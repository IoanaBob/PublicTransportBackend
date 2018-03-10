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

  # TODO: request schedule for each bus line separately
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
    return if @schedule.empty?

    delay = Float::INFINITY
    bus_line = ""
    sch_time = ""
    dep_time = ""

    @schedule.each do |departure|
      sch_time = departure["date"] + " " + departure["aimed_departure_time"]

      # time difference has to be smaller than the minimum delay and more than 5 minutes early
      # if it's more than 5 minutes early it's probably the previous bus being late
      if time_difference(sch_time).abs < delay.abs && time_difference(sch_time) >= -5
        dep_time = sch_time
        delay = time_difference(sch_time)
        # line_name or line??
        bus_line = departure["line_name"]
      end
    end
    
    {delay: delay, bus_line: bus_line, aimed_departure_time: dep_time}
  end

  def add_delays_to_schedule
    @schedule.each do |departure|
      delay = find_delay_for_departure(departure)

      unless delay.blank?
        departure["delay"] = delay
        expected_dep = expected_from_aimed_departure(departure["date"], departure["aimed_departure_time"], delay)
        departure["expected_departure_time"] = expected_dep[:time]
        departure["expected_departure_date"] = expected_dep[:date]
      end
    end
    @schedule
  end

  def find_delay_for_departure(departure)
    dep_time = departure["date"] + " " + departure["aimed_departure_time"]
    is_weekday = is_weekday(dep_time)
    locations = Location.where(bus_line: departure["line_name"])
    locations = locations.where_weekday(is_weekday)

    if locations.where_aimed_time(departure["aimed_departure_time"]).empty?
      starting = (departure["aimed_departure_time"].to_time - 1.hour).strftime("%H:%M")
      ending = (departure["aimed_departure_time"].to_time + 1.hour).strftime("%H:%M")
  
      locations = locations.where_aimed_in_time_range(starting, ending)
    else
      locations = locations.where_aimed_time(departure["aimed_departure_time"])
    end

    if locations.empty? 
      nil
    else
      locations.average_delay
    end
  end

  private

  def is_weekday(datetime)
    # returns 0 to 6, Sunday to Saturday
    day = datetime.to_time.wday
    # if monday to friday
    (1..5).include? day
  end

  # time difference in minutes betwen the recorded bus leaving time (time attribute) and the scheduled time
  def time_difference(departure_time)
    actual_time = @datetime.to_time.change(:sec => 0)
    ((departure_time.to_time - actual_time) / 60).to_i
  end

  def expected_from_aimed_departure(aim_date, aim_time, delay)
    aimed_time = (aim_date + " " + aim_time).to_time
    expected_time = aimed_time + delay.minutes
    {date: expected_time.strftime("%Y-%m-%d"), time: expected_time.strftime("%H:%M")}
  end
end