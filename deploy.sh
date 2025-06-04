#!/bin/bash

# Deployment script for Gigalixir
set -e

echo "🚀 Deploying to Gigalixir..."

# Deploy the application
echo "📦 Pushing to Gigalixir..."
git push gigalixir main

# Run migrations with required POOL_SIZE
echo "🗄️ Running database migrations..."
POOL_SIZE=2 gigalixir run mix ecto.migrate

# Seed the database
echo "🌱 Seeding database..."
POOL_SIZE=2 gigalixir run mix run priv/repo/seeds.exs

echo "✅ Deployment complete!"
echo "🌐 Visit your app at: https://$(gigalixir config | jq -r '.PHX_HOST')"