require "json"

# require app structure
Dir.glob(File.join(__dir__, '..', 'app', '**', '*.rb'), &method(:require))

# load data into classes
loader = Util::Loader.new File.join(__dir__, "data.json")

# link rentals with car
rentals_with_cars = loader.rentals.map do |rental|
  rental.car = loader.cars.find{|car| car.id == rental.car_id}

  # linking rentals and rental_modifications
  rental.rental_modifications = loader.rental_modifications.select{|rm| 
    rm.rental_id == rental.id
  }.map{|modification| 
    modification.rental = rental; modification
  }
  rental
end

# get file path first in order to avoid ugly method call
new_file_path = File.join(__dir__, "output.json")

# writing to JSON file
Util::Writer.write new_file_path do |hash|
  # get all modifications from all rentals
  modifications = rentals_with_cars.map(&:rental_modifications).flatten
  hash["rental_modifications"] = modifications.inject([]) do |sum, n|
    n.distribute_funds!
    sum << n.to_hash
  end
end
