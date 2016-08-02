module Aliyun
  module SignatureMethods
    class Base
      include Singleton

      def name
        self.class::NAME
      end

      def version
        self.class::VERSION
      end
    end
  end
end
