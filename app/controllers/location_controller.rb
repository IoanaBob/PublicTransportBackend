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
      else
        render json: location.errors, status: :bad_request
      end
    end
  end

  private

    def location_params
      # It's mandatory to specify the nested attributes that should be whitelisted.
      # If you use `permit` with just the key that points to the nested attributes hash,
      # it will return an empty hash.
      params
        .require(:location)
        .permit(:latitude, :longitude, :time, :current_speed, :note)
    end
end