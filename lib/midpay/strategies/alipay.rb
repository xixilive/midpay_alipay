require 'midpay'
module Midpay
  module Strategies
    class Alipay
      require 'uri'
      require 'net/http'

      GATEWAY = "https://www.alipay.com/cooperate/gateway.do"
      NOTIFY_VERIFY_GATEWAY = "http://notify.alipay.com/trade/notify_query.do"

      include ::Midpay::Strategy

      set :sign_type, "MD5"
      set :_input_charset, "utf-8"

      def request_phase response
        response.write("You are being redirected to Alipay......")
        response.redirect ali_request_url
      end

      def callback_phase pi
        raise Midpay::Errors::InvalidSignature.new unless request_params[:sign] == request_params.sign(:sign_type){|hsh| ali_sign_str(hsh) }
        pi.extra = { :notify_verified => notify_verified?(request_params[:notify_id]) }
        pi.raw_data = request_params.symbolize_keys
        pi.success = (pi.raw_data['is_success'] == 'T' || pi.raw_data['trade_status'] == "TRADE_FINISHED")
      end

      def ali_request_url
        GATEWAY + "?" + ali_request_params.to_query
      end

      def ali_request_params
        params = request_data
        params.merge_if!(arguments.merge(partner: options.app_key, seller_id: options.app_key, notify_url: callback_url, return_url: callback_url))
        params.sign!(:sign, :sign_type) do |hsh|
          ali_sign_str(hsh)
        end
      end

      def ali_sign_str hash
        hash.reject{|k,v| [:sign_type, :sign].include?(k.to_sym) || v.to_s.empty? }.collect{|k,v| "#{k}=#{v}" }.sort.join("&") + options.app_secret
      end

      def notify_verified? id
        url = NOTIFY_VERIFY_GATEWAY + "?service=notify_verify&partner=#{options.app_key}&notify_id=#{id}"
        body = Net::HTTP.get_response(URI.parse(url)).body.gsub(/\s+/,'').downcase rescue nil
        body == 'true'
      end
    end
  end
end
::Midpay[:alipay] = ::Midpay::Strategies::Alipay