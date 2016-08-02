require 'net/http'
require 'time'
require 'securerandom'
require 'uri'
require 'json'
require 'logger'

require 'aliyun'
require 'aliyun/utils'
require 'aliyun/signature_methods'

module Aliyun
  module Services
    class Base
      attr_accessor :access_key_id, :access_key_secret

      def initialize(options)
        self.access_key_id = options[:access_key_id]
        self.access_key_secret = options[:access_key_secret]
      end

      def method_missing(method, *args, &block)
        if service_actions.include?(action = method.to_sym)
          params = args[0].nil? ? {} : args[0]
          send_request(action, params)
        else
          super
        end
      end
      
      def respond_to?(method, include_private = false)
        if service_actions.include?(method.to_sym)
          true
        else
          super
        end
      end

      def base_url
        "#{request_schema}://#{request_host}"
      end

      def secure?
        request_schema == 'https'
      end

      def name
        self.class::NAME
      end

      def request_host
        service_definition[:host]
      end

      def request_schema
        service_definition[:schema] || Aliyun.config.default_schema || 'https'
      end

      def response_format
        service_definition[:format] || Aliyun.config.default_format || 'JSON'
      end

      def api_version
        service_definition[:version]
      end

      def separator
        "&"
      end

      def http_method
        'GET'
      end

      def signature_method
        Aliyun::SignatureMethods[service_definition[:signature_method]]
      end

      def service_definition
        self.class.load_service_definition(name)
      end

      def service_actions
        service_action_definitions.keys
      end

      def service_action_definitions
        self.class.load_service_action_definitions(name)
      end

      private

      def send_request(action, params)
        uri = URI(base_url)
        uri.query = URI.encode_www_form(generate_request_params(action, params))

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = secure?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri)
        logger.debug uri.request_uri
        response = http.request(request)

        case response
        when Net::HTTPSuccess
          return process_data(action, response.body)
        else
          raise process_error(action, response.code, response.body)
        end
      end

      def generate_request_params(action, params)
        params = process_params(action, params)
        logger.debug params
        params = params.merge(default_params(action))
        logger.debug params
        params['Signature'] = signature_method.generate(params, self)
        logger.debug params
        params
      end

      def process_params(action, params)
        param_definitions = service_action_definitions[action][:parameters]
        params.reduce({}) do |new_params, (k,v)|
          unless param_definitions[k].nil?
            new_params[param_definitions[k][:parameter]] = v
          end
          new_params
        end
      end

      def process_data(action, data)
        JSON.parse(data)
      end

      def process_error(action, error_code, error_message)
        Aliyun::Errors::Base.new("Response code: #{error_code}, message: #{error_message}")
      end

      def default_params(action)
        {
          'Format'            => response_format,
          'Version'           => api_version,
          'Action'            => service_action_definitions[action][:action],
          'AccessKeyId'       => access_key_id,
          'Timestamp'         => Time.now.utc.iso8601,
          'SignatureMethod'   => signature_method.name,
          'SignatureVersion'  => signature_method.version,
          'SignatureNonce'    => SecureRandom.uuid
        }
      end

      def logger
        Aliyun.config.logger || Logger.new(STDOUT)
      end

      def self.load_service_definition(service_name)
        @@service_definition ||= {}
        @@service_definition[service_name] ||= Aliyun::Utils.symbolize_hash_keys(
          YAML::load_file("#{api_definition_dir}/#{service_name}.yml")
        )
      end


      def self.load_service_action_definitions(service_name)
        @@service_action_definitions ||= {}
        @@service_action_definitions[service_name] ||=  Dir["#{api_definition_dir}/#{service_name}/*.yml"].map do |file|
                                                          File.basename(file, '.yml')
                                                        end.reduce({}) do |actions, action_name|
                                                          actions[action_name.to_sym] = Aliyun::Utils.symbolize_hash_keys(
                                                            YAML::load_file("#{api_definition_dir}/#{service_name}/#{action_name}.yml")
                                                          )
                                                          actions
                                                        end
      end
    end
  end
end
