# frozen_string_literal: true

module Darlingtonia
  ##
  # @abstract A null validator; always returns an empty error collection
  class Validator
    Error = Struct.new(:validator, :name, :description, :lineno)

    ##
    # @param parser       [Parser]
    # @param error_stream [#add]
    #
    # @return [Enumerator<Error>] a collection of errors found in validation
    def validate(*) # (parser:, error_stream:)
      []
    end
  end
end
