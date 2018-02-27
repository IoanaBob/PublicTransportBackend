class CreateBusStops < ActiveRecord::Migration[5.1]
  def change
    create_table :bus_stops do |t|
      t.string :atcocode
      t.string :mode
      t.string :name
      t.string :stop_name
      t.string :bearing
      t.string :smscode
      t.string :locality
      t.string :indicator
      t.float :longitude
      t.float :latitude
      t.integer :distance

      t.timestamps
    end
  end
end
