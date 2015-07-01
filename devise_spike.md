Devise spike memo
===

1. Gemfile
---
Add devise and bcrypt in your Gemfile.

```
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'devise'
```

I've got a liv8 error. So I tied this.

```
$ ruby -rubygems -e 'puts Gem::Platform.new(RUBY_PLATFORM)'
$ bundle config build.libv8 --with-system-v8
$ bundle config build.therubyracer --with-v8-dir
$ bundle install
```


[Yosemite で libv8 と therubyracer をインストールする](http://3.1415.jp/d3wpyqjr)

2. Install devise
---

```
$ bundle exec rails generate devise:install
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:

       config.assets.initialize_on_precompile = false

     On config/application.rb forcing your application to not access the DB
     or load models when precompiling your assets.

  5. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================

```

3. Database Migration
---

```
$ bundle exec rails generate controller home index
$ bundle exec rails generate devise user
$ bundle exec rake db:migrate
$ bundle exec rails server -b 0.0.0.0
```

