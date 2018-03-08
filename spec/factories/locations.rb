FactoryBot.define do
  factory :location do
    latitude 1.5
    longitude 1.5
    time "2018-02-27 14:25:17"
    current_speed 1.5
    note 1
    delay 5.0
    bus_line "9"
    aimed_departure_time "2018-02-27 14:30:17"
    bus_stop
  end
end
