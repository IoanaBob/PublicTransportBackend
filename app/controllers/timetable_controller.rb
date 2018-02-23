class TimetableController < ApplicationController
  def index
    @timetable = {name: "Ioana", text: "Hello, I'm Ioana. How are you?"}
    render json: @timetable, status: :ok
  end
end
