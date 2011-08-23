# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 40) do

  create_table "action_logs", :force => true do |t|
    t.column "user_id", :integer
    t.column "session_id", :string
    t.column "request_uri", :string
    t.column "remote_ip", :string
    t.column "action_uri", :string
    t.column "created_date", :integer
    t.column "created_at", :datetime
  end

  add_index "action_logs", ["user_id"], :name => "ix_action_logs_user"
  add_index "action_logs", ["created_date"], :name => "ix_action_logs_created_date"

  create_table "avatas", :force => true do |t|
    t.column "user_id", :integer
    t.column "group_id", :integer
    t.column "model_id", :integer
    t.column "makeup_id", :integer
    t.column "photographer_id", :integer
    t.column "enterprise_id", :integer
  end

  add_index "avatas", ["user_id"], :name => "avatas_1ix", :unique => true
  add_index "avatas", ["model_id"], :name => "avatas_2ix", :unique => true
  add_index "avatas", ["enterprise_id"], :name => "avatas_3ix", :unique => true
  add_index "avatas", ["group_id"], :name => "avatas_4ix", :unique => true
  add_index "avatas", ["makeup_id"], :name => "avatas_5ix", :unique => true
  add_index "avatas", ["photographer_id"], :name => "avatas_6ix", :unique => true

  create_table "blocked_ips", :force => true do |t|
    t.column "created_at", :datetime, :null => false
    t.column "updated_at", :datetime, :null => false
    t.column "ip", :string, :limit => 20, :default => "", :null => false
  end

  add_index "blocked_ips", ["ip"], :name => "blocked_ips_1uq", :unique => true

  create_table "comments", :force => true do |t|
    t.column "model_id", :integer
    t.column "user_id", :integer
    t.column "text", :text
    t.column "created_at", :datetime
  end

  add_index "comments", ["model_id"], :name => "comments_1ix"

  create_table "consts", :force => true do |t|
    t.column "table_name", :string
    t.column "field_name", :string
    t.column "field_value", :string
    t.column "text_name", :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "consts", ["field_value"], :name => "consts_1ix"
  add_index "consts", ["table_name", "field_name"], :name => "consts_2ix"

  create_table "emails", :force => true do |t|
    t.column "from", :string
    t.column "to", :string
    t.column "last_send_attempt", :integer, :default => 0
    t.column "mail", :text
    t.column "status", :integer, :limit => 1, :default => 1
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
    t.column "created_date", :integer
  end

  create_table "enterprises", :force => true do |t|
    t.column "name", :string
    t.column "user_id", :integer
    t.column "office", :string
    t.column "zip", :integer
    t.column "fax", :string
    t.column "site", :string
    t.column "number", :integer
    t.column "description", :text
    t.column "status", :string, :default => "0"
    t.column "created_at", :datetime
  end

  create_table "favs", :force => true do |t|
    t.column "user_id", :integer
    t.column "friend_id", :integer
    t.column "remark", :text
    t.column "created_at", :datetime
  end

  create_table "groups", :force => true do |t|
    t.column "model_id", :integer
    t.column "photographer_id", :integer
    t.column "makeup_id", :integer
    t.column "name", :string
    t.column "description", :text
    t.column "admin", :integer
    t.column "member_count", :integer, :default => 1
    t.column "topic_count", :integer, :default => 0
    t.column "post_count", :integer, :default => 0
    t.column "status", :string, :limit => 1
    t.column "created_at", :datetime
  end

  create_table "invites", :force => true do |t|
    t.column "user_id", :integer, :default => 0, :null => false
    t.column "code", :string, :default => "", :null => false
    t.column "created_at", :datetime
  end

  add_index "invites", ["user_id"], :name => "ix_invites_user"

  create_table "jobs", :force => true do |t|
    t.column "work", :string
    t.column "number", :integer
    t.column "worked_at", :datetime
    t.column "address", :string
    t.column "salary", :string
    t.column "content", :text
    t.column "user_id", :integer
    t.column "status", :string, :limit => 1
    t.column "user_count", :integer, :default => 0
    t.column "created_at", :datetime
    t.column "finished_at", :datetime
  end

  create_table "links", :force => true do |t|
    t.column "category", :string
    t.column "name", :string
    t.column "url", :string
    t.column "img", :string
    t.column "tel", :string
    t.column "im", :string
    t.column "email", :string
    t.column "in_count", :integer, :default => 0
    t.column "out_count", :integer, :default => 0
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "login_logs", :force => true do |t|
    t.column "user_id", :integer
    t.column "session_id", :string
    t.column "remote_ip", :string
    t.column "owner_type", :string
    t.column "owner_id", :integer
    t.column "created_date", :integer
    t.column "created_at", :datetime
  end

  add_index "login_logs", ["user_id"], :name => "ix_login_logs_user"
  add_index "login_logs", ["owner_type", "owner_id"], :name => "ix_login_logs_owner"
  add_index "login_logs", ["created_date"], :name => "ix_login_logs_created_date"

  create_table "makeup_pictures", :force => true do |t|
    t.column "makeup_id", :integer, :default => 0, :null => false
    t.column "picture_id", :integer, :default => 0, :null => false
    t.column "name", :string
    t.column "position", :integer
    t.column "display", :boolean
    t.column "deleted", :boolean
    t.column "created_at", :datetime
  end

  add_index "makeup_pictures", ["makeup_id", "created_at"], :name => "mp_1ix"
  add_index "makeup_pictures", ["makeup_id", "position"], :name => "mp_2ix"

  create_table "makeups", :force => true do |t|
    t.column "user_id", :integer
    t.column "name", :string, :limit => 80
    t.column "sex", :string, :limit => 1
    t.column "birthday", :date
    t.column "province", :string
    t.column "city", :string
    t.column "description", :text
    t.column "pictures_count", :integer, :default => 0
    t.column "worktime", :date
    t.column "category", :string
    t.column "read_count", :integer, :default => 0
    t.column "comments_count", :integer, :default => 0
    t.column "rank_count", :integer, :default => 0
    t.column "rank", :integer, :default => 0
    t.column "created_at", :datetime
    t.column "status", :string, :limit => 1, :default => "0"
  end

  add_index "makeups", ["user_id"], :name => "models_1ix"

  create_table "members", :force => true do |t|
    t.column "group_id", :integer
    t.column "user_id", :integer
    t.column "status", :string, :limit => 1
    t.column "created_at", :datetime
  end

  create_table "messages", :force => true do |t|
    t.column "title", :string
    t.column "content", :text
    t.column "send_id", :integer
    t.column "send_name", :string
    t.column "status", :boolean, :default => false
    t.column "user_id", :integer
    t.column "receive_name", :string
    t.column "reply", :boolean
    t.column "created_at", :datetime
  end

  create_table "model_pictures", :force => true do |t|
    t.column "model_id", :integer, :default => 0, :null => false
    t.column "picture_id", :integer, :default => 0, :null => false
    t.column "name", :string
    t.column "position", :integer
    t.column "display", :boolean
    t.column "deleted", :boolean
    t.column "created_at", :datetime
  end

  add_index "model_pictures", ["model_id", "created_at"], :name => "mp_1ix"
  add_index "model_pictures", ["model_id", "position"], :name => "mp_2ix"

  create_table "models", :force => true do |t|
    t.column "user_id", :integer
    t.column "name", :string, :limit => 80
    t.column "sex", :string, :limit => 1
    t.column "birthday", :date
    t.column "country", :string, :limit => 20
    t.column "province", :string
    t.column "city", :string
    t.column "weight", :integer
    t.column "height", :integer
    t.column "eye", :string, :limit => 20
    t.column "shoes", :integer
    t.column "chest", :integer
    t.column "waist", :integer
    t.column "hips", :integer
    t.column "in_china", :date
    t.column "description", :text
    t.column "remark", :text
    t.column "pictures_count", :integer, :default => 0
    t.column "worktime", :date
    t.column "category", :string
    t.column "read_count", :integer, :default => 0
    t.column "comments_count", :integer, :default => 0
    t.column "rank_count", :integer, :default => 0
    t.column "rank", :integer, :default => 0
    t.column "created_at", :datetime
    t.column "status", :string, :limit => 1, :default => "0"
    t.column "updated_at", :datetime
  end

  add_index "models", ["user_id"], :name => "models_1ix"

  create_table "notices", :force => true do |t|
    t.column "controller", :string
    t.column "action", :string
    t.column "title", :string
    t.column "content", :text
    t.column "created_at", :datetime
  end

  create_table "old_images", :force => true do |t|
    t.column "name", :integer
    t.column "user_id", :integer
    t.column "created_at", :datetime
  end

  add_index "old_images", ["name"], :name => "old_images_1ix", :unique => true
  add_index "old_images", ["user_id"], :name => "old_images_2ix"

  create_table "page_contents", :force => true do |t|
    t.column "page_id", :integer
    t.column "content", :text
    t.column "content_redcloth", :text
    t.column "number", :integer
  end

  add_index "page_contents", ["page_id"], :name => "pages_1ix", :unique => true
  add_index "page_contents", ["number"], :name => "pages_2ix"

  create_table "pages", :force => true do |t|
    t.column "title", :string
    t.column "category", :string
    t.column "author", :string
    t.column "from", :string
    t.column "brief", :text
    t.column "editor", :string
    t.column "count", :integer, :limit => 12, :default => 1
    t.column "number", :integer, :default => 0
    t.column "digg", :integer, :default => 0
    t.column "published_at", :date
    t.column "published", :integer, :limit => 4, :default => 0
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
  end

  add_index "pages", ["updated_at"], :name => "pages_1ix"
  add_index "pages", ["number"], :name => "pages_2ix"
  add_index "pages", ["digg"], :name => "pages_3ix"
  add_index "pages", ["category"], :name => "pages_4ix"

  create_table "photographer_pictures", :force => true do |t|
    t.column "photographer_id", :integer, :default => 0, :null => false
    t.column "picture_id", :integer, :default => 0, :null => false
    t.column "name", :string
    t.column "position", :integer
    t.column "display", :boolean
    t.column "deleted", :boolean
    t.column "created_at", :datetime
  end

  add_index "photographer_pictures", ["photographer_id", "created_at"], :name => "mp_1ix"
  add_index "photographer_pictures", ["photographer_id", "position"], :name => "mp_2ix"

  create_table "photographers", :force => true do |t|
    t.column "user_id", :integer
    t.column "name", :string, :limit => 80
    t.column "sex", :string, :limit => 1
    t.column "birthday", :date
    t.column "province", :string
    t.column "city", :string
    t.column "description", :text
    t.column "remark", :text
    t.column "pictures_count", :integer, :default => 0
    t.column "worktime", :date
    t.column "read_count", :integer, :default => 0
    t.column "comments_count", :integer, :default => 0
    t.column "rank_count", :integer, :default => 0
    t.column "rank", :integer, :default => 0
    t.column "created_at", :datetime
    t.column "status", :string, :limit => 1, :default => "0"
  end

  add_index "photographers", ["user_id"], :name => "models_1ix"

  create_table "pictures", :force => true do |t|
  end

  create_table "posts", :force => true do |t|
    t.column "user_id", :integer
    t.column "topic_id", :integer
    t.column "parent_id", :integer
    t.column "deleted", :boolean, :default => false
    t.column "content", :text
    t.column "created_at", :datetime
  end

  add_index "posts", ["user_id"], :name => "posts_1ix"

  create_table "referral_forums", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
    t.column "url", :string, :default => "", :null => false
    t.column "created_at", :datetime, :null => false
  end

  add_index "referral_forums", ["name"], :name => "ix_referral_forums_name"

  create_table "referral_stats", :force => true do |t|
    t.column "referral_id", :integer
    t.column "today_visit_count", :integer
    t.column "total_visit_count", :integer
    t.column "today_regist_count", :integer
    t.column "total_regist_count", :integer
    t.column "stat_date", :integer
    t.column "created_at", :datetime
  end

  create_table "referral_users", :force => true do |t|
    t.column "name", :string
    t.column "user_id", :integer
    t.column "email", :string
    t.column "created_at", :datetime
  end

  create_table "referrals", :force => true do |t|
    t.column "referral_user_id", :integer, :default => 0, :null => false
    t.column "referral_forum_id", :integer
    t.column "code", :string, :default => "", :null => false
    t.column "created_at", :datetime
  end

  add_index "referrals", ["referral_user_id"], :name => "ix_referrals_user"

  create_table "taggings", :force => true do |t|
    t.column "taggable_id", :integer
    t.column "tag_id", :integer
    t.column "taggable_type", :string
  end

  create_table "tags", :force => true do |t|
    t.column "name", :string
  end

  create_table "topics", :force => true do |t|
    t.column "group_id", :integer
    t.column "user_id", :integer
    t.column "title", :string
    t.column "read_count", :integer, :default => 0
    t.column "post_count", :integer, :default => 0
    t.column "last_reply", :datetime
    t.column "deleted", :boolean, :default => false
    t.column "status", :integer, :limit => 1, :default => 0
    t.column "created_at", :datetime
  end

  add_index "topics", ["group_id"], :name => "topics_1ix"
  add_index "topics", ["user_id"], :name => "topics_2ix"
  add_index "topics", ["created_at"], :name => "topics_3ix"
  add_index "topics", ["status"], :name => "topics_4ix"

  create_table "trades", :force => true do |t|
    t.column "job_id", :integer
    t.column "user_id", :integer
    t.column "status", :string, :limit => 1
    t.column "remark", :text
    t.column "created_at", :datetime
  end

  create_table "users", :force => true do |t|
    t.column "category", :integer, :limit => 1
    t.column "name", :string
    t.column "hashed_password", :string
    t.column "email", :string
    t.column "salt", :string
    t.column "phone", :integer, :limit => 20
    t.column "mobile", :integer, :limit => 20
    t.column "msn", :string
    t.column "qq", :integer, :limit => 20
    t.column "role", :string, :limit => 11
    t.column "hide", :boolean, :default => true
    t.column "remember_token_expires", :datetime
    t.column "remember_token", :string
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
    t.column "last_login", :datetime
    t.column "last_ip", :string
    t.column "login_times", :integer, :default => 0
    t.column "source", :integer
    t.column "source_detail", :string
    t.column "status", :integer, :limit => 1, :default => 1
    t.column "privacy", :boolean, :default => false
    t.column "has_avatar", :boolean, :default => false
    t.column "created_date", :integer
  end

  add_index "users", ["name"], :name => "users_1ix", :unique => true
  add_index "users", ["email"], :name => "users_2ix", :unique => true
  add_index "users", ["created_date"], :name => "ix_users_created_date"

  create_table "webs", :force => true do |t|
    t.column "title", :string
    t.column "content", :text
    t.column "url", :string
    t.column "number", :integer
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
  end

end
