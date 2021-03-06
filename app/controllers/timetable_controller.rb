class TimetableController < ApplicationController
  
  def hello
    render json: {hello: "Welcome to crowdsourced timetable API!"}, status: :ok
  end

  def all
    # TODO: check for valid atcocode ??
    # check for valid date and time input
    val = Validations.new()
    unless val.valid_time(params[:time])
      render json: { errors: [time: 'time not valid']}, status: :bad_request
      return
    end
    
    unless val.valid_date(params[:date])
      render json: { errors: [date: 'date not valid']}, status: :bad_request
      return
    end

    timetable = Timetable.new(atcocode: params[:atcocode], datetime: (params[:date] + ' ' + params[:time]))
    if timetable.schedule == []
      render json: { all: [] }, status: :empty
      return
    end
    schedule = timetable.add_delays_to_schedule
    render json: { all: schedule }, status: :ok
  end

  def all_of_bus_line
    # check for valid date and time input
    val = Validations.new()
    unless val.valid_time(params[:time])
      render json: { errors: [time: 'time not valid']}, status: :bad_request
      return
    end
    
    unless val.valid_date(params[:date])
      render json: { errors: [date: 'date not valid']}, status: :bad_request
      return
    end
    
    timetable = Timetable.new(atcocode: params[:atcocode], datetime: (params[:date] + ' ' + params[:time]), bus_line: params[:line])
    if timetable.schedule == []
      render json: { all: [] }, status: :empty
      return
    end
    schedule = timetable.add_delays_to_schedule
    render json: { all: schedule }, status: :ok
  end
end
