class RitualPlayer < ActiveRecord::Base
  belongs_to :ritual_game
  belongs_to :ritual
  
  validates :uuid, presence: true
  validates :name, presence: true
end
