# LineService
# Holds the business logic for LineServer Problem

require 'redis'
require 'connection_pool'

class LineService
  class LineNotFoundError < StandardError; end

  def initialize
    @file_path = ENV.fetch('FILE_PATH', 'data/sample_file.txt')
    valid_file?

    @redis = ConnectionPool.new(size: 5, timeout: 3) do
      Redis.new({
        url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
        reconnect_attempts: 3
      })
    end

    load_redis!
  end

  def get_line(index)
    @redis.with do |conn|
      conn.hget('lines:index', index)
    end || raise(LineNotFoundError)
  end

  private

  def valid_file?
    raise FileLoadError, "File not found" unless File.exist?(@file_path)
    raise FileLoadError, "File is empty" if File.zero?(@file_path)

    # check if the file is ascii
    sample = File.read(@file_path, 1024) # check the first 1kb of the file
    raise FileLoadError, "File is not ASCII" unless sample.ascii_only?
  end

  def load_redis!
    @redis.with do |conn|
      return if conn.exists?('lines:index')

      # bulk load lines
      conn.pipelined do |pipe|
        File.foreach(@file_path).with_index do |line, idx|
          clean_line = line.encode('ASCII', invalid: :replace, undef: :replace).chomp
          pipe.hset('lines:index', idx, clean_line)
          puts "Loaded line #{idx}" if idx % 100_000 == 0 if ENV.fetch('DEBUG') == '1'
        end
      end
    end
  rescue => e
    raise FileLoadError, "Failed to load file: #{e.message}"
  end
end
