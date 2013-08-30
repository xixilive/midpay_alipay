require 'spec_helper'

describe Midpay::Strategies::Alipay do
  include Rack::Test::Methods

  let(:inner_app){
    lambda { |env| [200, {"Content-Type" => "text/html"}, ["body"]] }
  }

  let(:app){
    Midpay::Strategies::Alipay.new(inner_app, 
      :app_key => "APPKEY", 
      :app_secret => "APPSECRET", 
      :request_params_proc => Proc.new{|params|
        {
          :service => "trade_create_by_buyer",
          :seller_email => "seller@email.com",
          :out_trade_no => params['order_id'],
          :subject => "subject",
          :payment_type => '1',
          :logistics_type=>"EXPRESS",
          :logistics_fee => 0,#delivery_amount,
          :logistics_payment => "BUYER_PAY",
          :price => 1, #item_amount,
          :quantity=> 1,
          :body => "body",
          :discount=> 0, #-discount,
          :total_fee=> 1, #total_price,
          :show_url=> "http://127.0.0.1",
          :receive_name => "recipient",
          :receive_address => "address",
          :receive_zip => "post_code",
          :receive_phone => "phone"
        }
      }
    )
  }

  let(:query){
    'body=%E5%86%9C%E4%BA%BA%E7%89%B9%E4%BE%9B-%E6%96%B0%E6%98%A5%E7%A4%BC%E7%9B%92%E7%B3%BB%E5%88%97(%E6%B7%B1%E8%89%B2%E7%B3%BB%C2%B7%E5%86%AC%E4%BB%A4%E8%A1%A5%E7%9B%8A%E9%BB%91%E5%93%81%E8%87%BB%E9%80%89)&buyer_email=hxplove01%40126.com&buyer_id=2088702028771600&discount=0.00&gmt_create=2013-07-19+16%3A18%3A25&gmt_logistics_modify=2013-07-19+16%3A18%3A25&gmt_payment=2013-07-19+16%3A21%3A19&is_success=T&is_total_fee_adjust=N&logistics_fee=0.00&logistics_payment=BUYER_PAY&logistics_type=EXPRESS&notify_id=RqPnCoPT3K9%252Fvwbh3I72LfQlir9TXixOvcNML3lAnszC8nxIDtv6GPlhvNbRfSNHf4aS&notify_time=2013-07-19+16%3A21%3A25&notify_type=trade_status_sync&out_trade_no=51da5b6bbcc126678b000006&payment_type=1&price=0.01&quantity=1&receive_address=%E5%8C%97%E4%BA%AC%2C+%E5%8C%97%E4%BA%AC%E5%B8%82%2C+%E6%9C%9D%E9%98%B3%E5%8C%BA%2C+%E5%8C%97%E4%BA%AC%E6%9C%9D%E9%98%B3%E5%8C%BA%E5%9B%A2%E7%BB%93%E6%B9%96%E5%8C%97%E9%87%8C8%E5%8F%B7%E6%A5%BC5%E9%97%A8103%E5%AE%A4%2C+100011%2C+%E4%B8%A5%E6%96%87%2C+13671297531&receive_name=%E4%B8%A5%E6%96%87&receive_phone=13671297531&receive_zip=100011&seller_actions=SEND_GOODS&seller_email=info%40baoshutech.com&seller_id=2088401331137232&subject=%E5%86%9C%E4%BA%BA%E7%89%B9%E4%BE%9B-%E6%96%B0%E6%98%A5%E7%A4%BC%E7%9B%92%E7%B3%BB%E5%88%97(%E6%B7%B1%E8%89%B2%E7%B3%BB%C2%B7%E5%86%AC%E4%BB%A4%E8%A1%A5%E7%9B%8A%E9%BB%91%E5%93%81%E8%87%BB%E9%80%89)&total_fee=0.01&trade_no=2013071958435860&trade_status=WAIT_SELLER_SEND_GOODS&use_coupon=N&sign=402b1a2b5a3b29430379b9961130a1bd&sign_type=MD5'
  }

  let(:query_data){
    Hash[::Rack::Utils.unescape(query).split("&").collect{|i| i.split("=")}]
  }

  it 'on request phase' do
    get '/midpay/alipay?order_id=823456781235689'
    expect(last_response.headers['Location']).to eq("https://www.alipay.com/cooperate/gateway.do?_input_charset=utf-8&body=body&discount=0&logistics_fee=0&logistics_payment=BUYER_PAY&logistics_type=EXPRESS&notify_url=http%3A%2F%2Fexample.org%2Fmidpay%2Falipay%2Fcallback&out_trade_no=823456781235689&partner=APPKEY&payment_type=1&price=1&quantity=1&receive_address=address&receive_name=recipient&receive_phone=phone&receive_zip=post_code&return_url=http%3A%2F%2Fexample.org%2Fmidpay%2Falipay%2Fcallback&seller_email=seller%40email.com&seller_id=APPKEY&service=trade_create_by_buyer&show_url=http%3A%2F%2F127.0.0.1&sign=a76efa33d1bbbd4275422323173ae142&sign_type=MD5&subject=subject&total_fee=1")
  end

  it 'on callback phase' do
    get "/midpay/alipay/callback?#{query}"
    expect(last_request.env['midpay.strategy'].class).to eq(app.class)
    expect(last_request.env['midpay.callback'].pay).to eq("alipay")
    expect(last_request.env['midpay.callback'].raw_data).to eq(query_data)
    expect(last_request.env['midpay.callback'].success?).to be_true
  end
end