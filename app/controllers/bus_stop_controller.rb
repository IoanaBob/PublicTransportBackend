class BusStopController < ApplicationController
  def index
    bus_stops = BusStop.all
    render json: bus_stops, status: :ok
  end

  def show
    bus_stop = BusStop.find(params[:id])
    render json: bus_stop, status: :ok
  end

  def create
    bus_stop = BusStop.new(bus_stop_params)

    if bus_stop.save
      render json: bus_stop, status: :ok
    else
      render json: bus_stop.errors, status: :bad_request
    end
  end

  private

    def bus_stop_params
      params
        .require(:bus_stop)
        .permit(:atcocode, :mode, :name, :stop_name, :bearing, :smscode, :locality, :indicator, :longitude, :latitude, :distance)
    end
end
