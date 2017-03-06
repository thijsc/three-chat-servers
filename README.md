# A tale of three chat rooms

Example code to go with the talk of the same name and the [Ruby Magic](https://appsignal.com/ruby-magic) concurrency series of blog posts.

## Usage

Start one of the three servers:

```
ruby server_evented.rb
ruby server_processes.rb
ruby server_threads.rb
```

Start a few chat clients in different tabs:

```
ruby client.rb localhost <nickname>
```

Type away!
