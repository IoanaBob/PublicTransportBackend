require 'time'
require 'net/http'

class Timetable
  attr_reader :schedule

  def initialize(atcocode:, datetime:, bus_line: nil)
    @atcocode = atcocode
    @datetime = datetime
    @date = datetime.to_date
    @time = datetime.to_time
    @schedule = refresh_schedule(bus_line) || []    
  end

  # TODO: request schedule for each bus line separately
  def refresh_schedule(bus_line = nil)
    date = @date.strftime("%Y-%m-%d")
    # TODO: add param for early schedule, with default
    time = (@time - 10.minutes).strftime("%H:%M")
    if bus_line.nil?
      url = URI.parse("http://transportapi.com/v3/uk/bus/stop/#{@atcocode}/#{date}/#{time}/timetable.json?group=no&app_id=f67ffe61&app_key=84ead149046c88f0189b3763639d4d152")
    else
      url = URI.parse("http://transportapi.com/v3/uk/bus/stop/#{@atcocode}/#{date}/#{time}/timetable.json?app_id=f67ffe61&app_key=84ead149046c88f0189b3763639d4d152")
    end
    
    request = Net::HTTP::Get.new(url.to_s)

    response = Net::HTTP.start(url.host, url.port) do |http|
      http.request(request)
    end

    parsed_body = JSON.parse(response.body)
    if parsed_body['departures'] == {}
      @schedule = []
    else
      if bus_line.nil?
        @schedule = parsed_body['departures']['all']
      else
        @schedule = parsed_body['departures'][bus_line]
      end
    end
    @schedule
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
        delay = time_difference(sch_time).to_i
        # line_name or line??
        bus_line = departure["line_name"]
      end
    end
    
    {delay: delay, bus_line: bus_line, aimed_departure_time: dep_time}
  end

  def add_delays_to_schedule
    return if @schedule.empty?
    
    @schedule.each do |departure|
      delay = find_delay_for_departure(departure)

      unless delay.nil?
        departure["delay"] = delay.to_i
        expected_dep = expected_from_aimed_departure(departure["date"], departure["aimed_departure_time"], delay)
        departure["expected_departure_time"] = expected_dep[:time]
        departure["expected_departure_date"] = expected_dep[:date]
      else
        departure["delay"] = 0
        departure["expected_departure_time"] = "unknown"
        departure["expected_departure_date"] = "unknown"
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

  # time difference in minutes between the recorded bus leaving time (time attribute) and the scheduled time
  def time_difference(departure_time)
    actual_time = @datetime.in_time_zone('UTC').change(:sec => 0)
    ((actual_time - departure_time.in_time_zone('UTC')) / 60).to_i
  end

  def expected_from_aimed_departure(aim_date, aim_time, delay)
    aimed_time = (aim_date + " " + aim_time).in_time_zone('UTC')
    expected_time = aimed_time + delay.minutes
    {date: expected_time.strftime("%Y-%m-%d"), time: expected_time.strftime("%H:%M")}
  end
end