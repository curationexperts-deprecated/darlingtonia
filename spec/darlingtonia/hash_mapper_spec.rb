# frozen_string_literal: true

describe Darlingtonia::HashMapper do
  it_behaves_like 'a Darlingtonia::Mapper' do
    let(:expected_fields) { metadata.keys.map(&:to_sym) }
    let(:metadata) { { 'a_field' => 'a', 'b_field' => 'b', 'c_field' => 'c' } }
  end
end
