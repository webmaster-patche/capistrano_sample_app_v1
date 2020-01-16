FROM ruby:2.6.5

# Setting environment
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV APP_HOME /var/www/capistrano_sample_app_v1

# Install libraries
RUN apt-get update -qq && \
    apt-get install -y build-essential \ 
                       libpq-dev \        
                       nodejs \           
                       vim \
                       default-mysql-client
RUN gem install bundler -v '2.1.4'

# Create app home
RUN mkdir -p $APP_HOME

WORKDIR $APP_HOME

# Copy Gemfile from origin
ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock

RUN bundle _2.1.4_ install --path vendor/bundle
RUN bundle exec rails db:migrate RAILS_ENV=development

ADD . $APP_HOME
