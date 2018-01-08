# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::VERSION do
  subject { Darlingtonia::VERSION }

  it { is_expected.to be_a String }
end
