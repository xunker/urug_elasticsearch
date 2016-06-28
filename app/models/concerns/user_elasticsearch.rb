require 'active_support/concern'

module UserElasticsearch
  extend ActiveSupport::Concern

  included do
    key :email, String
    key :first_name, String
    key :last_name, String
    key :quote, String

    index_name 'urug_elasticsearch'

    settings analysis: {
      filter: {
        english_possessive_stemmer: {
          type: "stemmer",
          language: "possessive_english"
        },
        english_stop: {
          type: "stop",
          stopwords: "_english_"
        },
        english_stemmer: {
          type: "stemmer",
          language: "english"
        },
        exclude_short_words: {
          type: :length,
          min: 3
        }
      },
      analyzer: {
        english: {
          tokenizer: "standard",
          filter: [
            'english_possessive_stemmer',
            'lowercase',
            'english_stop',
            'english_stemmer',
            'exclude_short_words'
          ]
        }
      }
    }

    mapping do
      indexes :email, type: :string
      indexes :name, type: :string
      indexes :user_type, type: :not_analyzed

      indexes :quote,
        type: :string,
        analyzer: 'english',
        fields: {
          raw: {
            type: :string,
            analyzer: 'keyword_lowercase'
          },
          stemmed: {
            type: :string,
            analyzer: 'english'
          }
        }

      indexes :id, type: :integer
    end
  end

  class_methods do
    
  end
end