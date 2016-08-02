require 'ostruct'

require 'aliyun/errors'

module Aliyun
  class << self
    def configure
      yield config
    end
    def config
      @config ||= OpenStruct.new
    end
  end
end
