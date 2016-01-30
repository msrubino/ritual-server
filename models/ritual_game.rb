class RitualGame < ActiveRecord::Base
  has_many :rituals
  has_one :leader, class_name: 'RitualPlayer', foreign_key: 'leader_id'
  has_many :ritual_players

  validates :last_leader_at_ritual_number, presence: true, numericality: {greater_than_or_equal_to: 0}

  def hasLeader?
    return !leader.nil?
  end

  def updateLeader
    numRitualsPerLeader = 3
    numRitualsPerformed = Ritual.count

    leaderIsDoneLeading = numRitualsPerformed % numRitualsPerLeader == 0
    leaderHasNotChanged = last_leader_at_ritual_number != numRitualsPerformed

    if leaderIsDoneLeading and leaderHasNotChanged
      self.leader = ritual_players.sample()
      self.last_leader_at_ritual_number = numRitualsPerformed
    end

    save!
  end

  def exportJSON()
    return self.to_json( :include => [{:rituals => { :include => :ritual_responses } }, :leader, :ritual_players] )
  end
end
