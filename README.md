em-campfire is a library for interacting with the [Campfire](http://campfirenow.com/) chat application. It was extracted from the [Scamp](https://github.com/wjessop/Scamp) v1 bot framework.

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

## TODO

* I mock is\_me? in "should be able to ignore itself" in connection_spec.rb for convenience, work out a way to not do that
* Some stuff is missing, such as user and room metadata fetching.
