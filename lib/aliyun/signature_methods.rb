require 'aliyun/signature_methods/hmac_sha1'

module Aliyun
  module SignatureMethods
    METHODS = {
      'HMAC-SHA1' => Aliyun::SignatureMethods::HmacSha1.instance
    }

    def self.[](name)
      METHODS[name]
    end
  end
end
