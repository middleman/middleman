FROM ruby
MAINTAINER Jack M <exegete@mac.com>

RUN apt-get update \
  && apt-get install -qqy nodejs \
  && rm -rf /var/lib/apt/lists/*

COPY . /src/
RUN gem build /src/middleman/middleman.gemspec \
  && gem install ./middleman-*.gem \
  && rm -Rf /src/

VOLUME /project/
WORKDIR /project/

EXPOSE 4567
