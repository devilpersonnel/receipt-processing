source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'

gem 'rake', '~> 10.3.2'

gem 'mysql2', '0.3.17'

gem 'bcrypt', '3.1.7'

gem 'tesseract-ocr'

gem 'rmagick', '2.13.2', :require => 'RMagick'

gem "paperclip", "~> 4.3"

gem 'aws-sdk', '1.49.0'

gem 'cocaine', '0.5.5'

gem 'rtesseract'

group :test, :development do
  gem 'pry-rails', '0.3.2'
  gem 'spring', '1.1.3'
end

# Using Capistrano for deployment
group :development do
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano3-puma'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '1.1.3'
  gem 'capistrano-rvm', :github => "capistrano/rvm"
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'sass'
gem 'puma'
gem 'sprockets'
# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

ENV['CFLAGS'] = '-I/usr/local/Cellar/tesseract/3.02.02_3/include -I/usr/local/Cellar/leptonica/1.71_1/include'
ENV['LDFLAGS'] = '-L/usr/local/Cellar/tesseract/3.02.02_3/lib -L/usr/local/Cellar/leptonica/1.71_1/lib'
