class SearchController < ApplicationController
  def index
    users = []

    if params[:q].present?
      users = User.search(
        query: {
          multi_match: {
            query: params[:q],
            fields: ['id^10', 'name^2','email^5', :quote, :quote_type]
          }
        }
      )
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
