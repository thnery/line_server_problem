#!/usr/bin/env bash

# run.sh - Start the Sinatra application with configurable file path

set -euo pipefail # Enable strict mode

# Default configuration
DEFAULT_FILE_PATH="data/sample_file.txt"
PORT=${PORT:-4567}
RACK_ENV=${RACK_ENV:-production}
DEBUG=0

# Parse command line arguments
while getopts ":f:p:d:" opt; do
  case $opt in
  f) FILE_PATH="$OPTARG" ;;
  p) PORT="$OPTARG" ;;
  d) DEBUG="$OPTARG" ;;
  *)
    echo "Usage: $0 [-f file_path] [-p port] [-d debug]"
    exit 1
    ;;
  esac
done

# Set default file path if not provided
FILE_PATH=${FILE_PATH:-$DEFAULT_FILE_PATH}

# Validate file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found at $FILE_PATH"
  exit 1
fi

# Check for required services
if ! command -v redis-server &>/dev/null; then
  echo "Warning: Redis not running. Starting Redis..."
  redis-server --daemonize yes
fi

# Export environment variables
export FILE_PATH
export PORT
export RACK_ENV

# Start the application
echo "Starting server with:"
echo "  File:    $FILE_PATH"
echo "  Port:    $PORT"
echo "  Debug:   $DEBUG"
echo "  Environment: $RACK_ENV"

exec bundle exec ruby app.rb
