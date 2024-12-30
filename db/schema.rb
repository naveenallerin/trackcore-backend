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

ActiveRecord::Schema[7.0].define(version: 2024_12_30_105302) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approval_decisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approval_requests", force: :cascade do |t|
    t.bigint "approver_id"
    t.string "status", default: "pending"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "approval_workflow_id", null: false
    t.string "approvable_type"
    t.bigint "approvable_id"
    t.string "approver_type"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.index ["approvable_type", "approvable_id"], name: "index_approval_requests_on_approvable_type_and_approvable_id"
    t.index ["approval_workflow_id"], name: "index_approval_requests_on_approval_workflow_id"
    t.index ["approver_id"], name: "index_approval_requests_on_approver_id"
    t.index ["approver_type", "approver_id"], name: "index_approval_requests_on_approver_type_and_approver_id"
  end

  create_table "approval_steps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approval_workflows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historical_metrics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_board_credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_posting_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_postings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "organization_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_jobs_on_organization_id"
  end

  create_table "knockout_and_scoring_tables", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "domain"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requisitions", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "pending"
    t.string "approval_state", default: "pending"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_requisitions_on_user_id"
  end

  create_table "rules", force: :cascade do |t|
    t.string "condition_expression"
    t.string "action"
    t.integer "priority"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name"
    t.boolean "is_approver", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "dashboard_config"
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "workflows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "approval_requests", "approval_workflows"
  add_foreign_key "jobs", "organizations"
  add_foreign_key "requisitions", "users"
end
