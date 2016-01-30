class RitualGame < ActiveRecord::Base
  has_many :rituals
  has_one :leader, class_name: 'RitualPlayer', foreign_key: 'leader_id'
  has_many :ritual_players

  def hasLeader?
    return !leader.nil?
  end

  def exportJSON()
    return self.to_json( :include => [{:rituals => { :include => :ritual_responses } }, :leader, :ritual_players] )
  end
end
