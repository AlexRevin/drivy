require "json"

module Util
  class Loader
    attr_accessor :cars, :rentals, :rental_modifications
    
    def initialize file_name
      @raw_data = JSON.parse IO.read(file_name) 
    end

    def cars
      @cars ||= @raw_data["cars"].map{|item| Models::Car.new(item)}
    end

    def rentals
      @rentals ||= @raw_data["rentals"].map{|item| Models::Rental.new(item)} 
    end

    def rental_modifications
      @rental_modifications ||= @raw_data["rental_modifications"].map{|item| Models::RentalModification.new(item)}
    end
  end
end