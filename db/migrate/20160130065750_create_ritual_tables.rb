class CreateRitualTables < ActiveRecord::Migration
  def change
    create_table :ritual_games do |t|
      t.timestamps
    end

    create_table :rituals do |t|
      t.integer :ritual_type, null: false
      t.float :duration, null: false
      t.datetime :starts_at, null: false

      t.references :ritual_game
      t.foreign_key :ritual_games, on_delete: :cascade

      t.index :starts_at
    end

    create_table :ritual_players do |t|
      t.string :uuid, null: false
      t.string :name, null: false

      t.references :ritual_game
      t.foreign_key :ritual_games, on_delete: :cascade

      t.integer :leader_id

      t.index :uuid, unique: true
    end

    create_table :ritual_responses do |t|
      t.float :response_time, null: false
      t.timestamps
    end
  end
end
