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

ActiveRecord::Schema.define(version: 20150329145800) do

  create_table "basket_items", force: true do |t|
    t.string   "term"
    t.text     "comment"
    t.boolean  "archived",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: true do |t|
    t.string   "sourceid"
    t.integer  "internalid"
    t.string   "title"
    t.text     "resultlines"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents_queryterms", id: false, force: true do |t|
    t.integer "document_id"
    t.integer "queryterm_id"
  end

  add_index "documents_queryterms", ["document_id"], name: "index_documents_queryterms_on_document_id"
  add_index "documents_queryterms", ["queryterm_id"], name: "index_documents_queryterms_on_queryterm_id"

  create_table "queryterms", force: true do |t|
    t.integer  "senseid"
    t.string   "sense"
    t.string   "term"
    t.integer  "termnum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searchresults", force: true do |t|
    t.integer  "workset_id"
    t.integer  "document_id"
    t.datetime "date"
    t.boolean  "selected"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searchresults", ["document_id"], name: "index_searchresults_on_document_id"
  add_index "searchresults", ["workset_id"], name: "index_searchresults_on_workset_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_worksets", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "workset_id"
  end

  add_index "users_worksets", ["user_id"], name: "index_users_worksets_on_user_id"
  add_index "users_worksets", ["workset_id"], name: "index_users_worksets_on_workset_id"

  create_table "worksets", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
