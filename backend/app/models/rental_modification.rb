require "date"
require "forwardable" # standard lib

module Models
  class RentalModification < ::Models::Rental
    extend Forwardable

    # rental modification does not know anything about car, but we need it, so we'll delegate it to rental 
    def_delegator :@rental, :car, :car

    attr_accessor :rental_id
    attr_accessor :rental

    # There also should be a state attriubute, as there should be a way
    # to distinguish applied renewals from new ones

    # fetching data not specified in modification from rental
    [:start_date, :end_date, :distance, :deductible_reduction].each do |method_sym|
      define_method(method_sym) do 
        self.instance_variable_get("@#{method_sym}") || rental.send(method_sym)
      end
    end

    def initialize data
      data.each_pair do |k, v| 
        self.send "#{k}=".to_sym , v
      end
      @transactions = []
    end

    # we calculate deltas from rental here, so it's different
    def distribute_funds!
      actors.each do |destination|
        delta = case destination
        when :driver
          -(rental.driver_price - driver_price)
        when :owner
          rental.to_owner - to_owner
        when :insurance
          rental.commission[:insurance_fee] - commission[:insurance_fee]
        when :assistance
          rental.commission[:assistance_fee] - commission[:assistance_fee]
        when :drivy
          rental.drivy_profit - drivy_profit
        end
        @transactions << Models::Transaction.new(item: self, destination: destination, amount: -delta)
      end
      # this is important as each further modification should work with updated data
      update_rental!
    end

    def update_rental!
      [:start_date, :end_date, :distance, :deductible_reduction].each do |field|
        rental.send "#{field}=".to_sym, self.send(field)
      end
    end

    def to_hash
      {
        id: id,
        rental_id: rental_id,
        actions: transactions.map(&:to_hash)
      }
    end
  end
end