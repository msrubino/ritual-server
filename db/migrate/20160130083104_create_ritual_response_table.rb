class CreateRitualResponseTable < ActiveRecord::Migration
  def change
    create_table :ritual_response do |t|
      t.float :response_time, null: false

      t.references :ritual_player
      t.references :ritual

      t.foreign_key :ritual_players
      t.foreign_key :rituals

      t.index :response_time
    end
  end
end
