class Role < ActiveRecord::Base
  has_many :users, :through => :assignments
  has_many :assignments, :dependent => :nullify
end
