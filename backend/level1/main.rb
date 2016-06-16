require "json"

# require app structure
Dir.glob(File.join(__dir__, '..', 'app', '**', '*.rb'), &method(:require))

# load data into classes
loader = Util::Loader.new File.join(__dir__, "data.json")

# link rentals with car
rentals_with_cars = loader.rentals.map do |rental|
  rental.car = loader.cars.find{|car| car.id == rental.car_id}
  rental
end

# get file path first in order to avoid ugly method call
new_file_path = File.join(__dir__, "output.json")

# writing to JSON file
Util::Writer.write new_file_path do |hash|
  hash["rentals"] = rentals_with_cars.inject([]) do |sum, n|
    sum << {id: n.id, price: n.price}
  end
end
