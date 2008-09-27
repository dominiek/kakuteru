# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080916093733) do

  create_table "links", :force => true do |t|
    t.integer  "post_id"
    t.string   "caption"
    t.string   "url"
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "medias", :force => true do |t|
    t.integer  "post_id"
    t.string   "caption"
    t.string   "url"
    t.string   "thumbnail_url"
    t.string   "embed_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "stream_id"
    t.integer  "service_id"
    t.string   "identifier"
    t.string   "caption"
    t.string   "permalink"
    t.string   "markup"
    t.text     "body"
    t.text     "summary"
    t.datetime "published_at"
    t.boolean  "is_deleted",   :default => false, :null => false
    t.boolean  "is_draft",     :default => false, :null => false
    t.boolean  "is_votable",   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.integer  "stream_id"
    t.string   "name"
    t.string   "identifier"
    t.string   "icon_url"
    t.string   "profile_url"
    t.string   "profile_image_url"
    t.boolean  "is_enabled",        :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streams", :force => true do |t|
    t.string   "password"
    t.string   "blog_url"
    t.string   "title"
    t.string   "subtitle"
    t.string   "author"
    t.string   "friendfeed_url"
    t.string   "feedburner_feed_url"
    t.string   "addthis_username"
    t.string   "disqus_forum_identifier"
    t.boolean  "filter_message_without_space"
    t.string   "filter_tag"
    t.string   "default_markdown"
    t.string   "about"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
