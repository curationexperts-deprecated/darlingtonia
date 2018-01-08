# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::CsvParser do
  let(:file) { Tempfile.new(['fake', '.csv']) }

  it_behaves_like 'a Darlingtonia::Parser' do
    let(:records) { [] }
  end

  it 'matches .csv files' do
    expect(Darlingtonia::Parser.for(file: file)).to be_a described_class
  end
end
