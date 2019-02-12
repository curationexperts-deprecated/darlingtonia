# frozen_string_literal: true

module Darlingtonia
  ##
  # @abstract A null validator; always returns an empty error collection
  #
  # Validators are used to ensure the correctness of input to a parser. Each
  # validator must respond to `#validate` and return a collection of errors
  # found during validation. If the input is valid, this collection must be
  # empty. Otherwise, it contains any number of `Validator::Error` structs
  # which should be sent to the `#error_stream` by the validator.
  #
  # The validation process accepts an entire `Parser` and is free to inspect
  # the input `#file` content, or view its individual `#records`.
  #
  # The base class provides infrastructure for the key behavior, relying on a
  # private `#run_validation` method to provide the core behavior. In most cases
  # implementers will want to simply override this method.
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
  # @example Implementing a custom Validator and using it in a Parser
  #   # Validator checks that the title, when downcased is equal to `moomin`
  #   class TitleIsMoominValidator
  #     def run_validation(parser:)
  #       parser.records.each_with_object([]) do |record, errors|
  #         errors << Error.new(self, :title_is_not_moomin) unless
  #           title_is_moomin?(record)
  #       end
  #     end
  #
  #     def title_is_moomin?(record)
  #       return false unless record.respond_to?(:title)
  #       return true if record.title.downcase == 'moomin
  #       true
  #     end
  #   end
  #
  #   parser = MyParser.new(some_content)
  #   parser.validations << TitleIsMoominvalidator.new
  #   parser.validate
  #   parser.valid? # => false (unless all the records match the title)
  #
  # @see Parser#validate
  class Validator
    ##
    # A representation of an error encountered in validation.
    Error = Struct.new(:validator, :name, :description, :lineno) do
      ##
      # @!attribute [rw] validator
      #   @return [#to_s] the validator that generated this error
      # @!attribute [rw] name
      #   @return [#to_s] a short descriptive name for the given error
      # @!attribute [rw] description
      #   @return [#to_s] a long form description or message
      # @!attribute [rw] lineno
      #   @return [#to_s] the line number, or other indication of the location
      #     where the error was encountered

      ##
      # @return [Boolean]
      def validator_error?
        true
      end

      ##
      # @return [String]
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
    def initialize(error_stream: Darlingtonia.config.default_error_stream)
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

    private

      # rubocop:disable Lint/UnusedMethodArgument

      ##
      # @return [Enumerator<Error>]
      #
      def run_validation(parser:)
        [].to_enum
      end

    # rubocop:enable Lint/UnusedMethodArgument
  end
end
