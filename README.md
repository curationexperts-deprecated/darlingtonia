# Darlingtonia

<table width="100%">
<tr><td>
<img alt="Darlingtonia californica image" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Darlingtonia_californica_ne1.JPG/220px-Darlingtonia_californica_ne1.JPG">
</td><td>
Object import for Hyrax. See the [API documentation](https://www.rubydoc.info/gems/darlingtonia) for more
information. See the [Getting Started](https://curationexperts.github.io/darlingtonia/) guide for a gentle introduction.
<br/><br/>
<a href="https://en.wikipedia.org/wiki/Darlingtonia_californica"><em>Darlingtonia californica</em></a>,
also called the California pitcher plant, cobra lily, or cobra plant, is a species of carnivorous plant, the sole member of the genus <i>Darlingtonia</i> in the family <i>Sarraceniaceae</i>. It is native to Northern California and Oregon growing in bogs and seeps with cold running water.
<br/><br/>

[![Gem Version](https://badge.fury.io/rb/darlingtonia.svg)](https://badge.fury.io/rb/darlingtonia)
[![Build Status](https://travis-ci.org/curationexperts/darlingtonia.svg?branch=master)](https://travis-ci.org/curationexperts/darlingtonia)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/darlingtonia)

</td></tr>
</table>




Usage
-----

In your project's `Gemfile`, add: `gem 'darlingtonia'`, then run `bundle install`.


This software is primarily intended for use in a [Hyrax](https://github.com/samvera/hyrax) project.
However, its dependency on `hyrax` is kept strictly optional so most of its code can be reused to
good effect elsewhere. Note: As of release 2.0, `HyraxBasicMetadataMapper` will be the default mapper.

To do a basic Hyrax import, first ensure that a [work type is registered](http://www.rubydoc.info/github/samvera/hyrax/Hyrax/Configuration#register_curation_concern-instance_method)
with your `Hyrax` application. You need to provide a `Parser` (out of the box, we support simple CSV
import with `CsvParser`). Write a class like this:

```ruby
require 'darlingtonia'

class MyImporter
  def initialize(csv_file)
    @csv_file = csv_file
    raise "Cannot find expected input file #{csv_file}" unless File.exist?(csv_file)
  end

  def import
    file = File.open(@csv_file)
    Darlingtonia::Importer.new(parser: Darlingtonia::CsvParser.new(file: file), record_importer: Darlingtonia::HyraxRecordImporter.new).import
    file.close # unless a block is passed to File.open, the file must be explicitly closed
  end
end
```

Development
-----------

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
