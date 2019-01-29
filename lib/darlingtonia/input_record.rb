# frozen_string_literal: true

module Darlingtonia
  ##
  # @example Building an importer with the factory
  #   record = InputRecord.from({some: :metadata}, mapper: MyMapper.new)
  #   record.some # => :metadata
  #
  class InputRecord
    ##
    # @!attribute [rw] mapper
    #   @return [#map_fields]
    attr_accessor :mapper

    ##
    # @param mapper [#map_fields]
    def initialize(mapper: HyraxBasicMetadataMapper.new)
      self.mapper = mapper
    end

    class << self
      ##
      # @param metadata [Object]
      # @param mapper  [#map_fields]
      #
      # @return [InputRecord] an input record mapping metadata with the given
      #   mapper
      def from(metadata:, mapper: HyraxBasicMetadataMapper.new)
        mapper.metadata = metadata
        new(mapper: mapper)
      end
    end

    ##
    # @return [Hash<Symbol, Object>]
    def attributes
      mapper.fields.each_with_object({}) do |field, attrs|
        attrs[field] = public_send(field)
      end
    end

    ##
    # @return [String, nil] an identifier for the representative file; nil if
    #   none is given.
    def representative_file
      return mapper.representative_file if
        mapper.respond_to?(:representative_file)

      nil
    end

    ##
    # Respond to methods matching mapper fields
    def method_missing(method_name, *args, &block)
      return super unless mapper.field?(method_name)
      mapper.public_send(method_name)
    end

    ##
    # @see #method_missing
    def respond_to_missing?(method_name, include_private = false)
      mapper.field?(method_name) || super
    end
  end
end
