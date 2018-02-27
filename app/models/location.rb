class Location < ApplicationRecord
  validates :latitude, presence: true, numericality: {only_float: true}
  validates :longitude, presence: true, numericality: {only_float: true}
  validates :current_speed, presence: true, numericality: {only_float: true}
  validates :time, presence: true
  validate :location_in_the_past
  belongs_to :bus_stop

  def location_in_the_past
    if time.present? && time > DateTime.now
      errors.add(:time, "cannot be in the future")
    end
  end
end
