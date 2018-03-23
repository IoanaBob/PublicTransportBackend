class LocationController < ApplicationController
  def index
    locations = Location.all
    render json: locations, status: :ok
  end

  def show
    location = Location.find(params[:id])
    render json: location, status: :ok
  end

  def create
    bus_stops = BusStop.where(atcocode: params[:atcocode])
    if bus_stops.empty?
      render json: { errors: [atcocode: 'bus stop could not be found'] }, status: :not_found
    else
      location = bus_stops.first.locations.new(location_params)

      if location.save
        head :ok
        # add delay, and for what bus line
        timetable = Timetable.new(atcocode: location.bus_stop.atcocode, datetime: location.time)
        delay_for_bus = timetable.get_delay_for_bus
        unless delay_for_bus.nil?
          add_params_to_location(location, delay_for_bus[:delay], delay_for_bus[:bus_line], delay_for_bus[:aimed_departure_time])
        end
        # else raise error? can it be an error?
      else
        render json: location.errors, status: :bad_request
      end
    end
  end

  private

    def add_params_to_location(location, delay, bus_line, aimed_departure_time)
      if location.update_attributes(bus_line: bus_line, delay: delay, aimed_departure_time: aimed_departure_time)
        return :ok
      else
        return :error
      end
    end

    def location_params
      params
        .require(:location)
        .permit(:latitude, :longitude, :time, :current_speed, :note)
    end
end