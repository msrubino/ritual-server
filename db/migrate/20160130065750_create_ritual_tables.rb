class CreateRitualTables < ActiveRecord::Migration
  def change
    create_table :ritual_games do |t|
      t.timestamps
    end

    create_table :rituals do |t|
      t.integer :ritual_type, null: false
      t.float :duration, null: false
      t.string :gesture_string
      t.datetime :starts_at, null: false
      t.timestamps

      t.references :ritual_game
      t.foreign_key :ritual_games, on_delete: :cascade

      t.index :starts_at
    end

    create_table :ritual_players do |t|
      t.string :uuid, null: false
      t.string :name, null: false

      t.references :ritual_game
      t.foreign_key :ritual_games, on_delete: :cascade

      t.references :ritual
      t.foreign_key :rituals

      t.integer :leader_id

      t.index :uuid, unique: true
    end

    add_reference :rituals, :ritual_leader, references: :ritual_player
    add_foreign_key :rituals, :ritual_players, column: :ritual_leader_id

    create_table :ritual_responses do |t|
      t.float :response_time, null: false
      t.timestamps

      t.references :ritual_player
      t.references :ritual

      t.foreign_key :ritual_players, on_delete: :cascade
      t.foreign_key :rituals, on_delete: :cascade

      t.index :response_time
    end
  end
end
