#!/bin/sh

# Environment variables
REQ_URL="${REQ_URL}"  # URL of the reload endpoint (e.g., http://localhost:8080/-/reload)
REQ_METHOD="${REQ_METHOD:-GET}"  # Request method GET or POST for requests to REQ_URL
REQ_RETRY_COUNT="${REQ_RETRY_COUNT:-5}"  # Number of retries for HTTP requests
REQ_RETRY_DELAY="${REQ_RETRY_DELAY:-5}"  # Delay between retries (seconds)
REQ_TIMEOUT="${REQ_TIMEOUT:-10}"  # Timeout for HTTP requests (seconds)
REQ_STATUS_CODE="${REQ_STATUS_CODE:-200}"  # Status code to expect from reload HTTP requests
WATCH_PATHS="${WATCH_PATHS}"  # Paths to watch for changes (comma-separated)
RELOAD_METHOD="${RELOAD_METHOD:-HTTP}"  # Default to http reload
SERVICE_NAME="${SERVICE_NAME}"  # Name of the service to reload

# Log a message with timestamp, prefix, and severity level
log_message() {
  local timestamp="$(date +'%Y-%m-%dT%H:%M:%S')"
  local severity="$1"
  local prefix="$2"
  local message="$3"

  echo "ts=$timestamp level=$severity [$prefix] message=$message"
}


# Function to trigger reload
reload_service() {
  case "$RELOAD_METHOD" in
    HTTP)
      # Send HTTP request with retries and timeout
      for attempt in $(seq 1 "$REQ_RETRY_COUNT"); do
        log_message "info" "HTTP" "Sending HTTP request attempt $attempt..."
        status_code=$(curl -sS -X "$REQ_METHOD" -o /dev/null -w "%{http_code}" "$REQ_URL" -m "$REQ_TIMEOUT")
        if [[ "$status_code" -eq "$REQ_STATUS_CODE" ]] ; then
          log_message "info" "HTTP" "Reload request successful."
          return 0
        fi
        log_message "warning" "HTTP" "Reload request failed. Retrying in $REQ_RETRY_DELAY seconds..."
        sleep "$REQ_RETRY_DELAY"
      done
      log_message "error" "HTTP" "Reload request failed after $REQ_RETRY_COUNT attempts."
      ;;
    SIGHUP)
      # Find running service process
      service_pid=$(pgrep -f "^$SERVICE_NAME")
      if [ -z "$service_pid" ]; then
        log_message "warning" "SIGHUP" "Service process for '$SERVICE_NAME' not found."
        return 1
      fi
      # Send HUP signal
      kill -HUP "$service_pid"
      log_message "info" "SIGHUP" "Successfully sent HUP signal to process $service_pid."
      ;;
    *)
      log_message "error" "SIGHUP" "Invalid reload method '$RELOAD_METHOD'."
      exit 1
      ;;
  esac
}

# Input validation and environment variable handling
if [[ "$RELOAD_METHOD" != "HTTP" && "$RELOAD_METHOD" != "SIGHUP" ]]; then
  log_message "error" "CONFIG" "Invalid RELOAD_METHOD '$RELOAD_METHOD'. Valid options are: HTTP or SIGHUP"
  exit 1
fi
if [ -z "$WATCH_PATHS" ]; then
  log_message "error" "CONFIG" "WATCH_PATHS environment variable not set. Please specify paths to watch for changes."
  exit 1
fi
if [[ "$RELOAD_METHOD" == "HTTP" ]]; then
  if [ -z "$REQ_URL" ]; then
    log_message "error" "CONFIG" "REQ_URL environment variable is required for HTTP reload."
    exit 1
  fi
  if [[ "$REQ_METHOD" != "GET" && "$REQ_METHOD" != "POST" ]]; then
    log_message "error" "CONFIG" "Invalid REQ_METHOD '$REQ_METHOD'. Valid options are: GET or POST"
    exit 1
  fi
fi
if [[ "$RELOAD_METHOD" == "SIGHUP" && -z "$SERVICE_NAME" ]]; then
  log_message "error" "CONFIG" "SERVICE_NAME environment variable is required for SIGHUP reload."
  exit 1
fi

# Check if shareProcessNamespace: true has been configued on pod
if [[ "$RELOAD_METHOD" == "SIGHUP" ]]; then
  if [[ $(cat /proc/1/cmdline) != "/pause" ]]; then
    log_message "error" "CONFIG" "Shared Process Namespace between Containers in a Pod must be enabled to use RELOAD_METHOD: SIGHUP"
    exit 1
  fi
fi

log_message "info" "RELOAD" "Starting Watches for paths: $WATCH_PATHS"
while inotifywait -qq -r -e create,modify,delete,delete_self $WATCH_PATHS; do
  log_message "info" "RELOAD" "Updated detected; Reloading."
  reload_service
done
