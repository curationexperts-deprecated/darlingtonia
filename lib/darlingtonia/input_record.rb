# frozen_string_literal: true

module Darlingtonia
  class InputRecord
    ##
    # @!attribute [rw] mapper
    #   @return [#map_fields]
    attr_accessor :mapper

    ##
    # @param metadata [Object]
    # @param mapper   [#map_fields]
    def initialize(mapper: HashMapper.new)
      self.mapper = mapper
    end

    class << self
      def from(metadata:, mapper: HashMapper.new)
        mapper.metadata = metadata
        new(mapper: mapper)
      end
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
