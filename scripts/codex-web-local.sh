#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NODE_DIR="$PROJECT_DIR/.tools/node-v24.20.0-linux-x64"
RUN_DIR="$PROJECT_DIR/.run"
LOG_FILE="$RUN_DIR/codex-web.log"
ADDRESS_FILE="$RUN_DIR/codex-web.address"
SESSION_NAME="codex-web-local"
HOST="${CODEX_WEB_HOST:-0.0.0.0}"
PORT="${CODEX_WEB_PORT:-8214}"
PROBE_HOST="$HOST"
[[ "$PROBE_HOST" == "0.0.0.0" ]] && PROBE_HOST="127.0.0.1"

is_running() {
  tmux has-session -t "=$SESSION_NAME" 2>/dev/null
}

start() {
  if is_running; then
    echo "codex-web is already running in tmux session $SESSION_NAME."
    return
  fi
  if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then
    echo "Invalid CODEX_WEB_PORT: $PORT" >&2
    return 2
  fi
  mkdir -p "$RUN_DIR"
  : > "$LOG_FILE"
  printf 'http://%s:%s\n' "$HOST" "$PORT" > "$ADDRESS_FILE"

  local launch_command
  printf -v launch_command \
    'exec env PATH=%q CODEX_CLI_PATH=%q %q src/server/main.js --host %q --port %q >>%q 2>&1' \
    "$NODE_DIR/bin:$PATH" \
    "${CODEX_CLI_PATH:-/root/.local/bin/codex}" \
    "$NODE_DIR/bin/node" \
    "$HOST" \
    "$PORT" \
    "$LOG_FILE"
  tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR" "$launch_command"

  for _ in {1..50}; do
    if ! is_running; then
      echo "codex-web exited during startup. See $LOG_FILE" >&2
      return 1
    fi
    if curl --fail --silent --output /dev/null "http://$PROBE_HOST:$PORT/"; then
      echo "codex-web started at http://$HOST:$PORT (tmux: $SESSION_NAME)."
      return
    fi
    sleep 0.1
  done
  echo "codex-web did not become ready. See $LOG_FILE" >&2
  return 1
}

stop() {
  if ! is_running; then
    echo "codex-web is not running."
    return
  fi
  tmux kill-session -t "=$SESSION_NAME"
  echo "codex-web stopped."
}

status() {
  if is_running; then
    local address="http://$HOST:$PORT"
    [[ -f "$ADDRESS_FILE" ]] && address="$(<"$ADDRESS_FILE")"
    echo "codex-web is running at $address (tmux: $SESSION_NAME)."
  else
    echo "codex-web is not running."
    return 1
  fi
}

case "${1:-}" in
  start) start ;;
  stop) stop ;;
  restart) stop; start ;;
  status) status ;;
  logs) tail -n "${2:-100}" "$LOG_FILE" ;;
  *) echo "Usage: $0 {start|stop|restart|status|logs [lines]}" >&2; exit 2 ;;
esac
