# frozen_string_literal: true

require 'spec_helper'

describe 'STDOUT as a MessageStream' do
  subject(:stream) { STDOUT }

  it_behaves_like 'a Darlingtonia::MessageStream'
end
