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
