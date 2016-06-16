module Models
  class Car
    attr_accessor :id, :price_per_day, :price_per_km

    def initialize data
      data.each_pair do |k, v|
        self.send "#{k}=".to_sym, v
      end
    end
  end
end