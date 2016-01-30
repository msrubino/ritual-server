class RitualResponse < ActiveRecord::Base
  belongs_to :ritual_player
  belongs_to :ritual

  validates :response_time, presence: true, numericality: {greater_than: 0}
end
