# frozen_string_literal: true

shared_context 'with a work type' do
  # A work type must be defined for the default `RecordImporter` to save objects
  before do
    load './spec/support/hyrax/core_metadata.rb'
    load './spec/support/hyrax/basic_metadata.rb'

    class Work < ActiveFedora::Base
      attr_accessor :visibility
      include ::Hyrax::CoreMetadata
      include ::Hyrax::BasicMetadata
    end

    module Hyrax
      def self.config
        Config.new
      end

      class Config
        def curation_concerns
          [Work]
        end
      end
    end
  end

  after do
    Object.send(:remove_const, :Hyrax) if defined?(Hyrax)
    Object.send(:remove_const, :Work)  if defined?(Work)
  end
end
