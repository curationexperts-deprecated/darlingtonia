# frozen_string_literal: true

require 'spec_helper'

describe 'importing a csv batch', :clean do
  subject(:importer) { Darlingtonia::Importer.new(parser: parser) }
  let(:parser)       { Darlingtonia::CsvParser.new(file: file) }
  let(:file)         { File.open('spec/fixtures/example.csv') }

  load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
  include_context 'with a work type'

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
