require 'elasticsearch/model'
require 'elasticsearch/persistence/model'
class LogEntry
  include Elasticsearch::Model
  include Elasticsearch::Persistence::Model

  attribute :remote_ip, String, mapping: { index: 'not_analyzed' }                      # IP of the caller
  attribute :path, String                                                               # path called on local server
  attribute :params, Hash, mapping: { index: 'not_analyzed' }                           # all the query params
  attribute :request_method, String, default: 'GET', mapping: { index: 'not_analyzed' } # method of request
  attribute :content_type, String, default: nil, mapping: { index: 'not_analyzed' }     # type of the content they sent
  attribute :accepts, String, default: nil, mapping: { index: 'not_analyzed' }          # content types they accept

  validates :created_at, presence: true
  validates :remote_ip, presence: true
  validates :path, presence: true
  validates :request_method, presence: true

  # for kaminari paging
  def self.default_per_page
    5
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
end
