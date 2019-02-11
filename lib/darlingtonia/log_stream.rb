# frozen_string_literal: true
require 'byebug'
module Darlingtonia
  class LogStream
    ##
    # @!attribute [rw] logger
    #   @return [Logger]
    # @!attribute [rw] severity
    #   @return [Logger::Serverity]
    attr_accessor :logger, :severity

    def initialize(logger: nil, severity: nil)
      self.logger   = logger   || Logger.new(build_filename)
      self.severity = severity || Logger::INFO
    end

    def <<(msg)
      logger.add(severity, msg)
      STDOUT << msg
    end

    private

      def build_filename
        return ENV['IMPORT_LOG'] if ENV['IMPORT_LOG']
        rails_log_name
      end

      def rails_log_name
        case ENV['RAILS_ENV']
        when 'production'
          Rails.root.join('log', "csv_import.log").to_s
        when 'development'
          Rails.root.join('log', "dev_csv_import.log").to_s
        when 'test'
          Rails.root.join('log', "test_csv_import.log").to_s
        when nil
          './darlingtonia_import.log'
        end
      rescue NameError
        './darlingtonia_import.log'
      end
  end
end
