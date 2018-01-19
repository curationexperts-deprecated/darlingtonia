# coding: utf-8
# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

describe Darlingtonia::CsvParser do
  subject(:parser) { described_class.new(file: file) }
  let(:file)       { Tempfile.new(['fake', '.csv']) }

  shared_context 'with content' do
    let(:csv_content) do
      <<-EOS
title,description,date
The Moomins and the Great Flood,"The Moomins and the Great Flood (Swedish: Småtrollen och den stora översvämningen, literally The Little Trolls and the Great Flood) is a book written by Finnish author Tove Jansson in 1945, during the end of World War II. It was the first book to star the Moomins, but is often seen as a prelude to the main Moomin books, as most of the main characters are introduced in the next book.",1945
Comet in Moominland,"Comet in Moominland is the second in Tove Jansson's series of Moomin books. Published in 1946, it marks the first appearance of several main characters, like Snufkin and the Snork Maiden.",1946
EOS
    end

    let(:record_count) { 2 }

    before do
      file.write(csv_content)
      file.rewind
    end
  end

  it_behaves_like 'a Darlingtonia::Parser' do
    include_context 'with content'
  end

  it 'matches .csv files' do
    expect(Darlingtonia::Parser.for(file: file)).to be_a described_class
  end

  describe '#records' do
    context 'with valid content' do
      include_context 'with content'

      it 'has the correct titles' do
        expect(parser.records.map(&:title))
          .to contain_exactly(['The Moomins and the Great Flood'],
                              ['Comet in Moominland'])
      end

      it 'has correct other fields' do
        expect(parser.records.map(&:date)).to contain_exactly(['1945'], ['1946'])
      end
    end

    context 'with invalid file' do
      let(:file) { File.open('spec/fixtures/bad_example.csv') }

      it 'is empty' do
        expect(parser.records.to_a).to be_empty
      end
    end
  end

  describe '#validate' do
    it 'is valid' do
      expect(parser.validate).to be_truthy
    end

    context 'with invalid file' do
      let(:file) { File.open('spec/fixtures/bad_example.csv') }

      it 'is invalid' do
        expect(parser.validate).to be_falsey
      end
    end
  end
end
