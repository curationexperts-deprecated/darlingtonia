# Importing to Hyrax with Darlingtonia

## Getting Started
The simplest use case is importing content that matches [Hyrax's core and basic metadata fields](http://samvera.github.io/metadata_application_profile.html), plus a few extra fields that let Hyrax know how to display the content properly. At a very high level we're going to:
1. Write a simple import test first
1. Get the test passing
1. Write a rake task to run your import with real data

**Note:** This guide assumes that you already have a working Hyrax instance with at least one work type. If you need help doing that, see [the Hyrax documentation](https://github.com/samvera/hyrax#creating-a-hyrax-based-app). This guide is going to assume we're using an `Image` work type and attaching image files, but should be applicable to any work type or kind of attachment.

### 1. Write a simple import test
1. Make a directory for your importer: `mkdir app/importers`
1. Make a directory for your importer tests: `mkdir spec/importers`
1. Make a directory for your fixture files: `mkdir spec/fixtures/images`
1. Put three small images in `spec/fixtures/images` In this guide, we're using copyright free images from https://www.pexels.com/, `birds.jpg`, `cat.jpg`, and `dog.jpg`.
1. Make a directory for your CSV fixture files: `mkdir spec/fixtures/csv_import`
1. Put a file like this in `spec/fixtures/csv_import`:
  ```
  title,source,visibility
  "A Cute Dog",https://www.pexels.com/photo/animal-blur-canine-close-up-551628/,open
  "An Interesting Cat",https://www.pexels.com/photo/person-holding-white-cat-1383397/,open
  "A Flock of Birds",https://www.pexels.com/photo/animal-avian-beak-birds-203088/,open
  ```
1. Make a file called `spec/importers/modular_importer_spec.rb` that contains this:
  ```ruby
    # frozen_string_literal: true

    require 'rails_helper'
    require 'active_fedora/cleaner'

    RSpec.describe ModularImporter do
      let(:modular_csv)     { 'spec/fixtures/csv_import/modular_input.csv' }
      let(:user) { ::User.batch_user }

      before do
        DatabaseCleaner.clean
        ActiveFedora::Cleaner.clean!
      end

      it "imports a csv" do
        expect { ModularImporter.new(modular_csv).import }.to change { Work.count }.by 3
      end
    end
  ```
1. Make a file called `app/importers/modular_importer.rb` that contains just enough of an importer class that your test can run and give a meaningful error:
  ```ruby
    class ModularImporter
      def initialize(csv_file)
        @csv_file = csv_file
        raise "Cannot find expected input file #{csv_file}" unless File.exist?(csv_file)
      end

      def import
      end
    end
  ```
1. Run your test:
  ```
  bundle exec rspec spec/importers/modular_importer_spec.rb
  ```
  It should fail with a message like
  ```
  expected `Work.count` to have changed by 3, but was changed by 0
  ```

So, at this point, your test is running, but the importer isn't yet creating any records.

### 2. Get the test passing
1. Add the darlingtonia gem to your `Gemfile` and run bundle update:
  ```
    gem `darlingtonia`
  ```
2. Edit `app/importer/modular_importer.rb` so it looks like this:
  ```ruby
    require 'darlingtonia'

    class ModularImporter
      def initialize(csv_file)
        @csv_file = csv_file
        raise "Cannot find expected input file #{csv_file}" unless File.exist?(csv_file)
      end

      def import
        file = File.open(@csv_file)
        Darlingtonia::Importer.new(parser: Darlingtonia::CsvParser.new(file: file), record_importer: Darlingtonia::HyraxRecordImporter.new).import
        file.close # Note that we must close any files we open.
      end
    end
  ```
3. Now your test should pass with output something like this:

  ```
  ModularImporter
  Creating record: ["A Cute Dog"].Record created at: jw827b648Record created at: jw827b648Creating record: ["An Interesting Cat"].Record created at: 3n203z084Record created at: 3n203z084Creating record: ["A Flock of Birds"].Record created at: wm117n96bRecord created at: wm117n96b  imports a csv

  Finished in 7.56 seconds (files took 9.06 seconds to load)
  1 example, 0 failures
  ```
