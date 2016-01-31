class AddLeaderLapseTime < ActiveRecord::Migration
  def change
      add_column :ritual_games, :leader_lapse_time, :datetime
  end
end
