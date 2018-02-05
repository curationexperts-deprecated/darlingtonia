# frozen_string_literal: true

class FakeParser < Darlingtonia::Parser
  METADATA = [{ 'title' => '1' }, { 'title' => '2' }, { 'title' => '3' }].freeze

  def initialize(file: METADATA)
    super
  end

  def records
    return enum_for(:records) unless block_given?

    file.each { |hsh| yield Darlingtonia::InputRecord.from(metadata: hsh) }
  end
end

# rubocop:disable RSpec/FilePath
describe FakeParser do
  it_behaves_like 'a Darlingtonia::Parser' do
    subject(:parser)   { described_class.new }
    let(:record_count) { 3 }
  end
end
# rubocop:enable RSpec/FilePath
