# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::TitleValidator do
  subject(:validator) { described_class.new(error_stream: []) }

  let(:invalid_parser) do
    FakeParser.new(file: [{ 'title' => 'moomin' }, {}, {}])
  end

  it_behaves_like 'a Darlingtonia::Validator' do
    let(:valid_parser) { FakeParser.new(file: [{ 'title' => 'moomin' }]) }
  end

  describe '#validate' do
    it 'populates errors for records with missing titles' do
      expect(validator.validate(parser: invalid_parser))
        .to contain_exactly(an_instance_of(described_class::Error),
                            an_instance_of(described_class::Error))
    end
  end
end
