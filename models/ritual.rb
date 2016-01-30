class Ritual < ActiveRecord::Base
  belongs_to :ritual_game
  
  validates :ritual_type, presence: true
  validates :duration, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :starts_at, presence: true
end
