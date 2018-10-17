FROM ruby:2.5.1-alpine3.7

RUN apk --no-cache add \
  nodejs=8.9.3-r1 \
  ruby-dev=2.4.4-r0 \
  build-base=0.5-r0 \
  git=2.15.2-r0

ARG MIDDLEMAN_VERSION

RUN gem install --no-document \
    middleman --version $MIDDLEMAN_VERSION

WORKDIR /app