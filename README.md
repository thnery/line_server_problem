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

The application was designed to use Redis as memory database.
When the server is up for the first time, the File will be loaded
to Redis line by line. Since the index of each line will be the
key in Redis, when the request is made as this example `curl http://localhost:4567/lines/9999`,
the passed index will be queried in Redis database, returning the content
on the file, if the line is found

