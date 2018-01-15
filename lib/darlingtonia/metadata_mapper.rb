# frozen_string_literal: true

module Darlingtonia
  ##
  # A null/base mapper that maps no fields.
  #
  # Real mapper implementations need to provide `#fields`, enumerating over
  # `Symbols` that represent the fields on the target object (e.g. an
  # `ActiveFedora::Base`/`Hyrax::WorkBehavior`) that the mapper can handle.
  # For each field in `#fields`, the mapper must respond to a matching method
  # (i.e. `:title` => `#title`), and return the value(s) that should be set to
  # the target's attributes upon mapping.
  #
  # To ease the implementation of field methods, this base class provides
  # a `#method_missing` that forwards missing method names to a `#map_field`
  # method. `#map_field` can be implemented to provide a generalized field
  # mapping when a common pattern will be used for many methods. Callers should
  # avoid relying on this protected method directly, since mappers may implement
  # individual field methods in any other way (e.g. `def title; end`) to route
  # around `#map_field`. Implementations are also free to override
  # `#method_missing` if desired.
  #
  # Mappers generally operate over some input `#metadata`. Example metadata
  # types that mappers could be implemented over include `Hash`, `CSV`, `XML`,
  # `RDF::Graph`, etc...; mappers are free to interpret or ignore the contents
  # of their underlying metadata data structures at their leisure. Values for
  # fields are /usually/ derived from the `#metadata`, but can also be generated
  # from complex logic or even hard-coded.
  #
  # @example Using a MetadataMapper
  #   mapper = MyMapper.new
  #   mapper.metadata = some_metadata_object
  #   mapper.fields # => [:title, :author, :description]
  #
  #   mapper.title # => 'Some Title'
  #
  #   mapper.fields.map { |field| mapper.send(field) }
  #
  #
  # @see ImportRecord#attributes for the canonical usage of a `MetadataMapper`.
  # @see HashMapper for an example implementation with dynamically generated
  #   fields
  class MetadataMapper
    ##
    # @!attribute [rw] metadata
    #   @return [Object]
    attr_accessor :metadata

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
      []
    end

    def method_missing(method_name, *args, &block)
      return map_field(method_name) if fields.include?(method_name)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      field?(method_name) || super
    end

    protected

      ##
      # @private
      #
      # @param name [Symbol]
      #
      # @return [Object]
      def map_field(_name)
        raise NotImplementedError
      end
  end
end
