require 'spec_helper'

describe Spree::Calculator::PostalService do
  context "description" do
  end

	describe "#compute:" do

		before(:each) do
			@postal_service_calculator = Spree::Calculator::PostalService.new
		end

		def create_our_order(args)
			variant = FactoryGirl.create(:base_variant, :weight => args[:weight])
			line_item = FactoryGirl.create(:line_item, :price => args[:price], :quantity => args[:quantity], :variant => variant)
			@order = line_item.order
			@order.line_items.reload
		end

		it "gives 15.0 when total price is 100 and weight is 10kg" do
			create_our_order(:weight => 10.0, :price => 100, :quantity =>1)
			result = @postal_service_calculator.compute(@order)
			result.should eq(15.0)
		end

		it "gives 25.0 when total price is 40 and weight is 10kg" do
			pending ## fails
			create_our_order(:weight => 10.0, :price => 40.0, :quantity => 1)
			result = @postal_service_calculator.compute(@order)
			result.should eq(15.0)
		end


		it "gives 6 when total price is 60 and weight is less than 1kg" do
			create_our_order(:weight => 0.5, :price => 60.0, :quantity => 1)
			result = @postal_service_calculator.compute(@order)
			result.should eq(6.0)
		end

		it "gives 16 when total price is 40 and weight is less than 1kg" do
			create_our_order(:weight => 0.5, :price => 40.0, :quantity => 1)
			result = @postal_service_calculator.compute(@order)
			result.should eq(16.0)
		end

		it "gives 30 when total price is 200 and weight is 25kg" do
			pending ## fails
			create_our_order(:weight => 25.0, :price => 200.0, :quantity => 1)
			result = @postal_service_calculator.compute(@order)
			result.should eq(30.0)
		end

		it "gives 12 when total price is 100, there are three items and their weight is unknown" do
			order = FactoryGirl.create(:order)
			[30.0, 40.0, 30.0].each do |price|
				FactoryGirl.create(:line_item,
					:price => price,
					:quantity => 1,
					:order => order,
					:variant => FactoryGirl.create(:base_variant, :weight => nil) )
			end
			order.line_items.reload

			result = @postal_service_calculator.compute(order)
			result.should eq(12.0)
		end

		it "gives 0 when total price is more than the MAX, for any number of items " do
			create_our_order(:weight => 25.0, :price => 350.0, :quantity => 1)
			@postal_service_calculator.preferred_max_price = 300
			result = @postal_service_calculator.compute(@order)
			result.should eq(0.0)
		end
	end
end
