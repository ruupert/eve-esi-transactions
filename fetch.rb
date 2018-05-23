require 'esi-ruby'
require 'pp'
require 'pg'
require 'base64'
require 'curb'
require 'json'

$conn = PG.connect( user: 'eve', dbname: 'eve' )

def update_token(character)

  enc = Base64.strict_encode64("#{character['client_id']}:#{character['secret_key']}")
  json = '{"grant_type":"refresh_token","refresh_token":"'
  json = json + character['refresh_token']
  json = json + '"}'
    curl = Curl::Easy.http_post("https://login.eveonline.com/oauth/token") do |c|
    c.headers['Authorization'] = "Basic #{enc}"
    c.headers['Content-Type'] = "application/json"
    c.headers['Host'] = "login.eveonline.com"
    c.post_body = json
  end
  res = JSON.parse(curl.body_str)
  $conn.exec( "UPDATE characters SET access_token='#{res['access_token']}' WHERE name='#{character['name']}';" )
  return res
end




def main
  $conn.exec( "SELECT * FROM characters where expires_at < now();" ) do |chars|
    chars.each do |char|
      res = update_token(char)
      EsiClient.configure do |config|
        config.access_token = res['access_token']
      end

      begin
        opts = ''
        puts char['character_id']
          r = $conn.exec( "select coalesce(max(transaction_id), 0) as last_id from transactions where character_id=#{char['character_id'].to_i};" )
        api_instance = EsiClient::WalletApi.new
        
        pp r
        opts = {
          datasource: "tranquility", 
          from_id: r[0]['last_id'].to_i,
          user_agent: "my application", 
          x_user_agent: "my application" 
        }
        pp opts
        result = api_instance.get_characters_character_id_wallet_transactions(char['character_id'], opts)
        unless result.empty?
          result = Array(result)
          result.each do |item|
            begin
            i = item.to_hash
            $conn.exec("INSERT INTO transactions (character_id, 
                                               client_id, 
                                               date, 
                                               is_buy, 
                                               is_personal, 
                                               journal_ref_id, 
                                               location_id, 
                                               quantity, 
                                               transaction_id, 
                                               type_id, 
                                               unit_price) 
                                       VALUES (#{char['character_id']},
                                               #{i[:client_id]},
                                               '#{i[:date]}',
                                               '#{i[:is_buy]}',
                                               '#{i[:is_personal]}',
                                               #{i[:journal_ref_id]},
                                               #{i[:location_id]},
                                               #{i[:quantity]},
                                               #{i[:transaction_id]},
                                               #{i[:type_id]},
                                               #{i[:unit_price]}
                                       );") 

            rescue
              # do nothing
            end
          end
          
        end
        
        rescue EsiClient::ApiError => e
          puts "Exception when calling WalletApi->get_characters_character_id_wallet_transactions: #{e}"
        end
        
    end
  end
end



main()








