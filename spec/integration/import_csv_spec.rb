# frozen_string_literal: true

require 'spec_helper'

describe 'importing a csv batch' do
  subject(:importer) { Darlingtonia::Importer.new(parser: parser) }
  let(:parser)       { Darlingtonia::CsvParser.new(file: file) }
  let(:file)         { File.open('spec/fixtures/example.csv') }

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

  it 'creates a record for each CSV line' do
    expect { importer.import }.to change { Work.count }.to 3
  end

  describe 'validation' do
    context 'with invalid CSV' do
      let(:file) { File.open('spec/fixtures/bad_example.csv') }

      it 'outputs invalid file notice to error stream' do
        expect { parser.validate }
          .to output(/^CSV::MalformedCSVError.*line 2/)
          .to_stdout_from_any_process
      end
    end
  end
end
