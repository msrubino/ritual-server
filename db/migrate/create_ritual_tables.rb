class CreateRitualTables < ActiveRecord::Migration
  def change
    create_table :rituals do |t|
      t.integer :ritual_type, null: false
      t.float :duration, null: false
      t.datetime :starts_at, null: false

      t.index :starts_at
    end

    create_table :ritual_players do |t|
      t.string :uuid, null: false
      t.string :name, null: false

      t.index :uuid, unique: true
    end

    create_table :ritual_games do |t|
      t.references :ritual_player
      t.references :ritual

      t.foreign_key :ritual_players, on_delete: :cascade
      t.foreign_key :ritual, on_delete: :cascade
    end
  end
