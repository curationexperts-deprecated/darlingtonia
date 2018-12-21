# frozen_string_literal: true

module Hyrax
  module BasicMetadata
    def self.included(work)
      work.property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false
      work.property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false
      work.property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
      work.property :resource_type, predicate: ::RDF::Vocab::DC.type
      work.property :creator, predicate: ::RDF::Vocab::DC11.creator
      work.property :contributor, predicate: ::RDF::Vocab::DC11.contributor
      work.property :description, predicate: ::RDF::Vocab::DC11.description
      work.property :keyword, predicate: ::RDF::Vocab::DC11.relation
      work.property :license, predicate: ::RDF::Vocab::DC.rights
      work.property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
      work.property :publisher, predicate: ::RDF::Vocab::DC11.publisher
      work.property :date_created, predicate: ::RDF::Vocab::DC.created
      work.property :subject, predicate: ::RDF::Vocab::DC11.subject
      work.property :language, predicate: ::RDF::Vocab::DC11.language
      work.property :identifier, predicate: ::RDF::Vocab::DC.identifier

      # Note: based_near is defined differently here than in Hyrax.
      work.property :based_near, predicate: ::RDF::Vocab::FOAF.based_near

      work.property :related_url, predicate: ::RDF::RDFS.seeAlso
      work.property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
      work.property :source, predicate: ::RDF::Vocab::DC.source
    end
  end
end
