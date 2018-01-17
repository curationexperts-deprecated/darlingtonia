# frozen_string_literal: true

module Darlingtonia
  class TitleValidator < Validator
    ##
    # @private
    #
    # @see Validator#validate
    def run_validation(parser:, **)
      parser.records.each_with_object([]) do |record, errors|
        titles = record.respond_to?(:title) ? record.title : []

        errors << error_for(record: record) if Array(titles).empty?
      end
    end

    protected

      ##
      # @private
      # @param record [InputRecord]
      #
      # @return [Error]
      def error_for(record:)
        Error.new(self,
                  :missing_title,
                  "Title is required; got #{record.mapper.metadata}")
      end
  end
end
