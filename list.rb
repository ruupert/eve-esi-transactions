require 'esi-ruby'
require 'pp'
require 'pg'
require 'base64'
require 'curb'
require 'json'

$conn = PG.connect( user: 'eve', dbname: 'eve' )




def main

puts "<html><head><title>transactions</title><style>
body {
     background: black;
     color: white;
}
table {width: 100%; border-spacing: 0}
td, th { padding: 0 0.2em }
td {
   padding-top: 2px;
   padding-bottom: 2px;
   border-bottom: gray;
   border-bottom-width: 1px;
   border-bottom-style: dotted;
}
.aright {
   text-align: right;
}
tr.red td {
       color: red;
}
tr.green td {
         color: green;
}
td {
   padding-left: 20px;
}
</style></head><body><table>"

  types = $conn.exec( ' select a."typeName", a.type_id from (select "invTypes"."typeName", "invTypes"."typeID", foo.type_id from evesde."invTypes", (select distinct(type_id) as type_id from transactions) as foo where foo.type_id="invTypes"."typeID") as a; ')
  key = types.collect{|row| row["type_id"] }
  value = types.collect{|row| row["typeName"] }
  type_hash = {}
  key.each_with_index { |k,i| type_hash[k]=value[i] }

  types = $conn.exec ('select a."stationName", a."stationID" from (select "staStations"."stationName", "staStations"."stationID", foo.location_id from evesde."staStations", (select distinct(location_id) as location_id from transactions) as foo where foo.location_id="staStations"."stationID") as a;')
  key = types.collect{|row| row["stationID"] }
  value = types.collect{|row| row["stationName"] }
  station_hash = {}
  key.each_with_index { |k,i| station_hash[k]=value[i] }

  #  puts type_hash
  $conn.exec( "SELECT * FROM public.transactions order by date desc" ) do |c|
    puts "<tr><th>date</th><th></th><th>type_name</th class='aright'><th class='aright'>quantity</th><th class='aright'>price</th><th class='aright'>total</th><th>client_name</th><th>station_name</th></tr>"
    c.each do |row|
      if row['is_buy'] == 't'
        puts "<tr class='red'>"
      else
        puts "<tr class='green'>"
      end
      #           date                              icon                                           typename                                           qty                                    price                                           total
      puts "<td>#{row['date']}</td><td><img src='Types/#{row['type_id']}_32.png'/></td><td>#{type_hash[row['type_id']]}</td><td class='aright'>#{row['quantity']}</td><td class='aright'>#{row['unit_price']}</td><td class='aright'>#{row['total_price']}</td><td>#{row['client_id']}</td><td>#{station_hash[row['location_id']]}</td></tr>"
      
#      puts "#{type_hash[row['type_id']]}\t\tqty: #{row['quantity']}\tprice: #{row['unit_price']}\ttotal: #{row['total_price']}\t #{row['date']} "
    end
    puts "</table></body></html>"

  end
  
end

main()



