Anmo
====

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

Multiple Hosts?
---------------

Yep. If you have one running anmo server then each domain that points to that server will have it's own data in anmo.
For example the hosts anmo2.example.org and anmo2.example.org can point at the same anmo instance, and each will have their own data.
