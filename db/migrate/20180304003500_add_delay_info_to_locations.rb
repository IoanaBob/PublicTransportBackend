class AddDelayInfoToLocations < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :delay, :float
    add_column :locations, :bus_line, :string
    add_column :locations, :aimed_departure_time, :datetime
  end
end
