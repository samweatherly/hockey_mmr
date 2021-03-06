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

ActiveRecord::Schema.define(version: 20160415001709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "futures", force: :cascade do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.float    "home_mmr"
    t.float    "away_mmr"
    t.date     "date"
    t.float    "expected_result"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer  "home_goals"
    t.float    "home_mmr"
    t.integer  "home_team_id"
    t.integer  "away_goals"
    t.float    "away_mmr"
    t.integer  "away_team_id"
    t.date     "date"
    t.string   "extra_time"
    t.float    "home_rating_change"
    t.float    "away_rating_change"
    t.boolean  "playoff"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "season"
    t.float    "result"
    t.float    "expected"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.float    "mmr"
    t.integer  "k_value"
    t.float    "home_mmr"
    t.float    "away_mmr"
    t.string   "logo"
    t.boolean  "active"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "total_games"
    t.string   "conference"
  end

end
