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
  class Parser
    @subclasses = [] # @private

    ##
    # @!attribute [rw] file
    #   @return [File]
    attr_accessor :file

    ##
    # @param file [File]
    def initialize(file:, **_opts)
      self.file = file
      yield self if block_given?
    end

    class << self
      ##
      # @param file [Object]
      #
      # @return [Darlingtonia::Parser] a parser instance appropriate for
      #   the arguments
      #
      # @raise
      def for(file:)
        klass =
          @subclasses.find { |k| k.match?(file: file) } ||
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
        @subclasses << subclass
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

    class NoParserError < TypeError; end
  end
end
