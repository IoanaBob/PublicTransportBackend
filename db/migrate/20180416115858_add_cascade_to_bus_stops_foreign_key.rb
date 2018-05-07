class AddCascadeToBusStopsForeignKey < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :locations, :bus_stops
    add_foreign_key :locations, :bus_stops, on_delete: :cascade
  end
end
