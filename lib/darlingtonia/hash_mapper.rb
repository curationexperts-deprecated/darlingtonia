# frozen_string_literal: true

module Darlingtonia
  ##
  # A generic metadata mapper for input records
  #
  # Maps from hash accessor syntax (`['title']`) to method call dot syntax (`.title`)
  #
  # The fields provided by this mapper are dynamically determined by the fields
  # available in the provided metadata hash.
  #
  # All field values are given as multi-valued arrays.
  #
  # @example
  #   mapper = HashMapper.new
  #   mapper.fields # => []
  #
  #   mapper.metadata = { title: 'Comet in Moominland', author: 'Tove Jansson' }
  #   mapper.fields # => [:title, :author]
  #   mapper.title  # => ['Comet in Moominland']
  #   mapper.author # => ['Tove Jansson']
  #
  class HashMapper < MetadataMapper
    ##
    # @param meta [#to_h]
    # @return [Hash<String, String>]
    def metadata=(meta)
      @metadata = meta.to_h
    end

    ##
    # @return [Enumerable<Symbol>] The fields the mapper can process
    def fields
      return [] if metadata.nil?
      metadata.keys.map(&:to_sym)
    end

    ##
    # @see MetadataMapper#map_field
    def map_field(name)
      Array(metadata[name.to_s])
    end
  end
end
