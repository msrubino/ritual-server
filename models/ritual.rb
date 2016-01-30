class Ritual < ActiveRecord::Base
  belongs_to  :ritual_game
  has_many    :ritual_players
  has_many    :ritual_responses
  
  validates :ritual_type, presence: true
  validates :duration, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :starts_at, presence: true

  def hasExpired?
    expirationTime = :starts_at + :duration
    return Time.now > expirationTime
  end
end
