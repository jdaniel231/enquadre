# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_29_135841) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "account_id", null: false
    t.bigint "care_plan_id", null: false
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "fee_cents"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_appointments_on_account_id"
    t.index ["care_plan_id"], name: "index_appointments_on_care_plan_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "care_plans", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "account_id", null: false
    t.integer "billing_mode", default: 0, null: false
    t.integer "sessions_per_week", null: false
    t.integer "session_duration_minutes", default: 50, null: false
    t.integer "fee_cents", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_care_plans_on_account_id"
    t.index ["patient_id"], name: "index_care_plans_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "full_name"
    t.string "cpf"
    t.string "phone"
    t.string "email"
    t.date "date_of_birth"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_patients_on_account_id"
  end

  create_table "private_notes", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_private_notes_on_patient_id"
    t.index ["user_id"], name: "index_private_notes_on_user_id"
  end

  create_table "professional_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "kind", default: 0, null: false
    t.string "crp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_professional_profiles_on_user_id"
  end

  create_table "record_entries", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.bigint "appointment_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_record_entries_on_account_id"
    t.index ["appointment_id"], name: "index_record_entries_on_appointment_id"
    t.index ["patient_id"], name: "index_record_entries_on_patient_id"
    t.index ["user_id"], name: "index_record_entries_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "account_id", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "appointments", "accounts"
  add_foreign_key "appointments", "care_plans"
  add_foreign_key "appointments", "patients"
  add_foreign_key "care_plans", "accounts"
  add_foreign_key "care_plans", "patients"
  add_foreign_key "patients", "accounts"
  add_foreign_key "private_notes", "patients"
  add_foreign_key "private_notes", "users"
  add_foreign_key "professional_profiles", "users"
  add_foreign_key "record_entries", "accounts"
  add_foreign_key "record_entries", "appointments"
  add_foreign_key "record_entries", "patients"
  add_foreign_key "record_entries", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "accounts"
end
