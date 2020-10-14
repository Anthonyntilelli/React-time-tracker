# frozen_string_literal: true

# Employee Migration
class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :employees do |t|
      t.text :name, null: false
      t.string :password_digest, null: false
      t.integer :pto_rate, null: false
      t.integer :pto_current, null: false
      t.integer :pto_max, null: false
      t.boolean :admin, null: false, default: false
      t.boolean :active, null: false

      t.timestamps
    end
  end
end
