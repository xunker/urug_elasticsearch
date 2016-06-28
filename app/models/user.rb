class User < ActiveRecord::Base
  include UserElasticsearch
  validates_presence_of :email, :name
  validates_uniqueness_of :email
  validates_inclusion_of :quote_type, in: [0, 1, 2]

  # for kaminari paging
  def self.default_per_page
    5
  end

end
