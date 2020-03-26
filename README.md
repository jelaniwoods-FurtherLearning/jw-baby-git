# JwGit

Test gem to attempt to use a Sinatra app alongside a Rails app.
## Installation

Add this line to your application's Gemfile:

```ruby
gem "jw_git", github: "jelaniwoods-FurtherLearning/jw_git"
```

And then execute:

    $ bundle install

In a rails app run:
```bash
rails g jw_git:install
```
Then `rails server` and visit `/git/status`.

Or install it yourself as:

    $ gem install jw_git

## Usage

In your Rails app

```ruby
# config.ru
# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

map '/git' do
  run JwGit::Server
end

map '/' do
  run Rails.application
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jw_git. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jw_git/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JwGit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jw_git/blob/master/CODE_OF_CONDUCT.md).
