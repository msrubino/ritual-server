class RitualGame < ActiveRecord::Base
  has_many :rituals
  has_one :leader, class_name: 'RitualPlayer', foreign_key: 'leader_id'
  has_many :ritual_players

  validates :last_leader_at_ritual_number, presence: true, numericality: {greater_than_or_equal_to: 0}

  def lapseSeconds
    return 15.seconds
  end

  def hasLeader?
    return !leader.nil?
  end

  def newLeader
    self.leader = self.ritual_players.sample()
    self.last_leader_at_ritual_number = Ritual.count
    if self.ritual_players.count > 1
      self.setLeaderLapseTimeNow
    end
  end

  def setLeaderLapseTimeNow
    self.leader_lapse_time = Time.current + self.lapseSeconds
  end

  def setLeaderLapseTime(time)
    self.leader_lapse_time = time
  end

  def updateLeader
    numRitualsPerLeader = 3
    numRitualsPerformed = Ritual.count

    leaderIsDoneLeading = numRitualsPerformed % numRitualsPerLeader == 0
    leaderHasNotChanged = self.last_leader_at_ritual_number != numRitualsPerformed

    if leaderIsDoneLeading and leaderHasNotChanged
      self.newLeader
    end

    self.save!
  end

  def exportJSON()
    return self.to_json( :include => [{:rituals => { :include => :ritual_responses } }, :leader, :ritual_players] )
  end
end
