# frozen_string_literal: true

shared_context 'with a work type' do
  # A work type must be defined for the default `RecordImporter` to save objects
  before do
    class Work < ActiveFedora::Base
      property :title,       predicate: ::RDF::URI('http://example.com/title')
      property :description, predicate: ::RDF::URI('http://example.com/description')
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
    Object.send(:remove_const, :Hyrax)
    Object.send(:remove_const, :Work)
  end
end
