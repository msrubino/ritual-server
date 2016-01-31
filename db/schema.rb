# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160131091443) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "players", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ritual_games", force: :cascade do |t|
    t.datetime "leader_lapse_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_leader_at_ritual_number", default: 0, null: false
  end

  create_table "ritual_players", force: :cascade do |t|
    t.string  "uuid",           null: false
    t.string  "name",           null: false
    t.integer "ritual_game_id"
    t.integer "ritual_id"
    t.integer "leader_id"
  end

  add_index "ritual_players", ["uuid"], name: "index_ritual_players_on_uuid", unique: true, using: :btree

  create_table "ritual_responses", force: :cascade do |t|
    t.float    "response_time",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ritual_player_id"
    t.integer  "ritual_id"
  end

  add_index "ritual_responses", ["response_time"], name: "index_ritual_responses_on_response_time", using: :btree

  create_table "rituals", force: :cascade do |t|
    t.integer  "ritual_type",      null: false
    t.float    "duration",         null: false
    t.datetime "starts_at",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ritual_game_id"
    t.integer  "ritual_leader_id"
  end

  add_index "rituals", ["starts_at"], name: "index_rituals_on_starts_at", using: :btree

  add_foreign_key "ritual_players", "ritual_games", on_delete: :cascade
  add_foreign_key "ritual_players", "rituals"
  add_foreign_key "ritual_responses", "ritual_players"
  add_foreign_key "ritual_responses", "rituals"
  add_foreign_key "rituals", "ritual_games", on_delete: :cascade
  add_foreign_key "rituals", "ritual_players", column: "ritual_leader_id"
end
