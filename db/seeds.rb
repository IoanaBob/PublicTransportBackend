# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

bus_stop = BusStop.create(
  {
    atcocode: "5710AWA10616", 
    mode: "bus", 
    name: "Treharris Street", 
    stop_name: "Treharris Street",
    bearing: "SE",
    smscode: "cdipaga",
    locality: "Roath",
    indicator: "o/s",
    latitude: -3.16913,
    longitude: 51.48983,
    distance: 61
  }
)

Location.create(
  {
    latitude: 1.5,
    longitude: 1.5,
    time: "2018-02-27 14:25:17",
    current_speed: 1.5,
    note: 1,
    delay: 5.0,
    bus_line: "9",
    aimed_departure_time: "2018-02-27 14:30:17",
    bus_stop: bus_stop
  }
)
