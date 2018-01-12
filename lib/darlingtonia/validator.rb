# frozen_string_literal: true

module Darlingtonia
  ##
  # @abstract A null validator; always returns an empty error collection
  #
  # @example validating a parser
  #   validator = MyValidator.new
  #   validator.validate(parser: myParser)
  #
  # @example validating an invalid parser
  #   validator = MyValidator.new
  #   validator.validate(parser: invalidParser)
  #   # => Error<#... validator: MyValidator,
  #                   name: 'An Error Name',
  #                   description: '...'
  #                   lineno: 37>
  #
  class Validator
    Error = Struct.new(:validator, :name, :description, :lineno)

    ##
    # @param parser       [Parser]
    # @param error_stream [#add]
    #
    # @return [Enumerator<Error>] a collection of errors found in validation
    #
    # rubocop:disable Lint/UnusedMethodArgument
    def validate(parser:, **)
      []
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end
end
