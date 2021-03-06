# Capistrano Smaple v1

This is a web-application that web applications according to the Model-View-ViewModel (MVVM) pattern..

## Ruby version

```
ruby '2.6.5'
```

## System dependencies

```
ruby 2.6.5
rails 5.2
```

## Quick Start

### MacOS

```sh:Terminal
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

$ brew -v

$ brew upgrade

$ brew cask

$ brew install rbenv ruby-build

$ rbenv --version

$ rbenv install -l

$ rbenv install 2.6.5

$ rbenv versions

$ rbenv global 2.6.5

$ rbenv init

echo 'eval "$(rbenv init --no-rehash -)"' >>  ~/.bash_profile

$ source ~/.bash_profile

$ gem install bundler

$ brew install docker

$ brew cask install docker

$ docker --version

$ open /Applications/Docker.app

$ git clone git@github.com:webmaster-patche/capistrano_sample_app_v1.git

# move application root directory
$ cd capistrano_sample_app_v1

$ rbenv local 2.6.5
$ rbenv rehash

$ docker-compose up --build

$ docker logs capistrano_sample_app_v1_app_1

$ docker exec -it capistrano_sample_app_v1_app_1 /bin/bash

# bundle exec rails db:migrate RAILS_ENV=development
```

### CentOS

```sh:Terminal
yum install -y gcc-6 bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel

rbenv -v

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile

# list all available versions:
$ rbenv install -l

# install a Ruby version:
$ rbenv install 2.6.5

# install a bundler version 1.17.2 from Ruby gems.
$ gem install bundler -v 1.17.2

# git clone
$ git clone git@github.com:webmaster-patche/capistrano_sample_app_v1.git

# move application root directory
$ cd capistrano_sample_app_v1

$ rbenv local 2.6.5
$ rbenv rehash

# bundle install.
bundle _1.17.2_ install --path vendor/bundle

# start rails server for development
$ bundle exec rails s -p 8080
```

## Tutorial

### Add new action
- Scaffold使用を推奨

#### Scaffold Generate

```text:Terminal
# remove --skip-controller-specs / --skip-routing-specs / --skip-request-specs if you dont create spec
$ bundle exec rails generate scaffold v1::Event game:string description:string event_date:date join_limit:integer latitude:string longitude:string --skip-assets --skip-helper --skip-stylesheets --skip-view-specs --skip-jbuilder --skip-migration
      invoke  active_record
      create    app/models/v1/event.rb
      create    app/models/v1.rb
      invoke    rspec
      create      spec/models/v1/event_spec.rb
      invoke  resource_route
       route    namespace :v1 do
  resources :events
end
      invoke  scaffold_controller
      create    app/controllers/v1/events_controller.rb
      invoke    rspec
      create      spec/controllers/v1/events_controller_spec.rb
      create      spec/routing/v1/events_routing_spec.rb
      invoke      rspec
      create        spec/requests/v1/events_spec.rb

$ rm app/models/v1.rb
```

### How user action controller

- Extend ModelBaseController

```ruby:app/controllers/v1/events_controller.rb
class V1::EventsController < ModelBaseController
end
```

- RESTfulAPIに基づいている為、 `index, create, show, update, destroy` は適切なHTTP MethodとActionControllerメソッドが割り振られます
- メタプログラミングにてModelロードされます
- 各ActionControllerは `strong_param_pattern` メソッドをオーバーライドするのみです（Modelのattributesに合わせて定義してください）

### How to test

- Recommend using rspec

```text:Terminal
$ bundle exec rspec -fd  --format html --out spec/result.html spec/models/v1/event_spec.rb && open coverage/index.html
```