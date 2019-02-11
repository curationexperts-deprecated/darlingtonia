# frozen_string_literal: true
require 'spec_helper'

describe 'importing a CSV with Hyrax defaults', :clean do
  subject(:importer) { Darlingtonia::Importer.new(parser: parser, record_importer: record_importer) }
  let(:parser) { Darlingtonia::CsvParser.new(file: csv_file) }
  let(:record_importer) { Darlingtonia::HyraxRecordImporter.new }

  let(:csv_file) { File.open('spec/fixtures/hyrax/example.csv') }
  after { csv_file.close }

  load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
  include_context 'with a work type'

  it 'creates the record(s)' do
    expect { importer.import }.to change { Work.count }.to 2

    works = Work.all
    work1 = works.find { |w| w.title == ['Work 1 Title'] }
    work2 = works.find { |w| w.title == ['Work 2 Title'] }

    # First Record
    expect(work1.depositor).to eq 'batchuser@example.com'
    expect(work1.date_modified).to eq '2018-01-01'
    expect(work1.label).to eq 'Work 1 Label'
    expect(work1.relative_path).to eq 'tmp/files'
    expect(work1.import_url).to eq 'https://example.com'
    expect(work1.resource_type).to eq ['Work 1 Type']
    expect(work1.creator).to eq ['Work 1 creator']
    expect(work1.contributor).to eq ['Work 1 contrib']
    expect(work1.description).to eq ['Desc 1']
    expect(work1.keyword).to eq ['Key 1']
    expect(work1.license).to eq ['Lic 1']
    expect(work1.rights_statement).to eq ['RS 1']
    expect(work1.publisher).to eq ['Pub 1']
    expect(work1.date_created).to eq ['2018-06-06']
    expect(work1.subject).to eq ['Subj 1']

    # An example with 2 values
    expect(work1.language).to contain_exactly('English', 'Japanese')

    expect(work1.identifier).to eq ['Ident 1']
    expect(work1.based_near).to eq ['Based 1']
    expect(work1.related_url).to eq ['https://example.com/related']
    expect(work1.bibliographic_citation).to eq ['Bib 1']
    expect(work1.source).to eq ['Source 1']

    # Second Record
    expect(work2.depositor).to eq 'batchuser@example.com'
    expect(work2.date_modified).to be_nil
    expect(work2.label).to eq 'Work 2 Label'
    expect(work2.relative_path).to be_nil
    expect(work2.import_url).to be_nil
    expect(work2.resource_type).to eq ['Work 2 Type']
    expect(work2.creator).to eq []
    expect(work2.contributor).to eq []
    expect(work2.description).to eq ['Desc 2']
    expect(work2.keyword).to eq []
    expect(work2.license).to eq []
    expect(work2.rights_statement).to eq []
    expect(work2.publisher).to eq ['Pub 2']
    expect(work2.date_created).to eq []
    expect(work2.subject).to eq ['Subj 2']
    expect(work2.language).to eq []
    expect(work2.identifier).to eq []
    expect(work2.based_near).to eq []
    expect(work2.related_url).to eq []
    expect(work2.bibliographic_citation).to eq []
    expect(work2.source).to eq []
  end
end
