# frozen_string_literal: true

module Darlingtonia
  ##
  # A Validator that always gives an error named `:everytime`.
  #
  # @example
  #   validator = AlwaysInvalidValidator.new
  #   validator.validate(:anything, :at, :all) # => [Error<#...>]
  class AlwaysInvalidValidator < Validator
    ##
    # @return [Array<Validator::Error>]
    def validate(*)
      [Error.new(self, :everytime)]
    end
  end
end
