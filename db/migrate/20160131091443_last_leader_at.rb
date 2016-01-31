class LastLeaderAt < ActiveRecord::Migration
  def change
    add_column :ritual_games, :last_leader_at_ritual_number, :integer, { null: false, default: 0 }
  end
end
