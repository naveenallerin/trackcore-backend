# Dockerfile

# 1) Use a pinned base image with Ruby 3.2
FROM ruby:3.2.2

# Install system dependencies including postgresql-client
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# 4) Set the working directory inside the container
WORKDIR /app

# 5) Copy Gemfile first for layer caching
COPY Gemfile Gemfile.lock ./

# 6) Install all gems including test group
RUN bundle config set --local without '' && \
    bundle install --jobs 4 --retry 3

# 7) Copy the rest of the app code
COPY . .

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
