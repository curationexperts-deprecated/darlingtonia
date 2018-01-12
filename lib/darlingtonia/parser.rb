# frozen_string_literal: true

module Darlingtonia
  ##
  # A generic parser
  #
  # @example
  #   file = File.open('path/to/import/manifest.csv')
  #
  #   Parser.for(file: file).records
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
      @validators ||= []

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
    # @return [Boolean] true if the
    def valid?
      errors.empty?
    end

    ##
    # @return [Boolean]
    def validate
      validators.each_with_object(errors) do |validator, errs|
        errs.concat(validator.validate(parser: self))
      end

      valid?
    end

    ##
    # @return [true]
    # @raise [ValidationError] if the file to parse is invalid
    def validate!
      validate || raise(ValidationError)
    end

    class NoParserError < TypeError; end
    class ValidationError < RuntimeError; end
  end # rubocop:enable Style/ClassVars
end
