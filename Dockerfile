FROM ruby:3.1.1

WORKDIR /bins
COPY . /bins

ENV RACK_ENV=production

RUN bundle install

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
