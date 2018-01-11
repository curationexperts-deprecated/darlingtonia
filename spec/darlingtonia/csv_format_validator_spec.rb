# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::CsvFormatValidator do
  subject(:validator)  { described_class.new }
  let(:invalid_parser) { Darlingtonia::CsvParser.new(file: invalid_file) }
  let(:invalid_file)   { File.open('spec/fixtures/bad_example.csv') }

  it_behaves_like 'a Darlingtonia::Validator' do
    let(:valid_parser)   { Darlingtonia::CsvParser.new(file: valid_file) }
    let(:valid_file)     { File.open('spec/fixtures/example.csv') }
  end

  define :a_validator_error do
    match do |error|
      return false unless error.respond_to?(:validator)

      if fields
        return false if fields[:validator] && error.validator != fields[:validator]
        return false if fields[:name]      && error.name      != fields[:name]
      end

      true
    end

    chain :with, :fields
  end

  describe '#validate' do
    it 'returns a Validator::Error' do
      expect(validator.validate(parser: invalid_parser))
        .to contain_exactly a_validator_error
        .with(validator: validator.class,
              name:      CSV::MalformedCSVError)
    end
  end
end
