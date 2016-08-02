module Aliyun
  module Utils    
    def symbolize_hash_keys(object)
      if object.is_a? Hash
        object.keys.each { |k| object[(k.to_sym rescue k) || k] = symbolize_hash_keys(object.delete(k)) }
      elsif object.is_a? Array
        object.each { |e| symbolize_hash_keys(e) }
      end
      object
    end
    
    module_function :symbolize_hash_keys
  end
end