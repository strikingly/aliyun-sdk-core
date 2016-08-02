require 'uri'
require 'base64'
require 'hmac-sha1'

require 'aliyun/signature_methods/base'

module Aliyun
  module SignatureMethods
    class HmacSha1 < Base
      NAME = "HMAC-SHA1".freeze
      VERSION = "1.0".freeze

      def generate(params, service)
        calculate_signature("#{service.access_key_secret}&", string_to_sign(params, service))
      end

      private

      def calculate_signature(key, string_to_sign)
        hmac = HMAC::SHA1.new(key)
        hmac.update(string_to_sign)
        Base64.encode64(hmac.digest).gsub("\n", '')
      end

      def string_to_sign(params, service)
        "#{service.http_method}#{service.separator}#{safe_encode('/')}#{service.separator}#{safe_encode(canonicalized_query_string(params, service))}"
      end

      def canonicalized_query_string(params, service)
        params.keys.sort.map do |k|
          "%s=%s" % [safe_encode(k.to_s), safe_encode(params[k.to_s])]
        end.join(service.separator)
      end

      def safe_encode(s)
        URI.encode_www_form_component(s).gsub(/\+/,'%20').gsub(/\*/,'%2A').gsub(/%7E/,'~')
      end
    end
  end
end
