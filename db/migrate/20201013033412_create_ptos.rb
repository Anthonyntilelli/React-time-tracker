# frozen_string_literal: true

# ClockEvents Migration
class CreatePtos < ActiveRecord::Migration[6.0]
  def change
    create_table :ptos do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :category, null: false
      t.datetime :triggered, null: false
      t.integer :hours
      t.boolean :paidOut, null: false

      t.timestamps
    end
  end
end
