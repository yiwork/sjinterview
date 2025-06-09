FROM webhippie/golang:latest

RUN apk update
RUN apk add wget
RUN apk add git

RUN mkdir gocode
COPY ./gocode* ./gocode/*
RUN cd ./gocode
RUN go build 
RUN cp ./go_binary /usr/bin/ 
RUN chmod +x /usr/bin/go_binary 

# Pull down the art/logal files from the art-student we're workign with 
RUN wget https://www.dropbox.com/s/token/static-assets.tar.gz -O /root/app.tar.gz
RUN mkdir /opt/nginx
RUN mv /root/app.tar.gz /opt/nginx/app.tar.gz
RUN tar -zxvf /opt/nginx/app.tar.gz
COPY ./nginx.conf /etc/nginx/sites-available/

COPY super_secret_database.conf /opt/app/config/database.yml

RUN mkdir /rails
COPY ./rails/* /rails 
WORKDIR /rails 
RUN apk add node
RUN npm run build 

RUN rc-service crond start && rc-update add crond
COPY scraper_schedul.cron /etc/cron/cron.d/

RUN apk add --update nginx ruby
RUN /opt/rails/bin/rails s
ENV HOTDOG_SCRAPPER_PATH=/usr/bin/go_binary
CMD ["nginx", "-g", "daemon off;"]
