module Models
  class Transaction
    attr_accessor :item
    attr_accessor :destination, :amount

    # all required data
    def initialize(item:, destination:, amount:)
      @item = item
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