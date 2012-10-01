em-campfire is a library for interacting with the [Campfire](http://campfirenow.com/) chat application. It was extracted from the [Scamp](https://github.com/wjessop/Scamp) v1 bot framework.

## Installation

`gem install em-campfire` or put `gem 'em-campfire'` in your Gemfile.

## Example

``` ruby
require 'em-campfire'

EM.run {
  connection = EM::Campfire.new(:subdomain => "foo", :api_key => "jhhekrlfjnksdjnliyherkjb", :verbose => true)
  connection.join 293778
  connection.join 401739
  
  connection.on_message do |msg|
    puts msg.inspect
  end
  
  # Give lib a chance to connect
  EM::Timer.new(10) do
    # Say something on a specific channel
    connection.say "foofoofoo", "Robot Army"
  end
}
```

## Requirements

I've tested it in Ruby >= 1.9.3.

## How to contribute

Here's the most direct way to get your work merged into the project:

1. Fork the project
2. Clone down your fork
3. Create a feature branch
4. Add your feature + tests
5. Document new features in the README
6. Make sure everything still passes by running the tests
7. If necessary, rebase your commits into logical chunks, without errors
8. Push the branch up
9. Send a pull request for your branch

# Coverage

When you run the tests a coverage report is made. We're not aiming for 100% coverage, it's just a guide.

Take a look at the TODO list or known issues for some inspiration if you need it.

## TODO

* I mock is\_me? in "should be able to ignore itself" in connection_spec.rb for convenience, work out a way to not do that
* Some stuff is missing, such as user and room metadata fetching.

# Missing features

See the [Campfire API](https://github.com/37signals/campfire-api) for reference:

* uploads.rb
* transcripts.rb
* search.rb
* account.rb
* Updating rooms
* Leaving rooms
* Locking/Unlocking rooms
* Users get self