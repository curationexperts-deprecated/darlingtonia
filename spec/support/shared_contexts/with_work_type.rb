# frozen_string_literal: true

shared_context 'with a work type' do
  # A work type must be defined for the default `RecordImporter` to save objects
  before do
    load './spec/support/hyrax/core_metadata.rb'
    load './spec/support/hyrax/basic_metadata.rb'

    class Work < ActiveFedora::Base
      attr_accessor :visibility
      include ::Hyrax::CoreMetadata
      include ::Hyrax::BasicMetadata
    end

    class User < Struct.new(:id, :user_key)
      def initialize(inputs = {})
        self.id = inputs[:id]
        self.user_key = inputs[:user_key] || batch_user_key
      end

      def self.find_or_create_system_user(_email)
        User.new
      end

      def batch_user_key
        'batchuser@example.com'
      end
    end

    class Ability
      def initialize(user); end
    end

    module Hyrax
      def self.config
        Config.new
      end

      class Config
        def curation_concerns
          [Work]
        end
      end

      class UploadedFile < ActiveFedora::Base
        def self.create(*)
          h = Hyrax::UploadedFile.new
          h.save
          h
        end
      end

      module Actors
        class Environment
          attr_reader :new_object, :attributes
          def initialize(new_object, _ability, attributes)
            @new_object = new_object
            @attributes = attributes
          end
        end
      end

      class Actor
        def create(actor_env)
          attrs = actor_env.attributes
          attrs.delete(:uploaded_files)
          actor_env.new_object.attributes = attrs
          actor_env.new_object.save
        end
      end

      class CurationConcern
        def self.actor
          Hyrax::Actor.new
        end
      end
    end
  end

  after do
    Object.send(:remove_const, :Hyrax) if defined?(Hyrax)
    Object.send(:remove_const, :Work) if defined?(Work)
    Object.send(:remove_const, :User) if defined?(User)
    Object.send(:remove_const, :Ability) if defined?(Ability)
  end
end
