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

## TODO

* I mock is\_me? in "should be able to ignore itself" in connection_spec.rb for convenience, work out a way to not do that

# Missing features

em-campfire was written primarily to support [Scamp](https://github.com/wjessop/Scamp)/[scamp-campfire ](https://github.com/omgitsads/scamp-campfire) so I've implemented the features required for that first. There are other features left-over that I didn't need and I'll get round to at some point. If you need one before then ping me and I might write it, or a pull request is of course welcome.

See the [Campfire API](https://github.com/37signals/campfire-api) for reference:

* [Messages (recent, highlight, unhighlight)](https://github.com/37signals/campfire-api/blob/master/sections/messages.md)
* [Rooms (updating, locking, unlocking, leaving)](https://github.com/37signals/campfire-api/blob/master/sections/rooms.md)
* [Transcripts](https://github.com/37signals/campfire-api/blob/master/sections/transcripts.md)
* [Uploads](https://github.com/37signals/campfire-api/blob/master/sections/uploads.md)
* [Users (get self)](https://github.com/37signals/campfire-api/blob/master/sections/users.md)
* [Search](https://github.com/37signals/campfire-api/blob/master/sections/search.md)
* [Account](https://github.com/37signals/campfire-api/blob/master/sections/account.md)

## Contributing

See the CONTRIBUTING file