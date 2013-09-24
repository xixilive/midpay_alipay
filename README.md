# Midpay::Alipay

[![Code Climate](https://codeclimate.com/github/xixilive/midpay_alipay.png)](https://codeclimate.com/github/xixilive/midpay_alipay)

Payment strategy for Alipay(支付宝 https://alipay.com) base on Midpay Middleware.

## Installation

Add this line to your application's Gemfile:

    gem 'midpay_alipay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install midpay-alipay

## Usage

In your application initialize

```ruby
  require 'midpay_alipay'
  use Midpay::Strategies::Alipay, APPID, APPSECRET, :request_params_proc => {|params| 
    order = Order.find(params['order_id'])
    order.to_alipay_params
  }
```

In your routes:

```ruby
  map '/midpay/alipay/callback' => 'payment#callback' 
```


Type following URL in your browser

```
  http://DOMAIN.COM/midpay/alipay?order_id=123
```

And your broswer will navigate to Alipay Casher page,

Then, handle the callback phase in your controller

```ruby
  def callback
    strategy = request.env['midpay.strategy']
    callback_data = request.env['midpay.callback'] # A Midpay::PaymentInfo object
    if callback_data.success?
      order = Order.find(callback_data.raw_data[:out_trade_no])
      order.paid!
    end

    p callback_data.to_hash
    p callback_data.to_json
    # ....
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
