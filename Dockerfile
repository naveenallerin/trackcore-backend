# Dockerfile

# 1) Use a pinned base image with Ruby 3.2
FROM ruby:3.2.2

# 2) Install necessary Linux packages for building gems + NodeJS if needed
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs && \
    rm -rf /var/lib/apt/lists/*

# 4) Set the working directory inside the container
WORKDIR /app

# 3) Force-install the correct Bundler version (~> 2.6)
RUN gem install bundler:2.4.22

# Configure bundler
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV PATH="${BUNDLE_BIN}:${PATH}"

# 5) Copy Gemfile first for layer caching
COPY Gemfile Gemfile.lock ./

# 6) Install gems and create binstubs for Rails
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# 7) Copy the rest of the app code
COPY . .

# 8) Ensure correct permissions
RUN mkdir -p tmp/pids && \
    chmod -R 777 tmp log

# 9) Expose port 3000 for Rails/Puma
EXPOSE 3000

# 10) Set default environment (can be overridden)
ENV RAILS_ENV=development

# 11) Add entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# 12) Default command to run Rails server (puma)
CMD ["rails", "server", "-b", "0.0.0.0"]
