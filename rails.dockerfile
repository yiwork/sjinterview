FROM ruby:alpine

RUN apk update && apk add node

RUN mkdir /rails
WORKDIR /rails
COPY rails/ .

RUN npm run build

# command assumes that in the ruby:alpine container that 
# rails lives in /opt/rails/bin/rails
CMD [/opt/rails/bin/rails s]
