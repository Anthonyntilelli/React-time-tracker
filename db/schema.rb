# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_13_033412) do

  create_table "admin_events", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "admin", null: false
    t.string "action", null: false
    t.string "reason", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["employee_id"], name: "index_admin_events_on_employee_id"
  end

  create_table "clock_events", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.string "category", null: false
    t.datetime "triggered", null: false
    t.boolean "paidOut", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["employee_id"], name: "index_clock_events_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.text "name", null: false
    t.string "password_digest", null: false
    t.integer "pto_rate", null: false
    t.integer "pto_current", null: false
    t.integer "pto_max", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "active", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_employees_on_name", unique: true
  end

  create_table "ptos", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.string "category", null: false
    t.datetime "triggered", null: false
    t.integer "hours"
    t.boolean "paidOut", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["employee_id"], name: "index_ptos_on_employee_id"
  end

  add_foreign_key "admin_events", "employees"
  add_foreign_key "clock_events", "employees"
  add_foreign_key "ptos", "employees"
end
