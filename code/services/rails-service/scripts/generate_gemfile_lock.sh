#!/bin/bash

# Generate Gemfile.lock for rails-service without local Ruby
echo "Generating Gemfile.lock for rails-service..."

# Install build tools and run bundle install in a Docker container
docker run --rm -v $(pwd)/rails-service:/app ruby:3.2-slim bash -c "apt-get update && apt-get install -y build-essential libc-dev curl libpq-dev libyaml-dev libssl-dev zlib1g-dev && cd /app && bundle install"

if [ -f rails-service/Gemfile.lock ]; then
  echo "Gemfile.lock generated successfully at rails-service/Gemfile.lock"
else
  echo "Error: Gemfile.lock was not generated"
  exit 1
fi