class RitualPlayer < ActiveRecord::Base
  belongs_to :ritual_game
  
  validates :uuid, presence: true
  validates :name, presence: true
end
