class BusStop < ApplicationRecord
  before_save :uppercase_bearing

  has_many :locations, dependent: :destroy

  validates :atcocode, presence: true # TODO: MAKE UNIQUE
  validates :mode, inclusion: { in: ["bus"] }
  validates :name, length: { minimum: 3 }
  validates :stop_name, length: { minimum: 3 }
  validates :bearing, length: { in: 1..2 }
  validates_format_of :bearing, :with => /[SENW]+/i
  validates :latitude, presence: true, numericality: { only_float: true }
  validates :longitude, presence: true, numericality: { only_float: true }
  validates :distance, presence: true, numericality: { only_integer: true }
  validate :not_duplicate

  def not_duplicate
    bus_stops = BusStop.where(atcocode: atcocode).where(distance: distance)
    bus_stops = bus_stops.where(created_at: (Time.now - 1.minutes)..(Time.now + 1.minutes))
    unless bus_stops.empty?
      errors.add(:atcocode, "cannot be duplicate")
    end
  end
  
  def uppercase_bearing
    self.bearing = self.bearing.upcase
  end
end
