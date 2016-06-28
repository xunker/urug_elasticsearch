class User < ActiveRecord::Base
  #include UserElasticsearch
  validates_presence_of :email, :name
  validates_uniqueness_of :email
end
