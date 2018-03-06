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
    @schedule.each do |departure|
      sch_time = departure["date"] + " " + departure["aimed_departure_time"]
      if time_difference(sch_time).abs < delay.abs
        delay = time_difference(sch_time)
        # line_name or line??
        bus_line = departure["line_name"]
      end
    end
    {delay: delay, bus_line: bus_line}
  end

  
  private

  # time difference in minutes betwen the recorded bus leaving time and the scheduled time
  def time_difference(departure_time)
    actual_time = @datetime.to_time.change(:sec => 0)
    ((departure_time.to_time - actual_time) / 60).to_i
  end

  def add_delay
  end
end