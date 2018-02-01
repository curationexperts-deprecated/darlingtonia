Darlingtonia
============

[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/darlingtonia)

Object import for Hyrax. See the [API documentation](http://www.rubydoc.info/gems/hyrax-spec) for more
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
parser = Darlingtonia::CsvParser.new(file: File.open('path/to/import.csv'))

Darlingtonia::Importer.new(parser: parser).import
```

Development
-----------

```sh
git clone https://github.com/curationexperts/darlingtonia
cd darlingtonia

bundle install
bundle exec rake ci
```
