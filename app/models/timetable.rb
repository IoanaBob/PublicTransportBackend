require 'time'

class Timetable
  attr_reader :schedule

  def initialize(atcocode:, datetime:)
    @atcocode = atcocode
    @datetime = datetime
    @date = datetime.to_date
    @time = datetime.to_time
    @schedule = refresh_schedule
  end

  def refresh_schedule
    date = @date.strftime("%Y-%m-%d")
    # TODO: minus 30 min
    time = @date.strftime("%H:%M")

    url = URI.parse("http://transportapi.com/v3/uk/bus/stop/#{@atcocode}/#{date}/#{time}/timetable.json?group=no&app_id=c12137e2&app_key=703b3fc0bc730dacf75e46ce7b9e9402")
    request = Net::HTTP::Get.new(url.to_s)

    response = Net::HTTP.start(url.host, url.port) do |http|
      http.request(request)
    end

    parsed_body = JSON.parse(response.body)
    @schedule = parsed_body['departures']['all']
  end

  def get_delay_for_bus
    return :none if @schedule.empty?

    delay = Float::INFINITY
    bus_line = ""
    sch_time = ""
    dep_time = ""

    @schedule.each do |departure|
      sch_time = departure["date"] + " " + departure["aimed_departure_time"]
      if time_difference(sch_time).abs < delay.abs
        dep_time = sch_time
        delay = time_difference(sch_time)
        # line_name or line??
        bus_line = departure["line_name"]
      end
    end
    {delay: delay, bus_line: bus_line, aimed_departure_time: dep_time}
  end

  def find_delay_for_departure(departure)
    dep_time = departure["date"] + " " + departure["aimed_departure_time"]
    is_weekday = is_weekday(dep_time)
    locations = Location.where(bus_line: departure["line_name"])
    locations = locations.where_weekday(is_weekday)

    if !locations.where_aimed_time(departure["aimed_departure_time"]).empty?
      locations = locations.where_aimed_time(departure["aimed_departure_time"])
    else
      starting = (departure["aimed_departure_time"].to_time - 1.hour).strftime("%H:%M")
      ending = (departure["aimed_departure_time"].to_time + 1.hour).strftime("%H:%M")
  
      locations = locations.where_aimed_in_time_range(starting, ending)
    end

    locations.empty? ? :none : locations.average_delay
  end

  private

  def is_weekday(datetime)
    # returns 0 to 6, Sunday to Saturday
    day = datetime.to_time.wday
    # if monday to friday
    return (1..5).include? day
  end

  # time difference in minutes betwen the recorded bus leaving time and the scheduled time
  def time_difference(departure_time)
    actual_time = @datetime.to_time.change(:sec => 0)
    ((departure_time.to_time - actual_time) / 60).to_i
  end
end