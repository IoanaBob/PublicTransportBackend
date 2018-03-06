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

  def expected_time
    (time.to_time - delay.minutes).to_datetime
  end
end
