# coding: utf-8
require 'mysql2'
require 'mysql2-cs-bind'
require 'pp'
require 'redis'
require 'redis/namespace'
require 'redis-objects'
require 'json'

client = Mysql2::Client.new(
  host: '127.0.0.1',
  port: '3306',
  username: 'isucon',
  password: 'isucon',
  database: 'isucon5q',
  reconnect: true,
)
client.query_options.merge!(symbolize_keys: true)

#query = 'SELECT * FROM relations WHERE one = ?'
#relation = client.xquery(query, '3333').first
#pp relation

#query = 'SELECT id,user_id FROM entries limit 200000 offset 390000'
#count = 390000
#client.xquery(query).each do |entry|
#  #pp entry
#  #break;
#  query = 'UPDATE comments SET entry_user_id = ? WHERE entry_id = ?'
#  client.xquery(query, entry[:user_id], entry[:id])
#  count += 1
#  puts count
#end


#redis = Redis.new(:host => "127.0.0.1", :port => 6379)
#redis = Redis.new(:path => "/var/run/redis/redis.sock")

redis_connection = Redis.new(:path => "/var/run/redis/redis.sock")
#redis = Redis::Namespace.new(:footprints, :redis => redis_connection)
redis_footprints = Redis::Namespace.new(:footprints, :redis => redis_connection)
#redis_footprints_updated = Redis::Namespace.new(:footprints_updated, :redis => redis_connection)
#redis_footprints2 = Redis::Namespace.new(:footprints2, :redis => redis_connection)

#redis.set "foo", "bar"

#Redis.current = redis_footprints
#counter = Redis::Counter.new('counter_name')
#counter.increment  # or incr
#counter.decrement  # or decr
#counter.increment(3)
#puts counter.value

#Redis.current = redis_footprints2
#counter = Redis::Counter.new('counter_name')
#counter.increment  # or incr
#counter.decrement  # or decr
#counter.increment(3)
#puts counter.value

#Redis.current = redis_footprints
#fp_list = Redis::List.new(1, :maxlength => 50)
#fp_list << '2_20170930'
#fp_list << '3_20170930'
#fp_list << '4_20170930'
#fp_list.unshift('test')
#puts fp_list.values

query = <<SQL
SELECT user_id, owner_id, DATE(created_at) AS date, MAX(created_at) AS updated
FROM footprints
WHERE user_id = ?
GROUP BY user_id, owner_id, DATE(created_at)
ORDER BY updated DESC
LIMIT 50
SQL


#test = 'test-a'
#test = test.gsub(/-/, '_')
#puts test
#exit

#for i in 1..5000
for i in 3657..3657
#for i in 1..1
  #footprints = client.xquery(query, i).first
  #pp footprints
  Redis.current = redis_footprints
  fp_list = Redis::List.new(i, :maxlength => 50)
  pp fp_list.values
  exit
  puts i
  #Redis.current = redis_footprints_updated
  fp_updated = Redis::HashKey.new("#{i}_updated")
  client.xquery(query, i).each do |fp|
    date = fp[:date].to_s
    #pp date
    #date = date.gsub(/-/, '_')
    fp_list << "#{fp[:owner_id]}_#{date}"
    #fp_updated = Redis::Value.new("#{fp[:user_id]}_#{fp[:owner_id]}_#{date}")
    #fp_updated.value = fp[:updated].to_s
    fp_updated["#{fp[:owner_id]}_#{date}"] = fp[:updated].to_s
  end
  #puts fp_list.values
end

