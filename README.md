Anmo
====

[![Build status](https://secure.travis-ci.org/AndrewVos/anmo.png)](https://secure.travis-ci.org/AndrewVos/anmo)

What?
-----
Anmo acts as a mock api and can be used to store arbitrary pieces of data for integration testing flaky APIs.
This is generally *not a good idea*, but where you can't use [VCR](https://github.com/myronmarston/vcr) anmo is now an option.

How?
----

```
require "anmo"

Thread.new { Anmo.launch_server }

Anmo.create_request({
  :path => "/lookatmyhorse",
  :body => "my horse is amazing"
})
```

```
curl http://localhost:8787/lookatmyhorse
my horse is amazing
```