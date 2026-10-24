#!/usr/bin/env python3
"""AI エージェント（Antigravity, Claude 等）のローカル会話・実行ログを収集し、
VictoriaLogs に差分送信する汎用同期スクリプトである。
"""

import argparse
import glob
import json
import logging
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterator, List, Optional, Tuple

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("sync-ai-logs")

DEFAULT_VICTORIA_URL = "http://192.168.5.200:8427"
DEFAULT_STATE_FILE = os.path.expanduser("~/.local/state/ai-log-sync/state.json")


def parse_timestamp(ts: Any) -> Optional[str]:
    """様々な形式のタイムスタンプを RFC3339 (UTC) 文字列に正規化する。"""
    if not ts:
        return None
    if isinstance(ts, (int, float)):
        # ミリ秒 (13桁) または秒 (10桁)
        seconds = ts / 1000.0 if ts > 1e11 else float(ts)
        try:
            dt = datetime.fromtimestamp(seconds, tz=timezone.utc)
            return dt.isoformat()
        except (ValueError, OSError):
            return None
    if isinstance(ts, str):
        # 既に ISO 形式か
        return ts
    return None


class BaseCollector:
    """各 AI エージェントのログ収集基底クラスである。"""

    name = "base"

    def scan_files(self) -> List[Path]:
        """収集対象のファイル一覧を返す。"""
        raise NotImplementedError

    def parse_line(
        self, file_path: Path, raw_line: str, fallback_time: str
    ) -> Optional[Dict[str, Any]]:
        """1行の生ログを VictoriaLogs 投入用 JSON に正規化する。"""
        raise NotImplementedError


class AntigravityCollector(BaseCollector):
    """Antigravity の会話ログ (transcript_full.jsonl) を収集する。"""

    name = "antigravity"

    def __init__(self, base_dir: Optional[str] = None):
        self.base_dir = Path(
            base_dir or os.path.expanduser("~/.gemini/antigravity/brain")
        )

    def scan_files(self) -> List[Path]:
        if not self.base_dir.exists():
            return []
        # brain/<conversation_id>/.system_generated/logs/transcript_full.jsonl
        pattern = str(self.base_dir / "*" / ".system_generated" / "logs" / "transcript_full.jsonl")
        files = [Path(p) for p in glob.glob(pattern)]
        # mtime 順にソート
        files.sort(key=lambda p: p.stat().st_mtime)
        return files

    def parse_line(
        self, file_path: Path, raw_line: str, fallback_time: str
    ) -> Optional[Dict[str, Any]]:
        raw_line = raw_line.strip()
        if not raw_line:
            return None
        try:
            data = json.loads(raw_line)
        except json.JSONDecodeError:
            return None

        # 生データを保持したまま、VictoriaLogs 必須の _msg と識別メタデータを付与
        data["stream"] = "antigravity-test-1"
        data["conversation_id"] = file_path.parents[2].name
        if "created_at" in data:
            data["_time"] = data["created_at"]
        elif fallback_time:
            data["_time"] = fallback_time

        # VictoriaLogs の UI 表示用に _msg を設定（生フィールドはそのまま保持）
        content = data.get("content")
        if isinstance(content, str):
            data["_msg"] = content
        elif data.get("thinking"):
            data["_msg"] = data.get("thinking")
        else:
            step = data.get("step_index", "")
            step_type = data.get("type", "")
            data["_msg"] = f"[{step_type}] step {step}"
        return data


