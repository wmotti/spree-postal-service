class Spree::Calculator::PostalService < Spree::Calculator
  preference :weight_table,    :string,  default: '1 2 5 10 20'
  preference :price_table,     :string,  default: '6 9 12 15 18'
  preference :max_item_weight, :decimal, default: 18
  preference :max_item_width,  :decimal, default: 60
  preference :max_item_length, :decimal, default: 120
  preference :max_total_weight,:decimal, default: 0
  preference :max_price,       :decimal, default: 120
  preference :handling_max,    :decimal, default: 50
  preference :handling_fee,    :decimal, default: 10
  preference :default_weight,  :decimal, default: 1
  preference :zipcode_handling,:string,  default: nil
  preference :zipcode,         :string,  default: nil

  attr_accessible :preferred_weight_table,
                  :preferred_price_table,
                  :preferred_max_item_weight,
                  :preferred_max_item_width,
                  :preferred_max_item_length,
                  :preferred_max_price,
                  :preferred_handling_max,
                  :preferred_handling_fee,
                  :preferred_default_weight,
                  :preferred_zipcode_handling,
                  :preferred_zipcode,
                  :preferred_max_total_weight

  def self.description
    'Postal'
    # Spree.t(:postal_service)
  end

  def self.register
    super
    # ShippingMethod.register_calculator(self)
  end

  def order_total_weight(order)
    total_weight = 0
    order.line_items.each do |item| # determine total price and weight
      total_weight += item.quantity * (item.variant.weight  || self.preferred_default_weight)
    end
    return total_weight
  end

  def handle_zipcode?(order)
    return true if self.preferred_zipcode_handling.blank?

    if(self.preferred_zipcode_handling == 'exact')
      return self.preferred_zipcode.downcase == order.ship_address.zipcode.downcase
    end
    if(self.preferred_zipcode_handling == 'starts')
      return order.ship_address.zipcode.downcase.start_with?(self.preferred_zipcode.downcase)
    end
    if(self.preferred_zipcode_handling == 'ends')
      return order.ship_address.zipcode.downcase.end_with?(self.preferred_zipcode.downcase)
    end
    if(self.preferred_zipcode_handling == 'contains')
      return order.ship_address.zipcode.downcase.include?(self.preferred_zipcode.downcase)
    end

    return true
  end

  def item_oversized? item
    return false if self.preferred_max_item_length == 0 && self.preferred_max_item_width == 0
    variant = item.variant
    sizes = [ variant.width ? variant.width : 0 , variant.depth ? variant.depth : 0 , variant.height ? variant.height : 0 ].sort!
    #puts "Sizes " + sizes.join(" ")
    return true if self.preferred_max_item_length > 0 && sizes[0] > self.preferred_max_item_length
    return true if self.preferred_max_item_width > 0 && sizes[0] > self.preferred_max_item_width
    return false
  end

  def total_overweight?(order)
    return false if self.preferred_max_total_weight == 0
    return order_total_weight(order) > self.preferred_max_total_weight
  end

  def available?(order)
    return false if !handle_zipcode?(order)
    order.line_items.each do |item| # determine if weight or size goes over bounds
      return false if self.preferred_max_item_weight > 0 && item.variant.weight && item.variant.weight > self.preferred_max_item_weight
      return false if item_oversized?(item)
    end
    return false if total_overweight?(order)
    return true
  end

  # as order_or_line_items we always get line items, as calculable we have Coupon, ShippingMethod or ShippingRate
  def compute(order)
    total_price, total_weight, shipping = 0, 0, 0
    prices = self.preferred_price_table.split.map { |price| price.to_f }

    order.line_items.each do |item| # determine total price and weight
      total_weight += item.quantity * (item.variant.weight || self.preferred_default_weight)
      total_price  += item.price * item.quantity
    end

    return 0.0 if total_price > self.preferred_max_price

    # determine handling fee
    handling_fee = self.preferred_handling_max < total_price ? 0 : self.preferred_handling_fee

    weights = self.preferred_weight_table.split.map { |weight| weight.to_f }

    while total_weight > weights.last # in several packages if need be
      total_weight -= weights.last
      shipping += prices.last
    end

    index = weights.length - 2
    while index >= 0
      break if total_weight > weights[index]
      index -= 1
    end
    shipping += prices[index + 1]

    return shipping + handling_fee
  end
end
