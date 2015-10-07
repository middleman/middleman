FROM ruby
MAINTAINER Jack M <exegete@mac.com>

RUN gem install execjs therubyracer

COPY . /src/
RUN gem build /src/middleman/middleman.gemspec \
  && gem install ./middleman-*.gem \
  && rm -Rf /src/

VOLUME /project/
WORKDIR /project/

EXPOSE 4567
