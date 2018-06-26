Darlingtonia
============

[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/darlingtonia)

Object import for Hyrax. See the [API documentation](https://www.rubydoc.info/gems/darlingtonia) for more
information.

Usage
-----

In your project's `Gemfile`, add: `gem 'darlingtonia', '~> 0.1'`, then do `bundle install`.


This software is primarily intended for use in a [Hyrax](https://github.com/samvera/hyrax) project.
However, its dependency on `hyrax` is kept strictly optional so most of its code can be reused to
good effect elsewhere.

To do a basic Hyrax import, first ensure that a [work type is registered](http://www.rubydoc.info/github/samvera/hyrax/Hyrax/Configuration#register_curation_concern-instance_method)
with your `Hyrax` application. You need to provide a `Parser` (out of the box, we support simple CSV
import with `CsvParser`).

```ruby
file = File.open('path/to/import.csv')
parser = Darlingtonia::CsvParser.new(file: file)

Darlingtonia::Importer.new(parser: parser).import

file.close # unless a block is passed to File.open, the file must be explicitly closed
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
