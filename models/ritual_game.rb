class RitualGame < ActiveRecord::Base
  has_one :leader, class_name: 'RitualPlayer', foreign_key: 'ritual_player_id'
  has_many :ritual_players, foreign_key: 'ritual_player_id' 
  has_one :ritual, foreign_key: 'ritual_id'
