# Spree Postal Service

[![Build Status](https://travis-ci.org/futhr/spree-postal-service.png?branch=2-0-stable)](https://travis-ci.org/futhr/spree-postal-service)
[![Dependency Status](https://gemnasium.com/futhr/spree-postal-service.png)](https://gemnasium.com/futhr/spree-postal-service)
[![Coverage Status](https://coveralls.io/repos/futhr/spree-postal-service/badge.png?branch=2-0-stable)](https://coveralls.io/r/futhr/spree-postal-service)

A postal service is delivers based on weight only(*). Like most post services in europe will.

This spree extension adds a spree-calculator to model this.

**Other features:**

- Size and weight restrictions by item and by order can be specified
- You can also add zip code restrictions
- You specify a weight/price table
- Prices in the price table can be by weight unit (kg)
- Handling fee may be added ( with a maximum when it won't be applied anymore)
- Multi-parcel shipments are automatically created
- You can specify a maximum order price, orders over this will not be charged

Off course this relies on your weight data to be correct (and if you want the restrictions to work, the size data too).
Use the same measurements as in the product info page.

(*) You may install several ShippingMethods for (usually) different countries.

## Usage

Add to your `Gemfile`:
```ruby
gem 'spree_postal_service',  github: 'futhr/spree-postal-service', branch: '2-0-stable'
```

Go to admin interface

`http://localhost:3000/admin/shipping_methods/new`

and use _Postal Service_ as calculator.

The size/weight _table_ must have the same amount of (space separated) entries.

## Settings

- Weights "table": A space separated list of weights (must have the same amount of entries as the Prices "table")
- Prices "table": A space separated list of prices (must have the same amount of entries as the Weights "table")
- Price by weight unit?: Indicates if the prices in the price list are by weight unit. If true, then the weight of the order will be multiplied by the price setted for that weight value.

  - Ex: Weights: "1 2 5"; Prices: "5 3 2"; Price By Weight Unit? true. If we have a order with a weight of 2.5kg then the total price will be 7,5. If the "Price By Weight Unit?" was setted to false, the total price would be 3.

- Max weight of one item enable?: Enables the "Max weight of one item" verification.
- Max weight of one item: Max weight of any item in the order may have to enable the shipping method.
- Max width of one item enabled?: Enables the "Max width of one item" verification.
- Max width of one item: Max width that any item in the order may have to enable the shipping method.
- Max length of one item enabled?: Enables the "Max length of one item" verification.
- Max length of one item: Max length that any item in the order may have to enable the shipping method.
- Max total weight enabled?: Enables the "Max total weight" verification.
- Max total weight: Max total weight of the order to enable the shipping method.
- Min total weight enabled?: Enables the "Min total weight" verification.
- Min total weight: Min total weight of the order to enable the shipping method.
- Maximum total of the order enabled?: Enables the "Maximum total of the order" verification.
- Maximum total of the order: Order price after which the shipping cost will be 0.
- Amount, over which handling fee won't be applied: Self explained.
- Handling fee: The handling fee.
- Default weight: The default weight to be used on any product that doesn't have a weight value defined.
- Zipcode handling (empty field - does not apply, exact, starts, ends, contains): When the value is one of "exact", "starts", "ends" or "contains", it will validate the zipcode of the shipping adress and enable the shipping method.

  - When the value is "starts", the shipping adress zipcode must equal to any of the defined zipcodes in the Zipcode(s) field;
  - When the value is "starts", the shipping adress zipcode must start with any of the defined zipcode "parts" in the Zipcode(s) field;
  - When the value is "ends", the shipping adress zipcode must end with any of the defined zipcode "parts" in the Zipcode(s) field;
  - When the value is "contains", the shipping adress zipcode must contains any of the defined zipcode "parts" in the Zipcode(s) field;

- Zipcode separator: The separator to be used when specifying several zipcodes in the "Zipcode(s)" field.
- Zipcode(s): Zipcode(s), or parts of them, to be used to check if the shipping method is available. When using several zipcodes, the separator must be the one indicated in the "Zipcode separator field".

## Example

With the default settings (measurements in kg and cm):

- Max weight of one item enabled: true
- Max weight of one item: 18
- Max width of one item enabled: true
- Max width of one item: 60
- Max length of one item enabled: true
- Max length of one item: 90
- Default weight: 1kg (applies when product weight is 0)
- Handling fee: 10
- Amount, over which handling fee won't be applied: 50
- Max total of the order: 120.0
- Max total weight of the order enabled: false
- Max total weight of the order: 120.0
- Min total weight of the order enabled: false
- Min total weight the order: 0
- Weights (space separated): 1 2 5 10 20
- Prices (space separated):  6 9 12 15 18
- Price by weight unit?: false
- Zipcode handling:
- Zipcode separator: |
- Zipcode:

## Applies?

The Shipping method does not apply to the order if:

- Any items weighs more than 18 Kg
- Any item is longer than 90 cm
- Any items second longest side (width) is over 60cm. Eg a 70x70x20 item.

## Costs

- Items weighing 10 kg of worth 100 Euros will cost 15 Euros
- Items weighing 10 kg of worth 40 Euros will cost 25 Euros (15 + 10 handling)
- Items weighing less than 1 kg of worth 60 Euros will cost 6 Euros
- Items weighing less than 1 kg of worth 40 Euros will cost 16 Euros (6 + 10)
- Items weighing 25 kg of worth 200 Euros will cost 30 Euros (2 packages, 18 + 12 euro)
- 3 items without weight information of worth 100 euros will cost 12 Euro
- Any amount of items costing more than the max_price will cost 0 Euro

## Contributing

In the spirit of [free software][1], **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using prerelease versions
* by reporting [bugs][2]
* by suggesting new features
* by writing [translations][4]
* by writing or editing documentation
* by writing specifications
* by writing code (*no patch is too small*: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving [issues][2]
* by reviewing patches

Starting point:

* Fork the repo
* Clone your repo
* Run `bundle install`
* Run `bundle exec rake test_app` to create the test application in `spec/test_app`
* Make your changes
* Ensure specs pass by running `bundle exec rspec spec`
* Submit your pull request

Copyright (c) 2013 [Torsten Rüger][5] and [contributors][6], released under the [New BSD License][3]

[1]: http://www.fsf.org/licensing/essays/free-sw.html
[2]: https://github.com/futhr/spree-postal-service/issues
[3]: https://github.com/futhr/spree-postal-service/blob/2-0-stable/LICENSE.md
[4]: http://www.localeapp.com/projects/4917
[5]: https://github.com/dancinglightning
[6]: https://github.com/futhr/spree-postal-service/contributors
