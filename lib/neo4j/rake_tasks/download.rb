require 'ruby-progressbar'
require 'net/http'

module Neo4j
  module RakeTasks
    class Download
      def initialize(url)
        @url = url
      end

      def exists?
        status = head(@url).code.to_i
        (200...300).cover?(status)
      end

      def fetch(message)
        require 'open-uri'
        open(@url,
             content_length_proc: lambda do |total|
               create_progress_bar(message, total) if total && total > 0
             end,
             progress_proc: method(:update_progress_bar)).read
      end

      private

      def create_progress_bar(message, total)
        @progress_bar ||= ProgressBar.create title: message,
                                             total: total
      end

      def update_progress_bar(value)
        return unless @progress_bar
        value = @progress_bar.total >= value ? value : @progress_bar.total
        @progress_bar.progress = value
      end

      def head(url)
        uri = URI(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          return http.head("#{uri.path}?#{uri.query}")
        end
      end
    end
  end
end
