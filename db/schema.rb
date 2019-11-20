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

ActiveRecord::Schema.define(version: 2019_11_17_065923) do

  create_table "activity_streams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "activity_stream_type_id", null: false
    t.integer "activity_stream_object_id", null: false
    t.integer "permission_id"
    t.integer "group_id"
    t.integer "o_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["activity_stream_object_id"], name: "index_activity_streams_on_activity_stream_object_id"
    t.index ["activity_stream_type_id"], name: "index_activity_streams_on_activity_stream_type_id"
    t.index ["created_at"], name: "index_activity_streams_on_created_at"
    t.index ["created_by_id"], name: "index_activity_streams_on_created_by_id"
    t.index ["group_id"], name: "index_activity_streams_on_group_id"
    t.index ["o_id"], name: "index_activity_streams_on_o_id"
    t.index ["permission_id", "group_id", "created_at"], name: "index_activity_streams_on_permission_id_group_id_created_at"
    t.index ["permission_id", "group_id"], name: "index_activity_streams_on_permission_id_and_group_id"
    t.index ["permission_id"], name: "index_activity_streams_on_permission_id"
  end

  create_table "authorizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "provider", limit: 250, null: false
    t.string "uid", limit: 250, null: false
    t.string "token", limit: 2500
    t.string "secret", limit: 250
    t.string "username", limit: 250
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["uid", "provider"], name: "index_authorizations_on_uid_and_provider"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
    t.index ["username"], name: "index_authorizations_on_username"
  end

  create_table "avatars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "o_id", null: false
    t.integer "object_lookup_id", null: false
    t.boolean "default", default: false, null: false
    t.boolean "deletable", default: true, null: false
    t.boolean "initial", default: false, null: false
    t.integer "store_full_id"
    t.integer "store_resize_id"
    t.string "store_hash", limit: 32
    t.string "source", limit: 100, null: false
    t.string "source_url", limit: 512
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_7f23a117cf"
    t.index ["default"], name: "index_avatars_on_default"
    t.index ["o_id", "object_lookup_id"], name: "index_avatars_on_o_id_and_object_lookup_id"
    t.index ["source"], name: "index_avatars_on_source"
    t.index ["store_hash"], name: "index_avatars_on_store_hash"
    t.index ["updated_by_id"], name: "fk_rails_36592d9368"
  end

  create_table "calendars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250
    t.string "timezone", limit: 250
    t.string "business_hours", limit: 3000
    t.boolean "default", default: false, null: false
    t.string "ical_url", limit: 500
    t.text "public_holidays", limit: 16777215
    t.text "last_log", limit: 16777215
    t.timestamp "last_sync", precision: 3
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_2a2c81de1a"
    t.index ["name"], name: "index_calendars_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_1923375e08"
  end

  create_table "channels", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "group_id"
    t.string "area", limit: 100, null: false
    t.text "options", limit: 16777215
    t.boolean "active", default: true, null: false
    t.string "preferences", limit: 2000
    t.text "last_log_in", limit: 16777215
    t.text "last_log_out", limit: 16777215
    t.string "status_in", limit: 100
    t.string "status_out", limit: 100
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["area"], name: "index_channels_on_area"
    t.index ["created_by_id"], name: "fk_rails_f1fc2a34ff"
    t.index ["group_id"], name: "fk_rails_8011c05949"
    t.index ["updated_by_id"], name: "fk_rails_32268ed43d"
  end

  create_table "chat_agents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "concurrent", default: 5, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["active"], name: "index_chat_agents_on_active"
    t.index ["created_by_id"], name: "index_chat_agents_on_created_by_id", unique: true
    t.index ["updated_by_id"], name: "index_chat_agents_on_updated_by_id", unique: true
  end

  create_table "chat_messages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "chat_session_id", null: false
    t.text "content", limit: 4294967295, null: false
    t.integer "created_by_id"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["chat_session_id"], name: "index_chat_messages_on_chat_session_id"
    t.index ["created_by_id"], name: "fk_rails_af8ea0a844"
  end

  create_table "chat_sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.string "session_id", null: false
    t.string "name", limit: 250
    t.string "state", limit: 50, default: "waiting", null: false
    t.integer "user_id"
    t.text "preferences", limit: 16777215
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["chat_id"], name: "index_chat_sessions_on_chat_id"
    t.index ["created_by_id"], name: "fk_rails_9b5b542892"
    t.index ["session_id"], name: "index_chat_sessions_on_session_id"
    t.index ["state"], name: "index_chat_sessions_on_state"
    t.index ["updated_by_id"], name: "fk_rails_dab338cf4e"
    t.index ["user_id"], name: "index_chat_sessions_on_user_id"
  end

  create_table "chat_topics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_05113b359f"
    t.index ["name"], name: "index_chat_topics_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_aae140f2f9"
  end

  create_table "chats", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250
    t.integer "max_queue", default: 5, null: false
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.boolean "public", default: false, null: false
    t.string "block_ip", limit: 5000
    t.string "block_country", limit: 5000
    t.string "preferences", limit: 5000
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_9053a479a7"
    t.index ["name"], name: "index_chats_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_cb3fe7fa69"
  end

  create_table "cti_caller_ids", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "caller_id", limit: 100, null: false
    t.string "comment", limit: 500
    t.string "level", limit: 100, null: false
    t.string "object", limit: 100, null: false
    t.integer "o_id", null: false
    t.integer "user_id"
    t.text "preferences", limit: 16777215
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["caller_id", "level"], name: "index_cti_caller_ids_on_caller_id_and_level"
    t.index ["caller_id", "user_id"], name: "index_cti_caller_ids_on_caller_id_and_user_id"
    t.index ["caller_id"], name: "index_cti_caller_ids_on_caller_id"
    t.index ["object", "o_id", "level", "user_id", "caller_id"], name: "index_cti_caller_ids_on_object_o_id_level_user_id_caller_id"
    t.index ["object", "o_id"], name: "index_cti_caller_ids_on_object_and_o_id"
    t.index ["user_id"], name: "fk_rails_f03ef195fa"
  end

  create_table "cti_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "direction", limit: 20, null: false
    t.string "state", limit: 20, null: false
    t.string "from", limit: 100, null: false
    t.string "from_comment", limit: 250
    t.string "to", limit: 100, null: false
    t.string "to_comment", limit: 250
    t.string "queue", limit: 250
    t.string "call_id", limit: 250, null: false
    t.string "comment", limit: 500
    t.timestamp "initialized_at", precision: 3
    t.timestamp "start_at", precision: 3
    t.timestamp "end_at", precision: 3
    t.integer "duration_waiting_time"
    t.integer "duration_talking_time"
    t.boolean "done", default: true, null: false
    t.text "preferences", limit: 16777215
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["call_id"], name: "index_cti_logs_on_call_id", unique: true
    t.index ["direction"], name: "index_cti_logs_on_direction"
    t.index ["from"], name: "index_cti_logs_on_from"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "email_addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "channel_id"
    t.string "realname", limit: 250, null: false
    t.string "email", limit: 250, null: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 250
    t.string "preferences", limit: 2000
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_4f204b5369"
    t.index ["email"], name: "index_email_addresses_on_email", unique: true
    t.index ["updated_by_id"], name: "fk_rails_a24ae390cf"
  end

  create_table "external_credentials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "credentials", limit: 2500, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "external_syncs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "source", limit: 100, null: false
    t.string "source_id", limit: 200, null: false
    t.string "object", limit: 100, null: false
    t.integer "o_id", null: false
    t.text "last_payload", limit: 16777215
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["object", "o_id"], name: "index_external_syncs_on_object_and_o_id"
    t.index ["source", "source_id", "object", "o_id"], name: "index_external_syncs_on_source_and_source_id_and_object_o_id"
    t.index ["source", "source_id"], name: "index_external_syncs_on_source_and_source_id", unique: true
  end

  create_table "groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "signature_id"
    t.integer "email_address_id"
    t.string "name", limit: 160, null: false
    t.integer "assignment_timeout"
    t.string "follow_up_possible", limit: 100, default: "yes", null: false
    t.boolean "follow_up_assignment", default: true, null: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_7bec5aff4f"
    t.index ["email_address_id"], name: "fk_rails_a828c3963d"
    t.index ["name"], name: "index_groups_on_name", unique: true
    t.index ["signature_id"], name: "fk_rails_5538295cdc"
    t.index ["updated_by_id"], name: "fk_rails_55ff2495b5"
  end

  create_table "groups_macros", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "macro_id", null: false
    t.integer "group_id", null: false
    t.index ["group_id"], name: "index_groups_macros_on_group_id"
    t.index ["macro_id"], name: "index_groups_macros_on_macro_id"
  end

  create_table "groups_text_modules", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "text_module_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_groups_text_modules_on_group_id"
    t.index ["text_module_id"], name: "index_groups_text_modules_on_text_module_id"
  end

  create_table "groups_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "group_id", null: false
    t.string "access", limit: 50, default: "full", null: false
    t.index ["access"], name: "index_groups_users_on_access"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "history_type_id", null: false
    t.integer "history_object_id", null: false
    t.integer "history_attribute_id"
    t.integer "o_id", null: false
    t.integer "related_o_id"
    t.integer "related_history_object_id"
    t.integer "id_to"
    t.integer "id_from"
    t.string "value_from", limit: 500
    t.string "value_to", limit: 500
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_histories_on_created_at"
    t.index ["created_by_id"], name: "index_histories_on_created_by_id"
    t.index ["history_attribute_id"], name: "index_histories_on_history_attribute_id"
    t.index ["history_object_id"], name: "index_histories_on_history_object_id"
    t.index ["history_type_id"], name: "index_histories_on_history_type_id"
    t.index ["id_from"], name: "index_histories_on_id_from"
    t.index ["id_to"], name: "index_histories_on_id_to"
    t.index ["o_id", "history_object_id", "related_o_id"], name: "index_histories_on_o_id_and_history_object_id_and_related_o_id"
    t.index ["o_id"], name: "index_histories_on_o_id"
    t.index ["related_history_object_id"], name: "index_histories_on_related_history_object_id"
    t.index ["related_o_id"], name: "index_histories_on_related_o_id"
    t.index ["value_from"], name: "index_histories_on_value_from", length: 255
    t.index ["value_to"], name: "index_histories_on_value_to", length: 255
  end

  create_table "history_attributes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_history_attributes_on_name", unique: true
  end

  create_table "history_objects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_history_objects_on_name", unique: true
  end

  create_table "history_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_history_types_on_name", unique: true
  end

  create_table "http_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "direction", limit: 20, null: false
    t.string "facility", limit: 100, null: false
    t.string "method", limit: 100, null: false
    t.string "url", null: false
    t.string "status", limit: 20
    t.string "ip", limit: 50
    t.string "request", limit: 10000, null: false
    t.string "response", limit: 10000, null: false
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_http_logs_on_created_at"
    t.index ["created_by_id"], name: "index_http_logs_on_created_by_id"
    t.index ["facility"], name: "index_http_logs_on_facility"
    t.index ["updated_by_id"], name: "fk_rails_0a97b58d1a"
  end

  create_table "import_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.boolean "dry_run", default: false
    t.text "payload", limit: 16777215
    t.text "result", limit: 16777215
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "timeplan", limit: 2500, null: false
    t.text "condition", limit: 16777215, null: false
    t.text "perform", limit: 16777215, null: false
    t.boolean "disable_notification", default: true, null: false
    t.timestamp "last_run_at", precision: 3
    t.timestamp "next_run_at", precision: 3
    t.boolean "running", default: false, null: false
    t.integer "processed", default: 0, null: false
    t.integer "matching", null: false
    t.string "pid", limit: 250
    t.string "note", limit: 250
    t.boolean "active", default: false, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_c4f56411f8"
    t.index ["name"], name: "index_jobs_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_3e355905b6"
  end

  create_table "karma_activities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 200, null: false
    t.string "description", limit: 200, null: false
    t.integer "score", null: false
    t.integer "once_ttl", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_karma_activities_on_name", unique: true
  end

  create_table "karma_activity_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "o_id", null: false
    t.integer "object_lookup_id", null: false
    t.integer "user_id", null: false
    t.integer "activity_id", null: false
    t.integer "score", null: false
    t.integer "score_total", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["activity_id"], name: "fk_rails_0517d121f2"
    t.index ["created_at"], name: "index_karma_activity_logs_on_created_at"
    t.index ["o_id", "object_lookup_id"], name: "index_karma_activity_logs_on_o_id_and_object_lookup_id"
    t.index ["user_id"], name: "index_karma_activity_logs_on_user_id"
  end

  create_table "karma_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "score", null: false
    t.string "level", limit: 200, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["user_id"], name: "index_karma_users_on_user_id", unique: true
  end

  create_table "knowledge_base_answer_translation_contents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body", limit: 4294967295
  end

  create_table "knowledge_base_answer_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", limit: 250, null: false
    t.integer "kb_locale_id", null: false
    t.integer "answer_id", null: false
    t.integer "content_id", null: false
    t.integer "created_by_id", null: false
    t.integer "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_knowledge_base_answer_translations_on_answer_id"
    t.index ["content_id"], name: "index_knowledge_base_answer_translations_on_content_id"
    t.index ["created_by_id"], name: "index_knowledge_base_answer_translations_on_created_by_id"
    t.index ["kb_locale_id"], name: "index_knowledge_base_answer_translations_on_kb_locale_id"
    t.index ["updated_by_id"], name: "index_knowledge_base_answer_translations_on_updated_by_id"
  end

  create_table "knowledge_base_answers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id", null: false
    t.boolean "promoted", default: false, null: false
    t.text "internal_note", limit: 16777215
    t.integer "position", null: false
    t.timestamp "archived_at", precision: 3
    t.integer "archived_by_id"
    t.timestamp "internal_at", precision: 3
    t.integer "internal_by_id"
    t.timestamp "published_at", precision: 3
    t.integer "published_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_by_id"], name: "index_knowledge_base_answers_on_archived_by_id"
    t.index ["category_id"], name: "index_knowledge_base_answers_on_category_id"
    t.index ["internal_by_id"], name: "index_knowledge_base_answers_on_internal_by_id"
    t.index ["position"], name: "index_knowledge_base_answers_on_position"
    t.index ["published_by_id"], name: "index_knowledge_base_answers_on_published_by_id"
  end

  create_table "knowledge_base_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "knowledge_base_id", null: false
    t.integer "parent_id"
    t.string "category_icon", limit: 30, null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["knowledge_base_id"], name: "index_knowledge_base_categories_on_knowledge_base_id"
    t.index ["parent_id"], name: "index_knowledge_base_categories_on_parent_id"
    t.index ["position"], name: "index_knowledge_base_categories_on_position"
  end

  create_table "knowledge_base_category_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", limit: 250, null: false
    t.integer "kb_locale_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_knowledge_base_category_translations_on_category_id"
    t.index ["kb_locale_id"], name: "index_knowledge_base_category_translations_on_kb_locale_id"
  end

  create_table "knowledge_base_locales", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "knowledge_base_id", null: false
    t.integer "system_locale_id", null: false
    t.boolean "primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["knowledge_base_id"], name: "index_knowledge_base_locales_on_knowledge_base_id"
    t.index ["system_locale_id"], name: "index_knowledge_base_locales_on_system_locale_id"
  end

  create_table "knowledge_base_menu_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "kb_locale_id", null: false
    t.integer "position", null: false
    t.string "title", limit: 100, null: false
    t.string "url", limit: 500, null: false
    t.boolean "new_tab", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kb_locale_id"], name: "index_knowledge_base_menu_items_on_kb_locale_id"
    t.index ["position"], name: "index_knowledge_base_menu_items_on_position"
  end

  create_table "knowledge_base_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", limit: 250, null: false
    t.string "footer_note", null: false
    t.integer "kb_locale_id", null: false
    t.integer "knowledge_base_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kb_locale_id"], name: "index_knowledge_base_translations_on_kb_locale_id"
    t.index ["knowledge_base_id"], name: "index_knowledge_base_translations_on_knowledge_base_id"
  end

  create_table "knowledge_bases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "iconset", limit: 30, null: false
    t.string "color_highlight", limit: 9, null: false
    t.string "color_header", limit: 9, null: false
    t.string "homepage_layout", null: false
    t.string "category_layout", null: false
    t.boolean "active", default: true, null: false
    t.string "custom_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "link_objects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_link_objects_on_name", unique: true
  end

  create_table "link_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_link_types_on_name", unique: true
  end

  create_table "links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "link_type_id", null: false
    t.integer "link_object_source_id", null: false
    t.integer "link_object_source_value", null: false
    t.integer "link_object_target_id", null: false
    t.integer "link_object_target_value", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["link_object_source_id", "link_object_source_value", "link_object_target_id", "link_object_target_value", "link_type_id"], name: "links_uniq_total", unique: true
    t.index ["link_type_id"], name: "fk_rails_a578a39c28"
  end

  create_table "locales", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "locale", limit: 20, null: false
    t.string "alias", limit: 20
    t.string "name", null: false
    t.string "dir", limit: 9, default: "ltr", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["locale"], name: "index_locales_on_locale", unique: true
    t.index ["name"], name: "index_locales_on_name", unique: true
  end

  create_table "macros", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250
    t.text "perform", limit: 16777215, null: false
    t.boolean "active", default: true, null: false
    t.string "ux_flow_next_up", default: "none", null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_18961fdc52"
    t.index ["name"], name: "index_macros_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_84f97aa218"
  end

  create_table "notifications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "subject", limit: 250, null: false
    t.string "body", limit: 8000, null: false
    t.string "content_type", limit: 250, null: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 250
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "oauth_access_grants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "fk_rails_b4b53e07b8"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "fk_rails_732cb83ab7"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confidential", default: true, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "object_lookups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_object_lookups_on_name", unique: true
  end

  create_table "object_manager_attributes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "object_lookup_id", null: false
    t.string "name", limit: 200, null: false
    t.string "display", limit: 200, null: false
    t.string "data_type", limit: 100, null: false
    t.text "data_option", limit: 16777215
    t.text "data_option_new", limit: 16777215
    t.boolean "editable", default: true, null: false
    t.boolean "active", default: true, null: false
    t.string "screens", limit: 2000
    t.boolean "to_create", default: false, null: false
    t.boolean "to_migrate", default: false, null: false
    t.boolean "to_delete", default: false, null: false
    t.boolean "to_config", default: false, null: false
    t.integer "position", null: false
    t.integer "created_by_id", null: false
    t.integer "updated_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["active"], name: "index_object_manager_attributes_on_active"
    t.index ["created_by_id"], name: "fk_rails_acacd17a49"
    t.index ["object_lookup_id", "name"], name: "index_object_manager_attributes_on_object_lookup_id_and_name", unique: true
    t.index ["object_lookup_id"], name: "index_object_manager_attributes_on_object_lookup_id"
    t.index ["updated_at"], name: "index_object_manager_attributes_on_updated_at"
    t.index ["updated_by_id"], name: "fk_rails_e812039563"
  end

  create_table "online_notifications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "o_id", null: false
    t.integer "object_lookup_id", null: false
    t.integer "type_lookup_id", null: false
    t.integer "user_id", null: false
    t.boolean "seen", default: false, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_online_notifications_on_created_at"
    t.index ["created_by_id"], name: "fk_rails_0c0055c5df"
    t.index ["seen"], name: "index_online_notifications_on_seen"
    t.index ["updated_at"], name: "index_online_notifications_on_updated_at"
    t.index ["updated_by_id"], name: "fk_rails_ee155e3c0c"
    t.index ["user_id"], name: "index_online_notifications_on_user_id"
  end

  create_table "organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.boolean "shared", default: true, null: false
    t.string "domain", limit: 250, default: ""
    t.boolean "domain_assignment", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 5000, default: ""
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_edec76c076"
    t.index ["domain"], name: "index_organizations_on_domain"
    t.index ["name"], name: "index_organizations_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_6b945c40b8"
  end

  create_table "organizations_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "organization_id"
    t.index ["organization_id"], name: "index_organizations_users_on_organization_id"
    t.index ["user_id"], name: "index_organizations_users_on_user_id"
  end

  create_table "overviews", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "link", limit: 250, null: false
    t.integer "prio", null: false
    t.text "condition", limit: 16777215, null: false
    t.string "order", limit: 2500, null: false
    t.string "group_by", limit: 250
    t.string "group_direction", limit: 250
    t.boolean "organization_shared", default: false, null: false
    t.boolean "out_of_office", default: false, null: false
    t.string "view", limit: 1000, null: false
    t.boolean "active", default: true, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_a12668341b"
    t.index ["name"], name: "index_overviews_on_name"
    t.index ["updated_by_id"], name: "fk_rails_13fe2fde45"
  end

  create_table "overviews_groups", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "overview_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_overviews_groups_on_group_id"
    t.index ["overview_id"], name: "index_overviews_groups_on_overview_id"
  end

  create_table "overviews_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "overview_id"
    t.integer "role_id"
    t.index ["overview_id"], name: "index_overviews_roles_on_overview_id"
    t.index ["role_id"], name: "index_overviews_roles_on_role_id"
  end

  create_table "overviews_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "overview_id"
    t.integer "user_id"
    t.index ["overview_id"], name: "index_overviews_users_on_overview_id"
    t.index ["user_id"], name: "index_overviews_users_on_user_id"
  end

  create_table "package_migrations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "version", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
  end

  create_table "packages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "version", limit: 50, null: false
    t.string "vendor", limit: 150, null: false
    t.string "state", limit: 50, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_438d68f470"
    t.index ["updated_by_id"], name: "fk_rails_86b7b71dbf"
  end

  create_table "permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "note", limit: 500
    t.string "preferences", limit: 10000
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_permissions_on_name", unique: true
  end

  create_table "permissions_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "role_id"
    t.integer "permission_id"
    t.index ["permission_id"], name: "index_permissions_roles_on_permission_id"
    t.index ["role_id"], name: "index_permissions_roles_on_role_id"
  end

  create_table "postmaster_filters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "channel", limit: 250, null: false
    t.text "match", limit: 16777215, null: false
    t.text "perform", limit: 16777215, null: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["channel"], name: "index_postmaster_filters_on_channel"
    t.index ["created_by_id"], name: "fk_rails_99ae723fc6"
    t.index ["updated_by_id"], name: "fk_rails_4b17873e0f"
  end

  create_table "recent_views", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "recent_view_object_id", null: false
    t.integer "o_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_recent_views_on_created_at"
    t.index ["created_by_id"], name: "index_recent_views_on_created_by_id"
    t.index ["o_id"], name: "index_recent_views_on_o_id"
    t.index ["recent_view_object_id"], name: "index_recent_views_on_recent_view_object_id"
  end

  create_table "report_profiles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 150
    t.text "condition", limit: 16777215
    t.boolean "active", default: true, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_c0dbdacc53"
    t.index ["name"], name: "index_report_profiles_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_214a4c247b"
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "preferences", limit: 16777215
    t.boolean "default_at_signup", default: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_b41292c88f"
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_e85422db7e"
  end

  create_table "roles_groups", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "group_id", null: false
    t.string "access", limit: 50, default: "full", null: false
    t.index ["access"], name: "index_roles_groups_on_access"
    t.index ["group_id"], name: "index_roles_groups_on_group_id"
    t.index ["role_id"], name: "index_roles_groups_on_role_id"
  end

  create_table "roles_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "schedulers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "method", limit: 250, null: false
    t.integer "period"
    t.integer "running", default: 0, null: false
    t.timestamp "last_run", precision: 3
    t.integer "prio", null: false
    t.string "pid", limit: 250
    t.string "note", limit: 250
    t.string "error_message"
    t.string "status"
    t.boolean "active", default: false, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_e0c99c2069"
    t.index ["name"], name: "index_schedulers_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_08966259e8"
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.boolean "persistent"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["persistent"], name: "index_sessions_on_persistent"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", limit: 200, null: false
    t.string "name", limit: 200, null: false
    t.string "area", limit: 100, null: false
    t.string "description", limit: 2000, null: false
    t.string "options", limit: 2000
    t.text "state_current", limit: 16777215
    t.string "state_initial", limit: 2000
    t.boolean "frontend", null: false
    t.text "preferences", limit: 16777215
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["area"], name: "index_settings_on_area"
    t.index ["frontend"], name: "index_settings_on_frontend"
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "signatures", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "body", limit: 16777215
    t.boolean "active", default: true, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_997a237d5e"
    t.index ["name"], name: "index_signatures_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_82877eeea3"
  end

  create_table "slas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "calendar_id", null: false
    t.string "name", limit: 150
    t.integer "first_response_time"
    t.integer "update_time"
    t.integer "solution_time"
    t.text "condition", limit: 16777215
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_15319a5af4"
    t.index ["name"], name: "index_slas_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_5a768af5b2"
  end

  create_table "stats_stores", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "stats_store_object_id", null: false
    t.integer "o_id", null: false
    t.string "key", limit: 250
    t.integer "related_stats_store_object_id"
    t.string "data", limit: 5000
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_stats_stores_on_created_at"
    t.index ["created_by_id"], name: "index_stats_stores_on_created_by_id"
    t.index ["key"], name: "index_stats_stores_on_key"
    t.index ["o_id"], name: "index_stats_stores_on_o_id"
    t.index ["stats_store_object_id"], name: "index_stats_stores_on_stats_store_object_id"
  end

  create_table "store_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "sha", limit: 128, null: false
    t.string "provider", limit: 20
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["provider"], name: "index_store_files_on_provider"
    t.index ["sha"], name: "index_store_files_on_sha", unique: true
  end

  create_table "store_objects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_store_objects_on_name", unique: true
  end

  create_table "store_provider_dbs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "sha", limit: 128, null: false
    t.binary "data", limit: 4294967295
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["sha"], name: "index_store_provider_dbs_on_sha", unique: true
  end

  create_table "stores", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "store_object_id", null: false
    t.integer "store_file_id", null: false
    t.bigint "o_id", null: false
    t.string "preferences", limit: 2500
    t.string "size", limit: 50
    t.string "filename", limit: 250, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_17354e2aa6"
    t.index ["store_file_id"], name: "index_stores_on_store_file_id"
    t.index ["store_object_id", "o_id"], name: "index_stores_on_store_object_id_and_o_id"
  end

  create_table "tag_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "name_downcase", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name_downcase"], name: "index_tag_items_on_name_downcase"
  end

  create_table "tag_objects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_tag_objects_on_name", unique: true
  end

  create_table "tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tag_item_id", null: false
    t.integer "tag_object_id", null: false
    t.integer "o_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_5f245fd6a7"
    t.index ["o_id"], name: "index_tags_on_o_id"
    t.index ["tag_item_id"], name: "fk_rails_ebb54809f6"
    t.index ["tag_object_id"], name: "index_tags_on_tag_object_id"
  end

  create_table "taskbars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "last_contact", null: false
    t.string "client_id", null: false
    t.string "key", limit: 100, null: false
    t.string "callback", limit: 100, null: false
    t.text "state", limit: 4294967295
    t.text "preferences", limit: 16777215
    t.string "params", limit: 2000
    t.integer "prio", null: false
    t.boolean "notify", default: false, null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["client_id"], name: "index_taskbars_on_client_id"
    t.index ["key"], name: "index_taskbars_on_key"
    t.index ["user_id"], name: "index_taskbars_on_user_id"
  end

  create_table "templates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 250, null: false
    t.text "options", limit: 16777215, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_989d730f4b"
    t.index ["name"], name: "index_templates_on_name"
    t.index ["updated_by_id"], name: "fk_rails_4688f6dd32"
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "templates_groups", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "template_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_templates_groups_on_group_id"
    t.index ["template_id"], name: "index_templates_groups_on_template_id"
  end

  create_table "text_modules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 250, null: false
    t.string "keywords", limit: 500
    t.text "content", limit: 16777215, null: false
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.integer "foreign_id"
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_84148bfddb"
    t.index ["name"], name: "index_text_modules_on_name"
    t.index ["updated_by_id"], name: "fk_rails_343b2c0fce"
    t.index ["user_id"], name: "index_text_modules_on_user_id"
  end

  create_table "ticket_article_flags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ticket_article_id", null: false
    t.string "key", limit: 50, null: false
    t.string "value", limit: 50
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "index_ticket_article_flags_on_created_by_id"
    t.index ["ticket_article_id", "created_by_id"], name: "index_ticket_article_flags_on_articles_id_and_created_by_id"
    t.index ["ticket_article_id", "key"], name: "index_ticket_article_flags_on_ticket_article_id_and_key"
    t.index ["ticket_article_id"], name: "index_ticket_article_flags_on_ticket_article_id"
  end

  create_table "ticket_article_senders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_0d21d01513"
    t.index ["name"], name: "index_ticket_article_senders_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_f5ba9a2f30"
  end

  create_table "ticket_article_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.boolean "communication", null: false
    t.boolean "active", default: true, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_521ad892f1"
    t.index ["name"], name: "index_ticket_article_types_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_01020bb700"
  end

  create_table "ticket_articles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "type_id", null: false
    t.integer "sender_id", null: false
    t.string "from", limit: 3000
    t.string "to", limit: 3000
    t.string "cc", limit: 3000
    t.string "subject", limit: 3000
    t.string "reply_to", limit: 300
    t.string "message_id", limit: 3000
    t.string "message_id_md5", limit: 32
    t.string "in_reply_to", limit: 3000
    t.string "content_type", limit: 20, default: "text/plain", null: false
    t.string "references", limit: 3200
    t.text "body", limit: 4294967295, null: false
    t.boolean "internal", default: false, null: false
    t.text "preferences", limit: 16777215
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.integer "origin_by_id"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_ticket_articles_on_created_at"
    t.index ["created_by_id"], name: "index_ticket_articles_on_created_by_id"
    t.index ["internal"], name: "index_ticket_articles_on_internal"
    t.index ["message_id_md5", "type_id"], name: "index_ticket_articles_message_id_md5_type_id"
    t.index ["message_id_md5"], name: "index_ticket_articles_on_message_id_md5"
    t.index ["origin_by_id"], name: "fk_rails_c2dbb9e7aa"
    t.index ["sender_id"], name: "index_ticket_articles_on_sender_id"
    t.index ["ticket_id"], name: "index_ticket_articles_on_ticket_id"
    t.index ["type_id"], name: "index_ticket_articles_on_type_id"
    t.index ["updated_by_id"], name: "fk_rails_38b783461b"
  end

  create_table "ticket_counters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "content", limit: 100, null: false
    t.string "generator", limit: 100, null: false
    t.index ["generator"], name: "index_ticket_counters_on_generator", unique: true
  end

  create_table "ticket_flags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.string "key", limit: 50, null: false
    t.string "value", limit: 50
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "index_ticket_flags_on_created_by_id"
    t.index ["ticket_id", "created_by_id"], name: "index_ticket_flags_on_ticket_id_and_created_by_id"
    t.index ["ticket_id", "key"], name: "index_ticket_flags_on_ticket_id_and_key"
    t.index ["ticket_id"], name: "index_ticket_flags_on_ticket_id"
  end

  create_table "ticket_priorities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.boolean "default_create", default: false, null: false
    t.string "ui_icon", limit: 100
    t.string "ui_color", limit: 100
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_7ba453ab6d"
    t.index ["default_create"], name: "index_ticket_priorities_on_default_create"
    t.index ["name"], name: "index_ticket_priorities_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_d43af6872e"
  end

  create_table "ticket_state_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "note", limit: 250
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_70faf2d7df"
    t.index ["name"], name: "index_ticket_state_types_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_0b22ef689c"
  end

  create_table "ticket_states", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "state_type_id", null: false
    t.string "name", limit: 250, null: false
    t.integer "next_state_id"
    t.boolean "ignore_escalation", default: false, null: false
    t.boolean "default_create", default: false, null: false
    t.boolean "default_follow_up", default: false, null: false
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_2927b269ed"
    t.index ["default_create"], name: "index_ticket_states_on_default_create"
    t.index ["default_follow_up"], name: "index_ticket_states_on_default_follow_up"
    t.index ["name"], name: "index_ticket_states_on_name", unique: true
    t.index ["state_type_id"], name: "fk_rails_0853e2d094"
    t.index ["updated_by_id"], name: "fk_rails_4a7d116edc"
  end

  create_table "ticket_time_accountings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "ticket_article_id"
    t.decimal "time_unit", precision: 6, scale: 2, null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "index_ticket_time_accountings_on_created_by_id"
    t.index ["ticket_article_id"], name: "index_ticket_time_accountings_on_ticket_article_id"
    t.index ["ticket_id"], name: "index_ticket_time_accountings_on_ticket_id"
    t.index ["time_unit"], name: "index_ticket_time_accountings_on_time_unit"
  end

  create_table "tickets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "priority_id", null: false
    t.integer "state_id", null: false
    t.integer "organization_id"
    t.string "number", limit: 60, null: false
    t.string "title", limit: 250, null: false
    t.integer "owner_id", null: false
    t.integer "customer_id", null: false
    t.string "note", limit: 250
    t.timestamp "first_response_at", precision: 3
    t.timestamp "first_response_escalation_at", precision: 3
    t.integer "first_response_in_min"
    t.integer "first_response_diff_in_min"
    t.timestamp "close_at", precision: 3
    t.timestamp "close_escalation_at", precision: 3
    t.integer "close_in_min"
    t.integer "close_diff_in_min"
    t.timestamp "update_escalation_at", precision: 3
    t.integer "update_in_min"
    t.integer "update_diff_in_min"
    t.timestamp "last_contact_at", precision: 3
    t.timestamp "last_contact_agent_at", precision: 3
    t.timestamp "last_contact_customer_at", precision: 3
    t.timestamp "last_owner_update_at", precision: 3
    t.integer "create_article_type_id"
    t.integer "create_article_sender_id"
    t.integer "article_count"
    t.timestamp "escalation_at", precision: 3
    t.timestamp "pending_time", precision: 3
    t.string "type", limit: 100
    t.decimal "time_unit", precision: 6, scale: 2
    t.text "preferences", limit: 16777215
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.string "category"
    t.boolean "are_you_victim"
    t.string "victim"
    t.string "others"
    t.string "ongoing"
    t.string "when_it_happened"
    t.string "where"
    t.string "anonymous"
    t.datetime "when"
    t.index ["close_at"], name: "index_tickets_on_close_at"
    t.index ["close_diff_in_min"], name: "index_tickets_on_close_diff_in_min"
    t.index ["close_escalation_at"], name: "index_tickets_on_close_escalation_at"
    t.index ["close_in_min"], name: "index_tickets_on_close_in_min"
    t.index ["create_article_sender_id"], name: "index_tickets_on_create_article_sender_id"
    t.index ["create_article_type_id"], name: "index_tickets_on_create_article_type_id"
    t.index ["created_at"], name: "index_tickets_on_created_at"
    t.index ["created_by_id"], name: "index_tickets_on_created_by_id"
    t.index ["customer_id", "state_id", "created_at"], name: "index_tickets_on_customer_id_and_state_id_and_created_at"
    t.index ["customer_id"], name: "index_tickets_on_customer_id"
    t.index ["escalation_at"], name: "index_tickets_on_escalation_at"
    t.index ["first_response_at"], name: "index_tickets_on_first_response_at"
    t.index ["first_response_diff_in_min"], name: "index_tickets_on_first_response_diff_in_min"
    t.index ["first_response_escalation_at"], name: "index_tickets_on_first_response_escalation_at"
    t.index ["first_response_in_min"], name: "index_tickets_on_first_response_in_min"
    t.index ["group_id", "state_id", "close_at"], name: "index_tickets_on_group_id_and_state_id_and_close_at"
    t.index ["group_id", "state_id", "created_at"], name: "index_tickets_on_group_id_and_state_id_and_created_at"
    t.index ["group_id", "state_id", "owner_id", "close_at"], name: "index_tickets_on_group_id_state_id_owner_id_close_at"
    t.index ["group_id", "state_id", "owner_id", "created_at"], name: "index_tickets_on_group_id_state_id_owner_id_created_at"
    t.index ["group_id", "state_id", "owner_id", "updated_at"], name: "index_tickets_on_group_id_state_id_owner_id_updated_at"
    t.index ["group_id", "state_id", "owner_id"], name: "index_tickets_on_group_id_and_state_id_and_owner_id"
    t.index ["group_id", "state_id", "updated_at"], name: "index_tickets_on_group_id_and_state_id_and_updated_at"
    t.index ["group_id", "state_id"], name: "index_tickets_on_group_id_and_state_id"
    t.index ["group_id"], name: "index_tickets_on_group_id"
    t.index ["last_contact_agent_at"], name: "index_tickets_on_last_contact_agent_at"
    t.index ["last_contact_at"], name: "index_tickets_on_last_contact_at"
    t.index ["last_contact_customer_at"], name: "index_tickets_on_last_contact_customer_at"
    t.index ["last_owner_update_at"], name: "index_tickets_on_last_owner_update_at"
    t.index ["number"], name: "index_tickets_on_number", unique: true
    t.index ["organization_id"], name: "fk_rails_b62b455ecb"
    t.index ["owner_id"], name: "index_tickets_on_owner_id"
    t.index ["pending_time"], name: "index_tickets_on_pending_time"
    t.index ["priority_id"], name: "index_tickets_on_priority_id"
    t.index ["state_id"], name: "index_tickets_on_state_id"
    t.index ["time_unit"], name: "index_tickets_on_time_unit"
    t.index ["title"], name: "index_tickets_on_title"
    t.index ["type"], name: "index_tickets_on_type"
    t.index ["update_diff_in_min"], name: "index_tickets_on_update_diff_in_min"
    t.index ["update_in_min"], name: "index_tickets_on_update_in_min"
    t.index ["updated_at"], name: "index_tickets_on_updated_at"
    t.index ["updated_by_id"], name: "fk_rails_edf0f77848"
  end

  create_table "tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "persistent"
    t.string "name", limit: 100, null: false
    t.string "action", limit: 40, null: false
    t.string "label"
    t.text "preferences", limit: 16777215
    t.timestamp "last_used_at", precision: 3
    t.date "expires_at"
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_tokens_on_created_at"
    t.index ["name", "action"], name: "index_tokens_on_name_and_action", unique: true
    t.index ["persistent"], name: "index_tokens_on_persistent"
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "locale", limit: 10, null: false
    t.string "source", limit: 500, null: false
    t.string "target", limit: 500, null: false
    t.string "target_initial", limit: 500, null: false
    t.string "format", limit: 20, default: "string", null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_d6e6d9635d"
    t.index ["locale"], name: "index_translations_on_locale"
    t.index ["source"], name: "index_translations_on_source", length: 255
    t.index ["updated_by_id"], name: "fk_rails_8cb1380a17"
  end

  create_table "triggers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.text "condition", limit: 16777215, null: false
    t.text "perform", limit: 16777215, null: false
    t.boolean "disable_notification", default: true, null: false
    t.string "note", limit: 250
    t.boolean "active", default: true, null: false
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "fk_rails_35c0846653"
    t.index ["name"], name: "index_triggers_on_name", unique: true
    t.index ["updated_by_id"], name: "fk_rails_7f3d25350f"
  end

  create_table "type_lookups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["name"], name: "index_type_lookups_on_name", unique: true
  end

  create_table "user_devices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", limit: 250, null: false
    t.string "os", limit: 150
    t.string "browser", limit: 250
    t.string "location", limit: 150
    t.string "device_details", limit: 2500
    t.string "location_details", limit: 2500
    t.string "fingerprint", limit: 160
    t.string "user_agent", limit: 250
    t.string "ip", limit: 160
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_at"], name: "index_user_devices_on_created_at"
    t.index ["fingerprint"], name: "index_user_devices_on_fingerprint"
    t.index ["os", "browser", "location"], name: "index_user_devices_on_os_and_browser_and_location"
    t.index ["updated_at"], name: "index_user_devices_on_updated_at"
    t.index ["user_id"], name: "index_user_devices_on_user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.string "login", null: false
    t.string "firstname", limit: 100, default: ""
    t.string "lastname", limit: 100, default: ""
    t.string "email", default: ""
    t.string "image", limit: 100
    t.string "image_source", limit: 200
    t.string "web", limit: 100, default: ""
    t.string "password", limit: 100
    t.string "phone", limit: 100, default: ""
    t.string "fax", limit: 100, default: ""
    t.string "mobile", limit: 100, default: ""
    t.string "department", limit: 200, default: ""
    t.string "street", limit: 120, default: ""
    t.string "zip", limit: 100, default: ""
    t.string "city", limit: 100, default: ""
    t.string "country", limit: 100, default: ""
    t.string "address", limit: 500, default: ""
    t.boolean "vip", default: false
    t.boolean "verified", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "note", limit: 5000, default: ""
    t.timestamp "last_login", precision: 3
    t.string "source", limit: 200
    t.integer "login_failed", default: 0, null: false
    t.boolean "out_of_office", default: false, null: false
    t.date "out_of_office_start_at"
    t.date "out_of_office_end_at"
    t.integer "out_of_office_replacement_id"
    t.string "preferences", limit: 8000
    t.integer "updated_by_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: 3, null: false
    t.datetime "updated_at", precision: 3, null: false
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["department"], name: "index_users_on_department"
    t.index ["email"], name: "index_users_on_email"
    t.index ["fax"], name: "index_users_on_fax"
    t.index ["image"], name: "index_users_on_image"
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["mobile"], name: "index_users_on_mobile"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["out_of_office", "out_of_office_start_at", "out_of_office_end_at"], name: "index_out_of_office"
    t.index ["out_of_office_replacement_id"], name: "index_users_on_out_of_office_replacement_id"
    t.index ["phone"], name: "index_users_on_phone"
    t.index ["source"], name: "index_users_on_source"
    t.index ["updated_by_id"], name: "fk_rails_355a7ffe95"
  end

  add_foreign_key "activity_streams", "groups"
  add_foreign_key "activity_streams", "object_lookups", column: "activity_stream_object_id"
  add_foreign_key "activity_streams", "permissions"
  add_foreign_key "activity_streams", "type_lookups", column: "activity_stream_type_id"
  add_foreign_key "activity_streams", "users", column: "created_by_id"
  add_foreign_key "authorizations", "users"
  add_foreign_key "avatars", "users", column: "created_by_id"
  add_foreign_key "avatars", "users", column: "updated_by_id"
  add_foreign_key "calendars", "users", column: "created_by_id"
  add_foreign_key "calendars", "users", column: "updated_by_id"
  add_foreign_key "channels", "groups"
  add_foreign_key "channels", "users", column: "created_by_id"
  add_foreign_key "channels", "users", column: "updated_by_id"
  add_foreign_key "chat_agents", "users", column: "created_by_id"
  add_foreign_key "chat_agents", "users", column: "updated_by_id"
  add_foreign_key "chat_messages", "chat_sessions"
  add_foreign_key "chat_messages", "users", column: "created_by_id"
  add_foreign_key "chat_sessions", "chats"
  add_foreign_key "chat_sessions", "users"
  add_foreign_key "chat_sessions", "users", column: "created_by_id"
  add_foreign_key "chat_sessions", "users", column: "updated_by_id"
  add_foreign_key "chat_topics", "users", column: "created_by_id"
  add_foreign_key "chat_topics", "users", column: "updated_by_id"
  add_foreign_key "chats", "users", column: "created_by_id"
  add_foreign_key "chats", "users", column: "updated_by_id"
  add_foreign_key "cti_caller_ids", "users"
  add_foreign_key "email_addresses", "users", column: "created_by_id"
  add_foreign_key "email_addresses", "users", column: "updated_by_id"
  add_foreign_key "groups", "email_addresses"
  add_foreign_key "groups", "signatures"
  add_foreign_key "groups", "users", column: "created_by_id"
  add_foreign_key "groups", "users", column: "updated_by_id"
  add_foreign_key "groups_macros", "groups"
  add_foreign_key "groups_macros", "macros"
  add_foreign_key "groups_text_modules", "groups"
  add_foreign_key "groups_text_modules", "text_modules"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "histories", "history_attributes"
  add_foreign_key "histories", "history_objects"
  add_foreign_key "histories", "history_types"
  add_foreign_key "histories", "users", column: "created_by_id"
  add_foreign_key "http_logs", "users", column: "created_by_id"
  add_foreign_key "http_logs", "users", column: "updated_by_id"
  add_foreign_key "jobs", "users", column: "created_by_id"
  add_foreign_key "jobs", "users", column: "updated_by_id"
  add_foreign_key "karma_activity_logs", "karma_activities", column: "activity_id"
  add_foreign_key "karma_activity_logs", "users"
  add_foreign_key "karma_users", "users"
  add_foreign_key "knowledge_base_answer_translations", "knowledge_base_answer_translation_contents", column: "content_id"
  add_foreign_key "knowledge_base_answer_translations", "knowledge_base_answers", column: "answer_id", on_delete: :cascade
  add_foreign_key "knowledge_base_answer_translations", "knowledge_base_locales", column: "kb_locale_id"
  add_foreign_key "knowledge_base_answer_translations", "users", column: "created_by_id"
  add_foreign_key "knowledge_base_answer_translations", "users", column: "updated_by_id"
  add_foreign_key "knowledge_base_answers", "knowledge_base_categories", column: "category_id"
  add_foreign_key "knowledge_base_answers", "users", column: "archived_by_id"
  add_foreign_key "knowledge_base_answers", "users", column: "internal_by_id"
  add_foreign_key "knowledge_base_answers", "users", column: "published_by_id"
  add_foreign_key "knowledge_base_categories", "knowledge_base_categories", column: "parent_id"
  add_foreign_key "knowledge_base_categories", "knowledge_bases"
  add_foreign_key "knowledge_base_category_translations", "knowledge_base_categories", column: "category_id", on_delete: :cascade
  add_foreign_key "knowledge_base_category_translations", "knowledge_base_locales", column: "kb_locale_id"
  add_foreign_key "knowledge_base_locales", "knowledge_bases"
  add_foreign_key "knowledge_base_locales", "locales", column: "system_locale_id"
  add_foreign_key "knowledge_base_menu_items", "knowledge_base_locales", column: "kb_locale_id", on_delete: :cascade
  add_foreign_key "knowledge_base_translations", "knowledge_base_locales", column: "kb_locale_id"
  add_foreign_key "knowledge_base_translations", "knowledge_bases", on_delete: :cascade
  add_foreign_key "links", "link_types"
  add_foreign_key "macros", "users", column: "created_by_id"
  add_foreign_key "macros", "users", column: "updated_by_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "object_manager_attributes", "object_lookups"
  add_foreign_key "object_manager_attributes", "users", column: "created_by_id"
  add_foreign_key "object_manager_attributes", "users", column: "updated_by_id"
  add_foreign_key "online_notifications", "users"
  add_foreign_key "online_notifications", "users", column: "created_by_id"
  add_foreign_key "online_notifications", "users", column: "updated_by_id"
  add_foreign_key "organizations", "users", column: "created_by_id"
  add_foreign_key "organizations", "users", column: "updated_by_id"
  add_foreign_key "organizations_users", "organizations"
  add_foreign_key "organizations_users", "users"
  add_foreign_key "overviews", "users", column: "created_by_id"
  add_foreign_key "overviews", "users", column: "updated_by_id"
  add_foreign_key "overviews_groups", "groups"
  add_foreign_key "overviews_groups", "overviews"
  add_foreign_key "overviews_roles", "overviews"
  add_foreign_key "overviews_roles", "roles"
  add_foreign_key "overviews_users", "overviews"
  add_foreign_key "overviews_users", "users"
  add_foreign_key "packages", "users", column: "created_by_id"
  add_foreign_key "packages", "users", column: "updated_by_id"
  add_foreign_key "postmaster_filters", "users", column: "created_by_id"
  add_foreign_key "postmaster_filters", "users", column: "updated_by_id"
  add_foreign_key "recent_views", "object_lookups", column: "recent_view_object_id"
  add_foreign_key "recent_views", "users", column: "created_by_id"
  add_foreign_key "report_profiles", "users", column: "created_by_id"
  add_foreign_key "report_profiles", "users", column: "updated_by_id"
  add_foreign_key "roles", "users", column: "created_by_id"
  add_foreign_key "roles", "users", column: "updated_by_id"
  add_foreign_key "roles_groups", "groups"
  add_foreign_key "roles_groups", "roles"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
  add_foreign_key "schedulers", "users", column: "created_by_id"
  add_foreign_key "schedulers", "users", column: "updated_by_id"
  add_foreign_key "signatures", "users", column: "created_by_id"
  add_foreign_key "signatures", "users", column: "updated_by_id"
  add_foreign_key "slas", "users", column: "created_by_id"
  add_foreign_key "slas", "users", column: "updated_by_id"
  add_foreign_key "stats_stores", "users", column: "created_by_id"
  add_foreign_key "stores", "store_files"
  add_foreign_key "stores", "store_objects"
  add_foreign_key "stores", "users", column: "created_by_id"
  add_foreign_key "tags", "tag_items"
  add_foreign_key "tags", "tag_objects"
  add_foreign_key "tags", "users", column: "created_by_id"
  add_foreign_key "taskbars", "users"
  add_foreign_key "templates", "users"
  add_foreign_key "templates", "users", column: "created_by_id"
  add_foreign_key "templates", "users", column: "updated_by_id"
  add_foreign_key "templates_groups", "groups"
  add_foreign_key "templates_groups", "templates"
  add_foreign_key "text_modules", "users"
  add_foreign_key "text_modules", "users", column: "created_by_id"
  add_foreign_key "text_modules", "users", column: "updated_by_id"
  add_foreign_key "ticket_article_flags", "ticket_articles"
  add_foreign_key "ticket_article_flags", "users", column: "created_by_id"
  add_foreign_key "ticket_article_senders", "users", column: "created_by_id"
  add_foreign_key "ticket_article_senders", "users", column: "updated_by_id"
  add_foreign_key "ticket_article_types", "users", column: "created_by_id"
  add_foreign_key "ticket_article_types", "users", column: "updated_by_id"
  add_foreign_key "ticket_articles", "ticket_article_senders", column: "sender_id"
  add_foreign_key "ticket_articles", "ticket_article_types", column: "type_id"
  add_foreign_key "ticket_articles", "tickets"
  add_foreign_key "ticket_articles", "users", column: "created_by_id"
  add_foreign_key "ticket_articles", "users", column: "origin_by_id"
  add_foreign_key "ticket_articles", "users", column: "updated_by_id"
  add_foreign_key "ticket_flags", "tickets"
  add_foreign_key "ticket_flags", "users", column: "created_by_id"
  add_foreign_key "ticket_priorities", "users", column: "created_by_id"
  add_foreign_key "ticket_priorities", "users", column: "updated_by_id"
  add_foreign_key "ticket_state_types", "users", column: "created_by_id"
  add_foreign_key "ticket_state_types", "users", column: "updated_by_id"
  add_foreign_key "ticket_states", "ticket_state_types", column: "state_type_id"
  add_foreign_key "ticket_states", "users", column: "created_by_id"
  add_foreign_key "ticket_states", "users", column: "updated_by_id"
  add_foreign_key "ticket_time_accountings", "ticket_articles"
  add_foreign_key "ticket_time_accountings", "tickets"
  add_foreign_key "ticket_time_accountings", "users", column: "created_by_id"
  add_foreign_key "tickets", "groups"
  add_foreign_key "tickets", "organizations"
  add_foreign_key "tickets", "ticket_priorities", column: "priority_id"
  add_foreign_key "tickets", "ticket_states", column: "state_id"
  add_foreign_key "tickets", "users", column: "created_by_id"
  add_foreign_key "tickets", "users", column: "customer_id"
  add_foreign_key "tickets", "users", column: "owner_id"
  add_foreign_key "tickets", "users", column: "updated_by_id"
  add_foreign_key "tokens", "users"
  add_foreign_key "translations", "users", column: "created_by_id"
  add_foreign_key "translations", "users", column: "updated_by_id"
  add_foreign_key "triggers", "users", column: "created_by_id"
  add_foreign_key "triggers", "users", column: "updated_by_id"
  add_foreign_key "user_devices", "users"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "out_of_office_replacement_id"
  add_foreign_key "users", "users", column: "updated_by_id"
end
