require 'active_support/concern'

module UserElasticsearch
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    index_name 'urug_elasticsearch_users'

    settings  do
      mapping dynamic: 'false' do
        indexes :id, type: :string, index: :not_analyzed # NOTE: indexed as a string!
        indexes :email, type: :string
        indexes :name, type: :string

        indexes :updated_at, type: :date, index: :no
        indexes :created_at, type: :date, index: :no

        indexes :quote_type, type: :string, index: :not_analyzed # NOTE: indexed as a string!
        # indexed :quote, type: :string

        indexes :quote,
          type: :string,
          analyzer: 'english',
          fields: {
            raw: {
              type: :string,
              analyzer: 'english'
            },
            stemmed: {
              type: :string,
              analyzer: 'english'
            }
          }

        indexes :suggest,
          type: :completion,
          analyzer: :simple,
          search_analyzer: :simple,
          payloads: true
      end
    end

    after_create -> { self.__elasticsearch__.index_document }

    after_update -> { self.__elasticsearch__.update_document }

    after_destroy -> { self.__elasticsearch__.delete_document }
  end

  def as_indexed_json(options={})
    {
      suggest: {
        input: self.name.split(/\s+/) + [self.email],
        output: "#{self.name} (#{self.email})",
        payload: {
          user_id: self.id, # not used, just for example
          email: self.email
        }
      }
    }.as_json.merge(self.as_json)
  end

  class_methods do

  end
end
