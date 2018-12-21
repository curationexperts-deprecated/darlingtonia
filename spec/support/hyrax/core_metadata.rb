# frozen_string_literal: true

module Hyrax
  module CoreMetadata
    def self.included(work)
      work.property :depositor, predicate: ::RDF::URI.new('http://id.loc.gov/vocabulary/relators/dpt'), multiple: false

      work.property :title, predicate: ::RDF::Vocab::DC.title

      work.property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted, multiple: false

      work.property :date_modified, predicate: ::RDF::Vocab::DC.modified, multiple: false
    end
  end
end
