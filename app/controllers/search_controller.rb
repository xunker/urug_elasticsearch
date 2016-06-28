class SearchController < ApplicationController
  def index
    users = []

    if (query = params[:q].to_s.dup).present?
      fields = [:id, 'name^2','email^5', :quote, :quote_type]

      if query =~ /([a-z]+\:)/
        # look for or custom query language
        fields = []
        while matches = query.match(/([a-z]+\:)/) do
          fields << matches[1].sub(':', '')
          query.gsub!(matches[1], '')
        end
      end

      users = User.search(
        query: {
          multi_match: {
            query: query,
            fields: fields
          }
        }
      ).page(params[:page].to_i)
    end

    respond_to do |format|
      format.any { render locals: { users: users } }
    end

  end

  def suggest
    suggestions_response = User.__elasticsearch__.client.suggest(
      index: User.index_name,
      body: {
        suggestions: {
          text: params[:term],
          completion: {
            field: 'suggest'
          }
        }
      }
    )

    suggestion_json = suggestions_response['suggestions']
      .first['options']
      .map{|suggestion|
        { label: suggestion['text'], value: suggestion['payload']['email'] }
      }

    respond_to do |format|
      format.any { render json: suggestion_json }
    end
  end
end
