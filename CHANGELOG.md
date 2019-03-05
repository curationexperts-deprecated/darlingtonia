3.2.0 - Tue Mar 5, 2019

* Allow the importer to receive log settings from elsewhere, so it can log
success messages with all the other logs.

* When a record is imported a second time (i.e., when there is already a
record matching the deduplication field in the repository), only update
its metadata and collection membership. Use a stripped down actor stack
that only performs these actions.

* Log a special message if we attempt an empty import.

* Fix logging error where id number wasn't printing to logs on updates.

3.1.0 - Tue Feb 26, 2019

New Feature: `HyraxRecordImporter` now accepts a `deduplication_field` in the
attributes hash it receives  when it is created. If a `deduplication_field`
is provided, the system will look for existing works with that field and matching
value and will update the record instead of creating a new record.

3.0.5 - Tue Feb 26, 2019

When setting the depositor, query for user with `find_by_user_key`, which is the Hyrax convention.
If user_key isn't found, fall back to querying by User.id for backward compatibility.

3.0.4 - Fri Feb 22, 2019

* Allow subclassed libraries not to have a files field

  It should be fine to use HyraxRecordImporter with a customized mapper
  that does not contain a field called files. There are other strategies
  for attaching files, such as the remote_files strategy used at UCLA in
  the Californica project.

3.0.3 - Thu Feb 21, 2019

* Bug fix: Ensure there is no files metadata field passed

  If Hyrax (or perhaps some versions of Hyrax?) receives a metadata field called
  "files" it will not attach files correctly.

  It causes an exception like this:

  ```
  ActiveFedora::AssociationTypeMismatch:
        Hydra::PCDM::File(#47055098949460) expected, got String(#47054999182880)
  ```
  This change removes any :files field from the metadata before submitting to Hyrax.

3.0.2 - Thu Feb 21, 2019

* Bug fix: Do not fail to log errors if the record is missing a title

3.0.1 - Thu Feb 14, 2019

* Move the default log into a log folder

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
