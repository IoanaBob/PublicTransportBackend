Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "timetable#hello"

  get "/locations", to: "location#index"
  get "/location/:id", to: "location#show", as: "show_location"
  post "/location/:bus_stop_id", to: "location#create"

  get "/bus_stops", to: "bus_stop#index"
  get "/bus_stop/:id", to: "bus_stop#show", as: "show_bus_stop"
  post "/bus_stop", to: "bus_stop#create"

  get "/timetable/:atcocode/:date/:time", to: "timetable#all"
  get "/timetable/:atcocode/:date/:time/:line", to: "timetable#all_of_bus_line"
end
