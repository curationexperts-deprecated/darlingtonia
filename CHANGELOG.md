3.0.0 - Wed Feb 13, 2019

* Change to method signature of HyraxRecordImporter.new
  * initialize method now accepts an attributes hash for
    attributes that come from the UI or importer rather
    than from the CSV/mapper. These are useful for logging
    and tracking the output of an import job for a given
    collection, user, or batch.
* Improved default logging
  * logs are more easily parsed, e.g., by splunk
  * logs contain summary information
  * option to pass in a batch_id to track successes and failures per batch

2.1.0 - Tue Feb 12, 2019

* Map a variety of values for 'visibility' to their Hyrax approved equivalents
* Remove date_uploaded from HyraxBasicMetadataMapper so it doesn't over-write the Hyrax provided timestamp
* Import headers are now case and whitespace insensitive
* Raise a more meaningful error when an expected file isn't found
* Transform location URIs into a based_near hash so geonames URIs import properly into Hyrax
* Add a default LogStream class so that Darlingtonia has logging by default instead of only sending output to STDOUT

2.0.0 - Mon Feb 4, 2019

Assume our base use case is to import into Hyrax.
  * Use HyraxRecordImporter as default
  * Use HyraxMapper as default
  * Add a getting started guide to the docs directory

1.2.3 - Thu Jan 24, 2019
------------------------

Update active_fedora version requirement to bypass a critical bug.

1.1.0 - Fri Mar 30, 2018
------------------------

Formatted message stream.

  - Adds a formatted message stream to wrap other streams in a formatter.

1.0.0 - Mon Jan 29, 2018
------------------------

No changes; this release commits to the API present in v0.3.0.

0.3.0 - Fri Jan 19, 2018
------------------------

Representative files.

  - `ImportRecord` now passes through a `#representative_file` to its mapper,
    returning `nil` if the mapper does not provide such a method.
  - `CsvParser#records` now returns an empty record collection if it is given
    invalid CSV input. This allows cleaner handling in other validations and
    imports.

0.2.0 - Wed Jan 17, 2018
------------------------

Error & info streams.

  - Extend `Parser` subclasses to define `DEFAULT_VALIDATORS` to hard code
    a default validator list.
  - Support streaming errors from `Validator` to an error stream (`#<<`).
  - Add configuration at `Darlingtonia.config` to set `default_error_stream`.
  - Introduce `MetadataMapper` as a base `Mapper` class.
  - Add error stream for `RuntimeError` to `RecordImporter`.
  - Add error stream handling for `Ldp::HTTPError` and `Faraday::Connection`
    errors to `RecordImporter`.
  - Add `info_stream`, `default_info_stream` (`#<<`) and notifications for
    before/after record import.
  - Improve validator documentation.
  - Add `TitleValidator` to validate presence of titles in parsed
    `InputRecord`s.

0.1.1 - Fri Jan 12, 2018
------------------------

Bugfix for nested class inheritance.

- Fix CI by requiring manually 'tempfile' in specs that use it
- Add a CSV format validator at `CsvFormatValidator`
- Fix `Parser` subclass registration and reorder parser class `#match`
  priority.

0.1.0 - Thu Jan 11, 2018
------------------------

Inital release.
