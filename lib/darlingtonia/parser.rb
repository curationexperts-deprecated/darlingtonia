# frozen_string_literal: true

module Darlingtonia
  ##
  # A generic parser.
  #
  # `Parser` implementations provide a stream of `InputRecord`s, derived from an
  # input object (`file`), through `Parser#records`. This method should be
  # implemented efficiently for repeated access, generating records lazily if
  # possible, and caching if appropriate.
  #
  # Input validation is handled by an array of `#validators`, which are run in
  # sequence when `#validate` (or `#validate!`) is called. Errors caught in
  # validation are accessible via `#errors`, and inputs generating errors result
  # in `#valid? # => false`.
  #
  # A factory method `.for` is provided, and each implementation should
  # provides a `.match?(**)` which returns `true` if the options passed
  # indicate the parser can handle the given input. Parsers are checked for
  # `#match?` in the reverse of load order (i.e. the most recently loaded
  # `Parser` classes are given precedence).
  #
  # @example Getting a parser for a file input
  #   file = File.open('path/to/import/manifest.csv')
  #
  #   Parser.for(file: file).records
  #
  # @example Validating a parser
  #   parser = Parser.for(file: invalid_input)
  #
  #   parser.valid?   # => true (always true before validation)
  #   parser.validate # => false
  #   parser.valid?   # => false
  #   parser.errors   # => an array of Validation::Error-like structs
  #
  #   parser.validate! # ValidationError
  #
  # rubocop:disable Style/ClassVars
  class Parser
    DEFAULT_VALIDATORS = [].freeze
    @@subclasses = [] # @private

    ##
    # @!attribute [rw] file
    #   @return [File]
    # @!attribute [rw] validators
    #   @return [Array<Validator>]
    # @!attribute [r] errors
    #   @return [Array]
    attr_accessor :file, :validators
    attr_reader   :errors

    ##
    # @param file [File]
    def initialize(file:, **_opts)
      self.file     = file
      @errors       = []
      @validators ||= self.class::DEFAULT_VALIDATORS

      yield self if block_given?
    end

    class << self
      ##
      # @param file [Object]
      #
      # @return [Darlingtonia::Parser] a parser instance appropriate for
      #   the arguments
      #
      # @raise [NoParserError]
      def for(file:)
        klass =
          @@subclasses.find { |k| k.match?(file: file) } ||
          raise(NoParserError)

        klass.new(file: file)
      end

      ##
      # @abstract
      # @return [Boolean]
      def match?(**_opts); end

      private

      ##
      # @private Register a new class when inherited
      def inherited(subclass)
        @@subclasses.unshift subclass
        super
      end
    end

    ##
    # @abstract
    #
    # @yield [record] gives each record in the file to the block
    # @yieldparam record [ImportRecord]
    #
    # @return [Enumerable<ImportRecord>]
    def records
      raise NotImplementedError
    end

    ##
    # @return [Boolean] true if the file input is valid
    def valid?
      errors.empty?
    end

    ##
    # @return [Boolean] true if the file input is valid
    def validate
      validators.each_with_object(errors) do |validator, errs|
        errs.concat(validator.validate(parser: self))
      end

      valid?
    end

    ##
    # @return [true] always true, unless an error is raised.
    #
    # @raise [ValidationError] if the file to parse is invalid
    def validate!
      validate || raise(ValidationError)
    end

    class NoParserError < TypeError; end
    class ValidationError < RuntimeError; end
  end # rubocop:enable Style/ClassVars
end
