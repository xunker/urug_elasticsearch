class SearchController < ApplicationController
  respond_to :json, only: :suggest
  respond_to :html, only: :index

  def index
    users = User.search(
      query: {
        multi_match: {
          query: params[:q],
          fields: ['name^10','email^2','user_id', 'quote', :user_type]
        }
      }
    )

    respond_to do |format|
      format.any { render locals: { users: users } }
    end

  end

  def suggest
    respond_to do |format|
      format.any { render json: Suggester.new(params) }
    end
  end
end
