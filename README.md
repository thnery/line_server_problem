# line_server_problem

### Dependencies
This project uses `asdf` to manage dependencies version.

* Ruby 3.4.2
* Redis
* Optional:
  * wrk - for running multiple threads (test)
  * watch - for monitoring

### Instructions

* Run `./build.sh` to install the Ruby dependencies

* Run the application with: `./run.sh -f <file-path> -p <port> -d <debug>`
  * the debug option is mean to be 1 or 0

* (Optiona) Running `wrk` and `watch` for testing and monitoring
  * Monitor Redis with `watch`: `$ watch -n 1 'redis-cli info | grep -e "connected_clients\|instantaneous\|memory_human"'`
  * Performing 60s tests with `wrk`: `$ wrk -t 4 -c 1000 -d 60s --latency "http://localhost:4567/lines/898769"`

### Solution Definition

#### How does the system work?
The application was designed to use Redis as memory database.
When the server is up for the first time, the File will be loaded
to Redis line by line. Since the index of each line will be the
key in Redis, when the request is made as this example `curl http://localhost:4567/lines/9999`,
the passed index will be queried 2025-04-01n Redis database, returning the content
on the file, if the line is found.

The problem with this approach is the first time loading. The larger the file
the larger the time to load. However, in a real world application, I'd prefer
to use another system to load the file into Redis.

#### How will the system perform with large files?
As mentioned above, the system will load the file in Redis
at startup. Once the file is loaded, the lines are indexed and 
the response is satisfactory.

#### How the system perform with big amount of users?
The core of this system is the Redis database. It handles
multiple requests very well. Since the data indexed and cached,
users gets a fast response.

#### What were the consulted resources?
For building the web app, Sinatra documentation was the main resource for
consultation. https://sinatrarb.com/

I used Redis and Ruby Redis documentation to research how to use Redis
for this application.
* https://www.rubyguides.com/2019/04/ruby-redis/
* https://www.rubydoc.info/gems/redis/4.5.1/Redis:hset
* https://www.rubydoc.info/gems/redis/4.5.1/Redis:hget
* https://redis.io/docs/latest/commands/hget/
* https://redis.io/docs/latest/commands/hset/

#### What libraries and frameworks does the system use?
The two main tools I decided to use were Sinatra Framework and Redis.
I personally choose Sinatra as the main web framework because
it's simple and I didn't need a big tool like Rails to create a single endpoint.
Redis was chosen due to its capacity for handling big amount of requests. It was
designed for that. I use it for caching, but not only that. Some key:value problems
are a very good fit for Redis.

#### How long did I spend on this exercise?
Given my routine, I could only spend a few hours on it. Not really sure how many, 
but I'd guess 6 hours with research and implementation.
With more time, I'd probably break this application a little bit more. Here's an
example how I'd organize the tasks by prioritization.

1. Create a single background script to write the file lines in Redis
2. Create the endpoint to receive the request for `GET /lines/<index>`
3. Add application to the file (size, content-type...)
4. Create a unique request identifier
5. Use the unique request id for creating a background process to handle the request - This is where the data would be fetched
6. Add monitors for requests and redis database

#### If I could criticize my code 
I'd say I did the best I could with the time I had. I missed adding test coverage,
but I focused on the best performance solution, given the knowledge I have.
