class Spree::Calculator::Shipping::PostalService < Spree::ShippingCalculator
  preference :weight_table,    :string,  default: '1 2 5 10 20'
  preference :price_table,     :string,  default: '6 9 12 15 18'
  preference :price_table_by_weight_unit, :boolean, default: false
  preference :max_item_weight_enabled, :boolean, default: true
  preference :max_item_weight, :decimal, default: 18
  preference :max_item_width_enabled, :boolean, default: true
  preference :max_item_width,  :decimal, default: 60
  preference :max_item_length_enabled, :boolean, default: true
  preference :max_item_length, :decimal, default: 120
  preference :max_total_weight_enabled, :boolean, default: false
  preference :max_total_weight,:decimal, default: 0
  preference :min_total_weight_enabled, :boolean, default: false
  preference :min_total_weight, :decimal,  default: 0
  preference :max_price_enabled, :boolean, default: false
  preference :max_price,       :decimal, default: 120
  preference :handling_max,    :decimal, default: 50
  preference :handling_fee,    :decimal, default: 10
  preference :default_weight,  :decimal, default: 1
  preference :zipcode_handling,:string,  default: nil
  preference :zipcode_separator, :string,  default: '|'
  preference :zipcodes,        :string,  default: nil

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
                  :preferred_zipcode_separator,
                  :preferred_zipcodes,
                  :preferred_max_total_weight,
                  :preferred_max_item_weight_enabled,
                  :preferred_max_item_width_enabled,
                  :preferred_max_item_length_enabled,
                  :preferred_max_total_weight_enabled,
                  :preferred_max_price_enabled,
                  :preferred_price_table_by_weight_unit,
                  :preferred_min_total_weight_enabled,
                  :preferred_min_total_weight

  def self.description
    'Postal'
    # Spree.t(:postal_service)
  end

  def self.register
    super
    # ShippingMethod.register_calculator(self)
  end

  def order_total_weight(order)
    return @total_weight if @total_weight
    @total_weight = 0
    order.line_items.each do |item| # determine total price and weight
      @total_weight += item.quantity * (item.variant.weight  || self.preferred_default_weight)
    end
    return @total_weight
  end

  def zipcodes
    return @zipcodes if @zipcodes
    return [""] if self.preferred_zipcodes.blank? || self.preferred_zipcode_separator.blank?

     self.preferred_zipcodes.downcase.split(self.preferred_zipcode_separator)
  end

  def handle_zipcode?(order)
    return true if self.preferred_zipcode_handling.blank?
    result = false
    zipcodes.each do |zipcode|
      if(self.preferred_zipcode_handling == 'exact')
        result = zipcode == order.ship_address.zipcode.downcase
      end
      if(self.preferred_zipcode_handling == 'starts')
        result = order.ship_address.zipcode.downcase.start_with?(zipcode)
      end
      if(self.preferred_zipcode_handling == 'ends')
        result = order.ship_address.zipcode.downcase.end_with?(zipcode)
      end
      if(self.preferred_zipcode_handling == 'contains')
        result = order.ship_address.zipcode.downcase.include?(zipcode)
      end
      break if result
    end
    return result
  end

  def item_oversized?(variant)
    sizes = [variant.width ? variant.width : 0, variant.depth ? variant.depth : 0, variant.height ? variant.height : 0].sort.reverse
    return true if sizes[0] > self.preferred_max_item_length # longest side
    return true if sizes[1] > self.preferred_max_item_width  # second longest side
    return false
  end

  def total_overweight?(order)
    return false if !self.preferred_max_total_weight_enabled
    return order_total_weight(order) > self.preferred_max_total_weight
  end

  def total_underweight?(order)
    return false if !self.preferred_min_total_weight_enabled
    return order_total_weight(order) <= self.preferred_min_total_weight
  end

  def available?(package_contents)
    variants = package_contents.map(&:variant)
    variants.each do |variant| # determine if weight or size goes over bounds
      return false if variant.weight && variant.weight > self.preferred_max_item_weight # 18
      return false if item_oversized? variant
    end
    return false if !handle_zipcode?(variants)
    return false if total_overweight?(variant)
    return false if total_underweight?(variant)
    return true
  end

  # as order_or_line_items we always get line items, as calculable we have Coupon, ShippingMethod or ShippingRate
  def compute(package)
    order = package.order

    total_price, total_weight, shipping = 0, 0, 0
    prices = self.preferred_price_table.split.map { |price| price.to_f }

    order.line_items.each do |item| # determine total price and weight
      total_weight += item.quantity * (item.variant.weight || self.preferred_default_weight)
      total_price  += item.price * item.quantity
    end

    logger.debug "Weight " + total_weight.to_s
    logger.debug "Price " + total_price.to_s

    return 0.0 if self.preferred_max_price_enabled && total_price > self.preferred_max_price

    # determine handling fee
    handling_fee = self.preferred_handling_max < total_price ? 0 : self.preferred_handling_fee

    weights = self.preferred_weight_table.split.map { |weight| weight.to_f }

    while total_weight > weights.last # in several packages if need be
      total_weight -= weights.last
      if(self.preferred_price_table_by_weight_unit)
        shipping += prices.last * weights.last
      else
        shipping += prices.last
      end
    end

    index = weights.length - 2
    while index >= 0
      break if total_weight > weights[index]
      index -= 1
    end

    if(self.preferred_price_table_by_weight_unit)
      shipping += prices[index + 1] * total_weight
    else
      shipping += prices[index + 1]
    end
    logger.debug "Shipping " + shipping.to_s

    return shipping + handling_fee
  end
end
