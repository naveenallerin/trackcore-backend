# Dockerfile

# 1) Use a pinned base image with Ruby 3.2
FROM ruby:3.2.2-bullseye

# 2) Install necessary Linux packages for building gems + NodeJS if needed
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

# 3) Force-install the correct Bundler version (~> 2.6)
RUN gem install bundler -v "~> 2.6"

# 4) Set the working directory inside the container
WORKDIR /app

# 5) Copy Gemfile first for layer caching
COPY Gemfile ./

# 6) Install gems and create binstubs for Rails
RUN bundle install --system && \
    bundle binstubs rails

# 7) Copy the rest of the app code
COPY . .

# 8) Ensure correct permissions
RUN mkdir -p tmp/pids && \
    chmod -R 777 tmp log

# 9) Expose port 3000 for Rails/Puma
EXPOSE 3000

# 10) Default command to run Rails server (puma)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
