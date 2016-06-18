require "date"

module Models
  class Rental
    attr_accessor :car
    attr_accessor :id, :car_id, :start_date, :end_date, :distance, :deductible_reduction
    attr_accessor :transactions
    attr_accessor :rental_modifications

    # Should be read from config or database, but constants are fine for now
    DEDUCTIBLE_FEE_PER_DAY = 400
    PROFIT_MARGIN     = 0.3
    INSURANCE_PERCENT = 0.5
    ASSISTANCE_FEE    = 100
    DAY_DISCOUNTS     = {
      "2..4"  => 0.9,
      "5..10" => 0.7,
      "10+"   => 0.5
    }

    def initialize data
      data.each_pair do |k, v| 
        self.send "#{k}=".to_sym , v
      end
      @transactions = []
    end

    def start_date=(date)
      @start_date = date.is_a?(Date) ? date : Date.parse(date)
    end

    def end_date=(date)
      @end_date = date.is_a?(Date) ? date : Date.parse(date)
    end

    def duration
      (end_date - start_date).to_i + 1 # last day included
    end

    def actors
      [ :driver, :owner, :insurance, :assistance, :drivy ]
    end

    def distribute_funds!
      actors.each do |destination|
        amount = case destination
        when :driver
          -driver_price
        when :owner
          to_owner
        when :insurance
          commission[:insurance_fee]
        when :assistance
          commission[:assistance_fee]
        when :drivy
          drivy_profit
        end
        @transactions << Models::Transaction.new(item: self, destination: destination, amount: amount)
      end
    end

    def deductible_fee
      if deductible_reduction
        duration * DEDUCTIBLE_FEE_PER_DAY
      else
        0
      end
    end

    def driver_price
      price + deductible_fee
    end

    def drivy_profit
      commission[:drivy_fee] + deductible_fee
    end

    def to_owner
      price - (price * PROFIT_MARGIN).floor
    end

    def commission
      income = price - to_owner
      [:insurance_fee, :assistance_fee, :drivy_fee].inject({}) do |sum, n|
        case n
        when :insurance_fee
          sum[n] = (income - (income *= INSURANCE_PERCENT)).ceil # no extra penny for gangsters
        when :assistance_fee
          sum[n] = (income - (income -= ASSISTANCE_FEE * duration )).ceil
        else
          # this is obviously not correct, watch Office Space movie
          # for careful accounting, matters of cents do count as well
          sum[n] = income.floor
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
          daily_prices << car.price_per_day * DAY_DISCOUNTS["2..4"]
        when 5..10
          daily_prices << car.price_per_day * DAY_DISCOUNTS["5..10"]
        else
          daily_prices << car.price_per_day * DAY_DISCOUNTS["10+"]
        end
      end
      daily_prices.inject(:+).floor + (distance * car.price_per_km)
    end
  end
end