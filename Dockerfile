# Use an official Elixir runtime as the base image
FROM elixir:1.18.4-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base git nodejs npm python3

# Create the application directory inside the container
WORKDIR /app

# Copy the mix.exs and mix.lock files to download dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

# Copy the rest of the application code
COPY . .

# Compile the application
RUN mix compile

# Create a release
RUN mix release

# Use a minimal image for the runtime
FROM alpine:latest

# Install openssl and other runtime dependencies
RUN apk add --no-cache bash openssl

# Create a non-root user
RUN adduser -D -H appuser

# Create the application directory
WORKDIR /app

# Copy the release from the build stage
COPY --from=build --chown=appuser:appuser /app/_build/prod/rel/hotel_management ./

# Change to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 4000

# Run the application
CMD ["./bin/hotel_management", "start"]