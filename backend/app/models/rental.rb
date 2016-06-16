require "date"

module Models
  class Rental
    attr_accessor :car
    attr_accessor :id, :car_id, :start_date, :end_date, :distance

    def initialize data
      data.each_pair do |k, v| 
        self.send "#{k}=".to_sym , v
      end
    end

    def start_date=(date_str)
      @start_date = Date.parse date_str
    end

    def end_date=(date_str)
      @end_date = Date.parse date_str
    end

    def duration
      (@end_date - @start_date).to_i + 1 # last day included
    end

    def price
      (car.price_per_day * duration) + (distance * car.price_per_km)
    end
  end
end