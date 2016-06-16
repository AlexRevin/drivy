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

    def commission
      profit = price * 0.3
      [:insurance_fee, :assistance_fee, :drivy_fee].inject({}) do |sum, n|
        case n
        when :insurance_fee
          sum[n] = (profit - (profit *= 0.5)).ceil # no extra penny for gangsters
        when :assistance_fee
          sum[n] = (profit - (profit -= 100 * duration )).ceil
        else
          # this is obviously not correct, watch Office Space movie
          # for careful accounting, matters of cents do count as well
          sum[n] = profit.floor
        end
        sum
      end
    end

    def price
      daily_prices = []
      (1..duration).each do |day|
        case day
        when 1
          daily_prices << car.price_per_day
        when 2..4
          daily_prices << car.price_per_day * 0.9
        when 5..10
          daily_prices << car.price_per_day * 0.7
        else
          daily_prices << car.price_per_day * 0.5
        end
      end
      daily_prices.inject(:+).floor + (distance * car.price_per_km)
    end
  end
end