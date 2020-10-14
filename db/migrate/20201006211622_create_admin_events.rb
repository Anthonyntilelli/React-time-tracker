# frozen_string_literal: true

# AdminEvent Migration
class CreateAdminEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_events do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :admin, null: false
      t.string :action, null: false
      t.string :reason, null: false

      t.timestamps
    end
  end
end
