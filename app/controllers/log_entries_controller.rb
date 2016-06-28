class LogEntriesController < ApplicationController
  before_action :set_default_request_type, only: [:create, :index]

  def index
    render locals: {
      log_entries: search_handle.page(page).results
    }
  end

  def oldest_date
    @oldest_date ||= LogEntry.oldest.created_at.to_date
  end
  helper_method :oldest_date

  def newest_date
    @newest_date ||= LogEntry.newest.created_at.to_date
  end
  helper_method :newest_date

private

  def search_handle
    return @search_handle if @search_handle

    # the logic of search_desc is: if the user requested any king of filtering
    # then build a search request with those filters. Otherwise, send a
    # `match_all` query.
    search_desc = Jbuilder.encode do |json|
      json.sort do
        json.array!([ { created_at: :desc } ])
      end
      json.query do
        json.match_all {}
      end
    end

    Rails.logger.debug "LogEntry query: #{search_desc}"

    @search_handle = LogEntry.search(search_desc)
  end

  def page
    params[:page].to_i
  end

  def set_default_request_type
    # Don't use #blank? because we need to let the field be an empty string,
    # which means show all types; only set :request_type if it is nil.
    params[:request_type] ||= 'search'
  end
end
