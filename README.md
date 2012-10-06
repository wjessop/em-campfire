em-campfire is a library for interacting with the [Campfire](http://campfirenow.com/) chat application. It was extracted from the [Scamp](https://github.com/wjessop/Scamp) v1 bot framework.

## Installation

`gem install em-campfire` or put `gem 'em-campfire'` in your Gemfile.

## Example

``` ruby
require 'em-campfire'

EM.run {
  connection = EM::Campfire.new(:subdomain => "foo", :api_key => "jhhekrlfjnksdjnliyherkjb", :verbose => true)

  # Join a room, you will need the room id
  connection.join(10101)

  # Stream a room, need to join it first
  connection.join(2345) {|id| connection.stream(id) }

  # Dump out any message we get
  connection.on_message do |msg|
    puts msg.inspect
  end

  # Give lib a chance to connect
  EM::Timer.new(10) do
    # Say something on a specific channel
    connection.say "foofoofoo", 10101

    # Paste something
    connection.paste "foo\nfoo\nfoo", 10101

    # Play a sound
    connection.play "nyan", 10101
  end
}
```

For more features see the examples.

### Connection options

There are a few optional parameters you can create an EM::Campfire with:

``` ruby
require 'em-campfire'

EM.run {
  connection = EM::Campfire.new(
    :subdomain => "foo",
    :api_key => "jhhekrlfjnksdjnliyherkjb",
    :verbose => true,
    :logger => Logger::Syslog.new('process_name', Syslog::LOG_PID | Syslog::LOG_CONS),
    :cache => custom_cache_object,
    :ignore_self => true,
    :ignore_timestamps => true
  )

  # more code
}
```

#### :verbose

If set to true sets the log level to DEBUG, defaults to false.

#### :logger

em-campfire uses a Logger instance from stdlib by default, you can switch this out by passing in your own logger instance.

#### :cache

em-campfire caches responses from the Campfire API and issues conditional requests using ETags. By default it uses an in-memory cache of data returned, and this is fine for most people, but if you want something custom, possibly more permanent, you can pass in your own cache object.

The cache object should conform to the get/set API of the [redis-rb](https://github.com/redis/redis-rb) lib (making that a drop-in replacement). Just make sure that you use the synchrony driver.

#### :ignore_self

em-campfire receives messages that it posted on it's streaming connections. By default it processes these just as it would any other message. set :ignore_self to true to make it ignore messages it sends.

#### :ignore_timestamps

Campfire sends periodic timestamp messages. They're useless for most applications, so set this option and they will be totally ignored.

## Requirements

I've tested it in Ruby >= 1.9.3.

## TODO

* See if http connection/cacheing/failure handling can be abstracted
* Allow user to pass success/error callbacks
* Re-try failed HTTP requests
* Maybe encapsulate actions in objects, for instance a Room object

### Missing features

em-campfire was written primarily to support [Scamp](https://github.com/wjessop/Scamp)/[scamp-campfire ](https://github.com/omgitsads/scamp-campfire) so I've implemented the features required for that first. There are other features left-over that I didn't need and I'll get round to at some point. If you need one before then ping me and I might write it, or a pull request is of course welcome.

See the [Campfire API](https://github.com/37signals/campfire-api) for reference:

* [Messages (recent, highlight, unhighlight)](https://github.com/37signals/campfire-api/blob/master/sections/messages.md)
* [Rooms (updating, locking, unlocking, leaving)](https://github.com/37signals/campfire-api/blob/master/sections/rooms.md)
* [Transcripts](https://github.com/37signals/campfire-api/blob/master/sections/transcripts.md)
* [Uploads](https://github.com/37signals/campfire-api/blob/master/sections/uploads.md)
* [Search](https://github.com/37signals/campfire-api/blob/master/sections/search.md)
* [Account](https://github.com/37signals/campfire-api/blob/master/sections/account.md)

## Contributing

See the CONTRIBUTING file