# EmbulkJavundler

this gem installs embulk java plugins from git repository.
And this gem run embulk command with installed java plugins.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'embulk_javundler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install embulk_javundler

## Usage

Write `Embulkfile`.

ex.
```
java_plugin "embulk-input-jdbc", github: "joker1007/embulk-input-jdbc", commit: "support-json-type", libdir: "embulk-input-postgresql/lib"
java_plugin "embulk-output-bigquery", github: "embulk/embulk-output-bigquery"
```

```sh
# install plugins to "plugins/java" directory
$ embulk_javundler install

# install plugins to ".plugins" directory
$ embulk_javundler install --path .plugins

# embulk preview with installed java plugins
$ embulk_javundler preview config.yml

# embulk run with installed java plugins
$ embulk_javundler run config.yml
```

After install, this gem generates `Embulkfile.lock`.
`Embulkfile.lock` is information of installed plugins.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec embulk_javundler` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joker1007/embulk_javundler.

