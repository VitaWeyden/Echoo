#!/bin/sh
set -e

echo "Running database migrations..."
node ace migration:run --force || true

echo "Starting server..."
exec node bin/server.js
