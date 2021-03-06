class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :value, :user, :votable_id, :votable_type, presence: true
  validates :value, inclusion: [1, -1]
  validates :votable_type, inclusion: ['Question', 'Answer']
end