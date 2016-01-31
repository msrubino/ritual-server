class Ritual < ActiveRecord::Base
  belongs_to  :ritual_game
  belongs_to  :ritual_leader, class_name: "RitualPlayer"
  
  has_many    :ritual_players
  has_many    :ritual_responses
  
  validates :ritual_type, presence: true
  validates :duration, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :starts_at, presence: true

  def hasExpired?
    expirationTime = self.starts_at + self.duration.seconds
    return Time.current > expirationTime
  end
end
