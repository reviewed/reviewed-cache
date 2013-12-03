module Reviewed
  class Cache
    class Key
      include ::Rack::Utils
      attr_reader :allow_query_params, :ignore_query_params

      def initialize(request_or_url, opts={})
        @allow_query_params = (opts[:allow_query_params] || configured_params('allow_query_params')).map(&:downcase)
        @ignore_query_params = (opts[:ignore_query_params] || configured_params('ignore_query_params')).map(&:downcase)

        # Accept a Request object, a string, or a URI
        if request_or_url.respond_to?(:url)
          @url = URI(URI.escape(request_or_url.url))
        elsif request_or_url.is_a?(String)
          @url = URI(URI.escape(request_or_url))
        else
          @url = request_or_url
        end
      end

      # Generate a normalized cache key for the url.
      def generate
        @key ||= begin
          parts = []
          parts << @url.scheme << "://"
          parts << @url.host

          if @url.scheme == "https" && @url.port != 443 ||
              @url.scheme == "http" && @url.port != 80
            parts << ":" << @url.port.to_s
          end

          parts << @url.path

          if query && query != ""
            parts << "?"
            parts << query
          end

          parts.join
        end
      end

      def to_s
        self.generate
      end

      private
      # Build a normalized query string by alphabetizing all keys/values
      # and applying consistent escaping.
      def query
        return nil if @url.query.nil?
        if whitelist_mode?
          whitelist(@url.query)
        else
          blacklist(@url.query)
        end
      end

      def whitelist(query)
        query_params = deparameterize(query)
        whitelisted_params = query_params.select{|k,v| whitelisted?(k) }
        parameterize(whitelisted_params)
      end

      def blacklist(query)
        query_params = deparameterize(query)
        blacklisted_params = query_params.reject{|k,v| blacklisted?(k) }
        parameterize(blacklisted_params)
      end

      def parameterize(params)
        params.map{ |k,v| "#{escape(k)}=#{escape(v)}" }.join('&')
      end

      def deparameterize(query)
        query.split(/[&;] */n).map { |p| unescape(p).split('=', 2) }.sort
      end

      def whitelisted?(param)
        allow_query_params.include?(param)
      end

      def blacklisted?(param)
        ["no-cachely", "refresh-cachely", ignore_query_params].flatten.include?(param)
      end

      def whitelist_mode?
        # Whitelist mode is enabled when the whitelist is the ONLY list set
        ignore_query_params.empty? && allow_query_params.any?
      end

      def blacklist_mode?
        !whitelist_mode?
      end

      def configured_params(params)
        if configured = configatron.reviewed_cache_key.retrieve(params)
          configured.flatten
        else
          []
        end
      end
    end
  end
end