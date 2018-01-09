# frozen_string_literal: true

module Darlingtonia
  ##
  # A generic metadata mapper for input records
  #
  # Maps from hash accessor syntax (`['title']`) to method call dot syntax (`.title`)
  class HashMapper
    ##
    # @!attribute [r] meadata
    #   @return [Hash<String, String>]
    attr_reader :metadata

    ##
    # @param meta [#to_h]
    # @return [Hash<String, String>]
    def metadata=(meta)
      @metadata = meta.to_h
    end

    ##
    # @param name [Symbol]
    #
    # @return [Boolean]
    def field?(name)
      fields.include?(name)
    end

    ##
    # @return [Enumerable<Symbol>] The fields the mapper can process
    def fields
      return [] if metadata.nil?
      metadata.keys.map(&:to_sym)
    end

    def method_missing(method_name, *args, &block)
      return metadata[method_name.to_s] if fields.include?(method_name)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      field?(method_name) || super
    end
  end
end
