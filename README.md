# Fluent::Plugin::Allsyslog

This fluentd parser plugin is a modified version of the built in fluent syslog parser.
It's smarter then the old one and will automatically detect if the syslog message has a priority and format.
It supports the newer rfc5424 syslog format along with the older syslog messages.
It also automatically parse the time formats using the build in 
ruby time parser rather than specifying the expected format. 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-allsyslog'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-allsyslog

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/athenahealth/fluent-plugin-allsyslog/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
