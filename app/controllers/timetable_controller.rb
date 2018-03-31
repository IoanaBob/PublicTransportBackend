class TimetableController < ApplicationController
  
  def hello
    render json: {hello: "Welcome to crowdsourced timetable API!"}, status: :ok
  end

  def all
    if BusStop.where(atcocode: params[:atcocode]).empty?
      render json: { errors: [atcocode: 'bus stop could not be found'] }, status: :not_found
      return
    end
    # check for valid time input
    timetable = Timetable.new(atcocode: params[:atcocode], datetime: (params[:date] + ' ' + params[:time]))
    if timetable.schedule == []
      render json: [], status: :empty
      return
    end
    schedule = timetable.add_delays_to_schedule
    render json: schedule, status: :ok
  end

  def all_of_bus_line
    if BusStop.where(atcocode: params[:atcocode]).empty?
      render json: { errors: [atcocode: 'bus stop could not be found'] }, status: :not_found
      return
    end
    # check for valid time input
    timetable = Timetable.new(atcocode: params[:atcocode], datetime: (params[:date] + ' ' + params[:time]), bus_line: params[:line])
    if timetable.schedule == []
      render json: [], status: :empty
      return
    end
    schedule = timetable.add_delays_to_schedule
    render json: schedule, status: :ok
  end
end