class ClaudeCollector(BaseCollector):
    """Claude Code の会話ログ (~/.claude/projects/*/*.jsonl) を収集する。"""

    name = "claude"

    def __init__(self, base_dir: Optional[str] = None):
        self.base_dir = Path(base_dir or os.path.expanduser("~/.claude/projects"))

    def scan_files(self) -> List[Path]:
        if not self.base_dir.exists():
            return []
        pattern = str(self.base_dir / "*" / "*.jsonl")
        files = [Path(p) for p in glob.glob(pattern)]
        files.sort(key=lambda p: p.stat().st_mtime)
        return files

    def parse_line(
        self, file_path: Path, raw_line: str, fallback_time: str
    ) -> Optional[Dict[str, Any]]:
        raw_line = raw_line.strip()
        if not raw_line:
            return None
        try:
            data = json.loads(raw_line)
        except json.JSONDecodeError:
            return None

        # 生データを保持したまま、VictoriaLogs 必須の _msg と識別メタデータを付与
        data["stream"] = "claude-test-1"
        ts = parse_timestamp(data.get("timestamp")) or fallback_time
        if ts:
            data["_time"] = ts

        # VictoriaLogs の UI 表示用に _msg を設定（生フィールドはそのまま保持）
        content = data.get("content")
        if isinstance(content, str):
            data["_msg"] = content
        elif isinstance(content, list):
            data["_msg"] = json.dumps(content, ensure_ascii=False)
        elif data.get("display"):
            data["_msg"] = str(data.get("display"))
        else:
            data["_msg"] = f"[{data.get('type', 'event')}]"
        return data


class StateManager:
    """送信済みオフセットを永続化するクラスである。"""

    def __init__(self, state_file: str):
        self.state_file = Path(state_file)
        self.state: Dict[str, Dict[str, Any]] = {}
        self._load()

    def _load(self):
        if self.state_file.exists():
            try:
                with open(self.state_file, "r", encoding="utf-8") as f:
                    self.state = json.load(f)
            except Exception as e:
                logger.warning("状態ファイルの読み込みに失敗した。再作成する: %s", e)
                self.state = {}
        else:
            self.state = {}

    def save(self):
        self.state_file.parent.mkdir(parents=True, exist_ok=True)
        temp_file = self.state_file.with_suffix(".tmp")
        with open(temp_file, "w", encoding="utf-8") as f:
            json.dump(self.state, f, indent=2, ensure_ascii=False)
        temp_file.replace(self.state_file)

    def get_offset(self, provider: str, file_path: str) -> int:
        return self.state.get(provider, {}).get(file_path, {}).get("offset", 0)

    def update_offset(self, provider: str, file_path: str, offset: int, mtime: float):
        if provider not in self.state:
            self.state[provider] = {}
        self.state[provider][file_path] = {
            "offset": offset,
            "mtime": mtime,
            "updated_at": datetime.now(timezone.utc).isoformat(),
        }


