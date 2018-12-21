# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::RecordImporter, :clean do
  subject(:importer) do
    described_class.new(error_stream: error_stream, info_stream: info_stream)
  end

  let(:error_stream) { [] }
  let(:info_stream)  { [] }
  let(:record)       { Darlingtonia::InputRecord.new }

  it 'raises an error when no work type exists' do
    expect { importer.import(record: record) }
      .to raise_error 'No curation_concern found for import'
  end

  context 'with a registered work type' do
    load File.expand_path("../../support/shared_contexts/with_work_type.rb", __FILE__)
    include_context 'with a work type'

    it 'creates a work for record' do
      expect { importer.import(record: record) }
        .to change { Work.count }
        .by 1
    end

    it 'writes to the info stream before and after create' do
      expect { importer.import(record: record) }
        .to change { info_stream }
        .to contain_exactly(/^Creating record/, /^Record created/)
    end

    context 'when input record errors with LDP errors' do
      let(:ldp_error) { Ldp::PreconditionFailed }

      before { allow(record).to receive(:attributes).and_raise(ldp_error) }

      it 'writes errors to the error stream (no reraise!)' do
        expect { importer.import(record: record) }
          .to change { error_stream }
          .to contain_exactly(an_instance_of(ldp_error))
      end
    end

    context 'when input record errors unexpectedly' do
      let(:custom_error) { Class.new(RuntimeError) }

      before { allow(record).to receive(:attributes).and_raise(custom_error) }

      it 'writes errors to the error stream' do
        expect { begin; importer.import(record: record); rescue; end }
          .to change { error_stream }
          .to contain_exactly(an_instance_of(custom_error))
      end

      it 'reraises error' do
        expect { importer.import(record: record) }.to raise_error(custom_error)
      end
    end
  end
end
