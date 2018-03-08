class Location < ApplicationRecord
  belongs_to :bus_stop
  
  validates :latitude, presence: true, numericality: {only_float: true}
  validates :longitude, presence: true, numericality: {only_float: true}
  validates :current_speed, presence: true, numericality: {only_float: true}
  validates :time, presence: true
  validate :location_in_the_past

  def location_in_the_past
    if time.present? && time > DateTime.now
      errors.add(:time, "cannot be in the future")
    end
  end

  def is_weekday
    # returns 0 to 6, Sunday to Saturday
    day = time.wday
    # if monday to friday
    return (1..5).include? day
  end

  scope :where_aimed_time, -> (time) { where("to_char(aimed_departure_time, 'HH24:MI') = '#{time}'") }
  scope :where_aimed_in_time_range, -> (starting, ending) { where("aimed_departure_time::time between '#{starting}'::time and '#{ending}'::time") }

  scope :where_weekday, lambda { |valid|
    if valid == true
      where("EXTRACT(DOW FROM \"aimed_departure_time\") = ANY('{1,2,3,4,5}'::int[])")
    else
      where("EXTRACT(DOW FROM \"aimed_departure_time\") = ANY('{0,6}'::int[])")
    end
  }

  scope :average_delay, -> { average(:delay) }
  # scope :where_weekend, -> (date, valid) {valid == true ? where("EXTRACT(DOW FROM TIMESTAMP '2001-02-16 20:38:40') == ANY('{1,2,3,4,5}'::int[])") : where("EXTRACT(DOW FROM TIMESTAMP '2001-02-16 20:38:40') == ANY('{0,6}'::int[])") }

  def expected_time
    (time.to_time - delay.minutes).to_datetime
  end
end