class VictoriaSender:
    """VictoriaLogs への HTTP POST を行うクラスである。"""

    def __init__(self, base_url: str):
        # vmauth は /insert/.* を vlagent:9429 にルーティングする
        self.url = f"{base_url.rstrip('/')}/insert/jsonline?_stream_fields=stream,conversation_id,sessionId"

    def send_batch(self, records: List[Dict[str, Any]]) -> bool:
        if not records:
            return True

        # JSON Lines 形式にエンコード
        lines = [json.dumps(r, ensure_ascii=False) for r in records]
        body = "\n".join(lines).encode("utf-8")

        req = urllib.request.Request(
            self.url,
            data=body,
            headers={
                "Content-Type": "application/stream+json",
                "User-Agent": "sync-ai-logs/1.0",
            },
            method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                if 200 <= resp.status < 300:
                    return True
                logger.error("VictoriaLogs への送信が異常ステータスを返した: %d", resp.status)
                return False
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8", errors="replace")
            logger.error("VictoriaLogs HTTP エラー (%d): %s", e.code, err_body)
            return False
        except Exception as e:
            logger.error("VictoriaLogs への接続に失敗した: %s", e)
            return False


def process_collector(
    collector: BaseCollector,
    state_mgr: StateManager,
    sender: VictoriaSender,
    batch_size: int = 500,
    dry_run: bool = False,
) -> Tuple[int, int]:
    """1つのコレクターのログ差分を処理する。"""
    files = collector.scan_files()
    total_records = 0
    total_files = 0

    for file_path in files:
        file_str = str(file_path.resolve())
        try:
            stat = file_path.stat()
        except OSError:
            continue

        prev_offset = state_mgr.get_offset(collector.name, file_str)
        # ファイルが以前より小さくなっていたらローテーションとみなして最初から
        if stat.st_size < prev_offset:
            prev_offset = 0

        if stat.st_size == prev_offset:
            continue

        fallback_time = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc).isoformat()
        records_to_send: List[Dict[str, Any]] = []
        new_offset = prev_offset

        try:
            with open(file_path, "r", encoding="utf-8", errors="replace") as f:
                f.seek(prev_offset)
                while True:
                    line_start = f.tell()
                    line = f.readline()
                    if not line:
                        break
                    # 末尾が改行でなければ書き込み中の可能性があるので次回に回す
                    if not line.endswith("\n"):
                        f.seek(line_start)
                        break

                    record = collector.parse_line(file_path, line, fallback_time)
                    if record:
                        records_to_send.append(record)
                    new_offset = f.tell()

                    if len(records_to_send) >= batch_size:
                        if dry_run:
                            logger.info(
                                "[DRY-RUN] %s: %s 件送信予定 (offset: %d -> %d)",
                                collector.name,
                                len(records_to_send),
                                prev_offset,
                                new_offset,
                            )
                        else:
                            if not sender.send_batch(records_to_send):
                                logger.error(
                                    "%s の送信に失敗したため、オフセット更新を中断する: %s",
                                    collector.name,
                                    file_path.name,
                                )
                                return total_files, total_records
                            state_mgr.update_offset(
                                collector.name, file_str, new_offset, stat.st_mtime
                            )
                            state_mgr.save()
                        total_records += len(records_to_send)
                        records_to_send = []
                        prev_offset = new_offset

                if records_to_send:
                    if dry_run:
                        logger.info(
                            "[DRY-RUN] %s: %s 件送信予定 (offset: %d -> %d)",
                            collector.name,
                            len(records_to_send),
                            prev_offset,
                            new_offset,
                        )
                    else:
                        if not sender.send_batch(records_to_send):
                            logger.error(
                                "%s の送信に失敗したため、オフセット更新を中断する: %s",
                                collector.name,
                                file_path.name,
                            )
                            return total_files, total_records
                        state_mgr.update_offset(
                            collector.name, file_str, new_offset, stat.st_mtime
                        )
                        state_mgr.save()
                    total_records += len(records_to_send)

            if new_offset > prev_offset:
                total_files += 1

        except Exception as e:
            logger.error("ファイル処理中にエラーが発生した (%s): %s", file_path, e)
            continue

    return total_files, total_records


def main():
    parser = argparse.ArgumentParser(
        description="Sync AI agent conversation logs to VictoriaLogs."
    )
    parser.add_argument(
        "--victoria-url",
        default=os.environ.get("VICTORIA_URL", DEFAULT_VICTORIA_URL),
        help=f"VictoriaLogs base URL (default: {DEFAULT_VICTORIA_URL})",
    )
    parser.add_argument(
        "--state-file",
        default=DEFAULT_STATE_FILE,
        help=f"Path to offset state file (default: {DEFAULT_STATE_FILE})",
    )
    parser.add_argument(
        "--provider",
        choices=["all", "antigravity", "claude"],
        default="all",
        help="Target provider (default: all)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate scan and parse without sending to VictoriaLogs",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=500,
        help="Batch size for POST requests (default: 500)",
    )

    args = parser.parse_args()

    state_mgr = StateManager(args.state_file)
    sender = VictoriaSender(args.victoria_url)

    collectors: List[BaseCollector] = []
    if args.provider in ("all", "antigravity"):
        collectors.append(AntigravityCollector())
    if args.provider in ("all", "claude"):
        collectors.append(ClaudeCollector())

    total_synced_files = 0
    total_synced_records = 0

    for col in collectors:
        logger.info("Collector 開始: %s", col.name)
        f_count, r_count = process_collector(
            col, state_mgr, sender, batch_size=args.batch_size, dry_run=args.dry_run
        )
        logger.info(
            "Collector 完了: %s (更新ファイル: %d, 送信レコード: %d)",
            col.name,
            f_count,
            r_count,
        )
        total_synced_files += f_count
        total_synced_records += r_count

    logger.info(
        "同期終了: 合計 %d ファイル / %d レコードを処理した",
        total_synced_files,
        total_synced_records,
    )


if __name__ == "__main__":
    main()
