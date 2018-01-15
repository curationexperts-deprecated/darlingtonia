# frozen_string_literal: true

require 'active_fedora'

##
# Bulk object import for Hyrax
module Darlingtonia
  require 'darlingtonia/version'
  require 'darlingtonia/metadata_mapper'
  require 'darlingtonia/hash_mapper'

  require 'darlingtonia/importer'
  require 'darlingtonia/record_importer'

  require 'darlingtonia/input_record'

  require 'darlingtonia/validator'
  require 'darlingtonia/validators/csv_format_validator'

  require 'darlingtonia/parser'
  require 'darlingtonia/parsers/csv_parser'
end
