require "pp"
require "yajl/json_gem"
require "stringio"

module CloudFoundry
  module Resources
    module Helpers

      def url(config, key)
        (config[:test] == true) ? config[key][:test] : config[key][:prod]
      end

      def proper_title(item)
        parts = item[:content_filename].split("/")
        return parts[1].capitalize if parts.count > 2

        "Documentation"
      end

      def json(key)
        hash = case key
          when Hash
            h = {}
            key.each { |k, v| h[k.to_s] = v }
            h
          when Array
            key
          else Resources.const_get(key.to_s.upcase)
        end

        hash = yield hash if block_given?

        %(<pre class="highlight"><code class="language-javascript">) +
          JSON.pretty_generate(hash) + "</code></pre>"
      end
    end

  end
end

include CloudFoundry::Resources::Helpers