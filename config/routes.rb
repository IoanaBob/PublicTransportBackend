Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # root "timetable#all"

  get "/locations", to: "location#index"
  get "/location/:id", to: "location#show"
  post "/location/:bus_stop_id", to: "location#create"

  get "/bus_stops", to: "bus_stop#index"
  get "/bus_stop/:id", to: "bus_stop#show"
  post "/bus_stop", to: "bus_stop#create"

  get "/timetable/:atcocode/:date/:time", to: "timetable#all"
  get "/timetable/:atcocode/:date/:time/:line", to: "timetable#all_of_bus_line"
end
