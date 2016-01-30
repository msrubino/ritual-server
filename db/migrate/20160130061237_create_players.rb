class CreatePlayers < ActiveRecord::Migration
  def change
  end

  def self.up
    create_table :players do |t|
      t.name :name
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end

end
