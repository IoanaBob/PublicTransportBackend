require 'time'

class Validations
  def valid_time(time)
    if (/^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/).match(time)
      true
    elsif (/^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$/).match(time)
      true
    else
      false
    end
  end

  def valid_date(date)
    begin
      Time.parse(date)
      true
    rescue ArgumentError
      false
    end
  end
end