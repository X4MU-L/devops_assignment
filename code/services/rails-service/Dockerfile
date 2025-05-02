# Build stage
FROM ruby:3.4-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y build-essential libc-dev curl libpq-dev libyaml-dev libssl-dev zlib1g-dev
COPY Gemfile ./
RUN bundle install
COPY . .
RUN bundle install # Ensure Gemfile.lock is generated

# Test target
FROM ruby:3.2-slim AS test
WORKDIR /app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/Gemfile.lock /app/
COPY . .
CMD ["rspec", "spec/"]

# Dev target
FROM ruby:alpine AS dev
WORKDIR /app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/Gemfile.lock /app/
COPY . .
ENV ENV=dev
ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT=true
EXPOSE 8083
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8083"]

# Staging target
FROM ruby:3.2-slim AS staging
WORKDIR /app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/Gemfile.lock /app/
COPY . .
ENV ENV=staging
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
EXPOSE 8083
USER 1000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8083"]

# Prod target
FROM ruby:3.2-slim AS prod
WORKDIR /app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/Gemfile.lock /app/
COPY . .
ENV ENV=prod
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
EXPOSE 8083
USER 1000
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8083"]