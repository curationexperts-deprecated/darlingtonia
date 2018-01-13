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
    Error = Struct.new(:validator, :name, :description, :lineno) do
      def to_s
        "#{name}: #{description} (#{validator})"
      end
    end

    ##
    # @!attribute [rw] error_stream
    #   @return [#<<]
    attr_accessor :error_stream

    ##
    # @param error_stream [#<<]
    def initialize(error_stream: STDOUT)
      self.error_stream = error_stream
    end

    ##
    # @param parser [Parser]
    #
    # @return [Enumerator<Error>] a collection of errors found in validation
    def validate(parser:)
      run_validation(parser: parser).tap do |errors|
        errors.map { |error| error_stream << error }
      end
    end
    # rubocop:enable Lint/UnusedMethodArgument

    private

      ##
      # @return [Enumerator<Error>]
      #
      # rubocop:disable Lint/UnusedMethodArgument
      def run_validation(parser:)
        [].to_enum
      end
  end
end
