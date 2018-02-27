class CreateLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :time
      t.float :current_speed
      t.integer :note
      t.belongs_to :bus_stop, foreign_key: true

      t.timestamps
    end
  end
end
