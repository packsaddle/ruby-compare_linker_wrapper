# CompareLinkerWrapper

[![Gem Version](http://img.shields.io/gem/v/compare_linker_wrapper.svg?style=flat)](http://badge.fury.io/rb/compare_linker_wrapper)
[![Build Status](http://img.shields.io/travis/packsaddle/ruby-compare_linker_wrapper/master.svg?style=flat)](https://travis-ci.org/packsaddle/ruby-compare_linker_wrapper)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'compare_linker_wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install compare_linker_wrapper

## Usage

```
git diff --name-only origin/master \
 | grep ".*[gG]emfile.lock$" || RETURN_CODE=$?

case "$RETURN_CODE" in
 "" ) echo "found" ;;
 "1" )
   echo "not found"
   exit 0 ;;
 * )
   echo "Error"
   exit $RETURN_CODE ;;
esac

git diff --name-only origin/master \
 | grep ".*[gG]emfile.lock$" \
 | xargs compare-linker-wrapper --base origin/master \
    --formatter CompareLinker::Formatter::Text \
 | text-to-checkstyle \
 | saddler report \
    --require saddler/reporter/github \
    --reporter Saddler::Reporter::Github::PullRequestComment
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec compare_linker_wrapper` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/packsaddle/ruby-compare_linker_wrapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
