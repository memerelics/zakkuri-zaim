# coding: utf-8
class ZaimApi # < ActiveRecord::Base #NOTE
  class ResponseError < StandardError; end
  class UnauthorizedError < StandardError; end

  attr_accessor :consumer, :token, :token_secret

  def initialize(token, token_secret)
    @consumer = OAuth::Consumer.new($setting.Consumer_Key, $setting.Consumer_Secret,
                                    #site: 'https://api.zaim.net/',
                                    request_token_path: $setting.Request_token_URL,
                                    authorize_path: $setting.Authorize_URL,
                                    access_token_path: $setting.Access_token_URL)
    @token = token
    @token_secret = token_secret
  end

  # Zaim APIを介して記録を行う
  def pay!(category_id, genre_id, price)
    price = price.to_i.abs*-1 # 正負どちらで渡されようと負値に変換
    input = {
      category_id: category_id,
      genre_id: genre_id,
      price: price,
      date: Time.now.strftime("%Y-%m-%d")
    }
    res = access_token.post("https://api.zaim.net/v1/pay/create.json", input)
    raise UnauthorizedError if res.class == Net::HTTPUnauthorized
    raise ResponseError if res.code != "200"
  end

  def access_token
    @at ||= OAuth::AccessToken.from_hash(self.consumer,
                                         oauth_token: self.token,
                                         oauth_token_secret: self.token_secret)
  end
end
