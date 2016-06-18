module Models
  class Transaction
    attr_accessor :rental
    attr_accessor :destination, :amount

    # all required data
    def initialize(rental:, destination:, amount:)
      @rental = rental
      @destination = destination
      @amount = amount
    end

    def to_hash
      {
        who: destination,
        type: amount > 0 ? "credit" : "debit",
        amount: amount.abs
      }
    end
  end
end