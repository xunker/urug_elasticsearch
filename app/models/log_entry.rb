require 'elasticsearch/model'
require 'elasticsearch/persistence/model'
class LogEntry
  include Elasticsearch::Model
  include Elasticsearch::Persistence::Model

  attribute :remote_ip, String, mapping: { index: 'not_analyzed' } # IP of the caller
  attribute :path, String # path called on local server
  attribute :request_type, String, mapping: { index: 'not_analyzed' } # search or suggest
  attribute :term, String # term, search or suggest, that was searched for
  attribute :params, Hash, mapping: { index: 'not_analyzed' } # all the query params
  attribute :request_method, String, default: 'GET', mapping: { index: 'not_analyzed' } # method of request
  attribute :content_type, String, default: nil, mapping: { index: 'not_analyzed' }
  attribute :accepts, String, default: nil, mapping: { index: 'not_analyzed' }
  attribute :request, String, default: nil # what they sent us, if anything
  attribute :response, String # what we sent back
  attribute :env, Hash, mapping: { index: 'not_analyzed' } # the env vars just in case we need them
        
  validates :created_at, presence: true
  validates :remote_ip, presence: true
  validates :path, presence: true
  validates :request_method, presence: true
  validates :response, presence: true

  before_save :set_request_type, :set_term

  # for kaminari paging
  def self.default_per_page
    25
  end

  # .oldest/.newest are kind of like .first/.last, but Elasticsearch::Model
  # doesn't have those methods since elasticsearch documents have no implicit
  # order. Instead we have these methods based on #created_at timestamp.
  def self.oldest
    search({ sort: [ { created_at: :asc } ], size: 1 }).first
  end

  def self.newest
    search({ sort: [ { created_at: :desc } ], size: 1 }).first
  end

  def search?
    request_type == 'search'
  end

  # parse the `results_meta` portion of the response and return the total
  def total_results
    get_total_from_meta(:results)
  end

  # parse the `highlights_meta` portion of the response and return the total
  def total_highlights
    get_total_from_meta(:highlights)
  end

private

  # If this was a search request, and given a response with a block like:
  #
  # {
  #   "search":{
  #    "highlights_meta":{ // or "results_meta":{
  #       "page":0,
  #       "last_page":0,
  #       "total":50
  #     }
  #   }
  # }
  #
  # ..return the "total" field; if not present, return zero.
  # If it's not a search (it's a suggest or something), return nil.
  def get_total_from_meta(return_type)
    return unless search?
    total = parsed_response
      .try(:[], 'search')
      .try(:[], "#{return_type}_meta")
      .try(:[], 'total')
    total || 0
  end

  # parse response from json into a hash
  def parsed_response
    return @parsed_response if @parsed_response
    return {} if response.blank?
    @parsed_response = JSON.parse(response)
  end

  def set_request_type
    return true if self.request_type.present?
    self.request_type = if path =~ /^\/search\/searches\/suggest/
      'suggest'
    elsif path =~ /^\/search\/searches/
      'search'
    else
      'unknown'
    end
    return true
  end

  def set_term
    case self.request_type
    when 'search'
      self.term = self.params.try(:[], 'term')
    when 'suggest'
      self.term = self.params.try(:[], 'q')
    end
    true
  end

end

# Notes to self:
# How to order a query: 
#puts ApiLog.search(query:{sort:[{created_at: :asc}]).map(&:created_at).map(&:to_s).
# Won't work with .find_each, only .search.
#
# ApiClient.search query: { match: { path: '/search/searches' } },
#                          aggregations: {  authors: { terms: { field: 'author.raw' } } },
#                          highlight: { fields: { title: {} } }
#
# GET http://localhost:9200/api_logs/_search?pretty
# {
#     "query" : {
#         "filtered" : {
#             "filter" : {
#                 "range" : {
#                     "timestamp" : {
#                         "gt" : "now-1h"
#                     }
#                 }
#             }
#         }
#     }
# }
#
# Pagination:
#puts ApiLog.search(sort:[{created_at: :desc}], size: 1, from: 0).map(&:created_at).map(&:to_s)