# Darlingtonia

<table width="100%">
<tr><td>
<img alt="Darlingtonia californica image" src="https://upload.wikimedia.org/wikipedia/commons/2/20/Darlingtonia_californica_ne1.JPG" width="500px">
</td><td>
Object import for Hyrax. See the <a href="https://www.rubydoc.info/gems/darlingtonia">API documentation</a> for more
information. See the <a href="https://curationexperts.github.io/darlingtonia/">Getting Started</a> guide for a gentle introduction.
<br/><br/>
<a href="https://en.wikipedia.org/wiki/Darlingtonia_californica"><em>Darlingtonia californica</em></a>,
also called the California pitcher plant, cobra lily, or cobra plant, is a species of carnivorous plant, the sole member of the genus <i>Darlingtonia</i> in the family <i>Sarraceniaceae</i>. It is native to Northern California and Oregon growing in bogs and seeps with cold running water.
<br/><br/>

[![Gem Version](https://badge.fury.io/rb/darlingtonia.svg)](https://badge.fury.io/rb/darlingtonia)
[![Build Status](https://travis-ci.org/curationexperts/darlingtonia.svg?branch=master)](https://travis-ci.org/curationexperts/darlingtonia)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/darlingtonia)

</td></tr>
</table>

## Usage

In your project's `Gemfile`, add: `gem 'darlingtonia'`, then run `bundle install`.

To do a basic Hyrax import, first ensure that a [work type is registered](http://www.rubydoc.info/github/samvera/hyrax/Hyrax/Configuration#register_curation_concern-instance_method)
with your `Hyrax` application. Then write a class like this:

```ruby
require 'darlingtonia'

class MyImporter
  def initialize(csv_file)
    @csv_file = csv_file
    raise "Cannot find expected input file #{csv_file}" unless File.exist?(csv_file)
  end

  def import
    attrs = {
      collection_id: collection_id,     # pass a collection id to the record importer and all records will be added to that collection
      depositor_id: depositor_id,       # pass a Hyrax user_key here and that Hyrax user will own all objects created during this import
      deduplication_field: 'identifier' # pass a field with a persistent identifier (e.g., ARK) and it will check to see if a record with that identifier already     
    }                                   # exists, update its metadata if so, and only if it doesn't find a record with that identifier will it make a new object.

    file = File.open(@csv_file)
    parser = Darlingtonia::CsvParser.new(file: file)
    record_importer = Darlingtonia::HyraxRecordImporter.new(attributes: attrs)
    Darlingtonia::Importer.new(parser: parser, record_importer: record_importer).import
    file.close # unless a block is passed to File.open, the file must be explicitly closed
  end
end
```

You can find [an example csv file for import to Hyrax](https://github.com/curationexperts/darlingtonia/blob/master/spec/fixtures/hyrax/example.csv) in the fixtures directory. Files for attachment should have the filename in a column
with a heading of `files`, and the location of the files should be specified via an
environment variables called `IMPORT_PATH`. If `IMPORT_PATH` is not set, `HyraxRecordImporter` will look in `/opt/data` by default.

## Customizing
To input any kind of file other than CSV, you need to provide a `Parser` (out of the box, we support simple CSV import with `CsvParser`). We will be writing guides about
how to support custom mappers (for metadata outside of Hyrax's core and basic metadata fields).

This software is primarily intended for use in a [Hyrax](https://github.com/samvera/hyrax) project.
However, its dependency on `hyrax` is kept strictly optional so most of its code can be reused to
good effect elsewhere. Note: As of release 2.0, `HyraxBasicMetadataMapper` will be the default mapper.

## Development

```sh
git clone https://github.com/curationexperts/darlingtonia
cd darlingtonia

bundle install
bundle exec rake ci
```

### RSpec Support

This gem ships with RSpec shared examples and other support tools intended to ease testing and ensure
interoperability of client code. These can be included by adding `require 'darlingtonia/spec'` to a
`spec_helper.rb` or `rails_helper.rb` file in your application's test suite.
