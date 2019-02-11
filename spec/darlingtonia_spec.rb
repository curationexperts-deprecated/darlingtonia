# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia do
  describe '#config' do
    it 'can set a default error stream' do
      expect { described_class.config { |c| c.default_error_stream = STDOUT } }
        .to change { described_class.config.default_error_stream }
        .to(STDOUT)
    end

    it 'can set a default info stream' do
      expect { described_class.config { |c| c.default_info_stream = STDOUT } }
        .to change { described_class.config.default_info_stream }
        .to(STDOUT)
    end
  end
end
