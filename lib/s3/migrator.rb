require_relative "migrator/version"

require "aws-sdk"

require "logger"
require "optparse"
require "thread"

module S3
  module Migrator
    extend self

    DEFAULT_THREAD_COUNT = 10

    def migrate!(opts)
      creds = Aws::Credentials.new(opts[:access_key_id], opts[:secret_access_key])
      s3_client = Aws::S3::Client.new(credentials: creds, region: opts[:region])

      pagerble = if opts[:prefix]
        s3_client.list_objects(bucket: opts[:src_bucket], prefix: opts[:prefix])
      else
        s3_client.list_objects(bucket: opts[:src_bucket])
      end

      logger = Logger.new(STDOUT)

      begin
        each_in_threads(opts[:thread_count] || DEFAULT_THREAD_COUNT, pagerble.contents) do |obj|
          begin
            s3_client.copy_object(
              bucket: opts[:dest_bucket],
              key: obj.key,
              copy_source: "#{opts[:src_bucket]}/#{obj.key}",
              acl: "public-read",
            )
            logger.info("copied: #{obj.key}")
          rescue => e
            logger.error(e)
          end
        end

        is_last = pagerble.last_page?
        pagerble = pagerble.next_page if !is_last
      end while !is_last
    end

    def each_in_threads(thread_count = 10, enumerable)
      queue = SizedQueue.new(thread_count)
      terminator = { quit: true }

      threads = thread_count.times.map do
        Thread.new do
          loop do
            obj = queue.shift
            break if obj.is_a?(Hash) && obj[:quit]
            yield obj
          end
        end
      end

      enumerable.each { |obj| queue.push obj }
      thread_count.times { queue.push terminator }
      threads.each(&:join)

      enumerable
    end
  end
end
