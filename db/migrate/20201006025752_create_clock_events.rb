# frozen_string_literal: true

# ClockEvents Migration
class CreateClockEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :clock_events do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :category, null: false
      t.datetime :triggered, null: false
      t.boolean :paidOut, null: false

      t.timestamps
    end
  end
end
