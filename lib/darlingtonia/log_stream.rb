# frozen_string_literal: true

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
        return rails_log_name if rails_log_name
        './log/darlingtonia_import.log'
      end

      def rails_log_name
        case Rails.env
        when 'production'
          Rails.root.join('log', "csv_import.log").to_s
        when 'development'
          Rails.root.join('log', "dev_csv_import.log").to_s
        when 'test'
          Rails.root.join('log', "test_csv_import.log").to_s
        end
      rescue ::NameError
        false
      end
  end
end
