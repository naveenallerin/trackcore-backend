#!/bin/bash
set -e

# Remove any existing server.pid
rm -f /app/tmp/pids/server.pid

# Execute the main container command
exec "$@"
