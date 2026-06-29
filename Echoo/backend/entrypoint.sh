#!/bin/sh

echo "Running database migrations..."
node ace migration:run --force

if [ ! -f /app/.seed-marker/.seeded ]; then
  echo "Seeding database..."
  node ace db:seed
  touch /app/.seed-marker/.seeded
  echo "Seeding complete."
else
  echo "Database already seeded, skipping."
fi

echo "Starting server..."
exec node bin/server.js
