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

ActiveRecord::Schema.define(version: 20160106232929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "images", force: :cascade do |t|
    t.string   "titre"
    t.string   "file_icon"
    t.string   "file_preview"
    t.string   "file_normal"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "email"
    t.string   "title"
    t.string   "content"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", force: :cascade do |t|
    t.string   "titre"
    t.string   "content"
    t.string   "date"
    t.boolean  "actif"
    t.string   "color"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "folder_hash"
    t.integer  "icon_id"
    t.string   "meta_keywords"
    t.integer  "order"
    t.text     "sha1"
  end

end
