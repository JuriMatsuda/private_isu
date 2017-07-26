require 'mysql2'
require 'fileutils'

def config
  @config ||= {
      db: {
          host: ENV['ISUCONP_DB_HOST'] || 'localhost',
          port: ENV['ISUCONP_DB_PORT'] && ENV['ISUCONP_DB_PORT'].to_i,
          username: ENV['ISUCONP_DB_USER'] || 'root',
          password: ENV['ISUCONP_DB_PASSWORD'],
          database: ENV['ISUCONP_DB_NAME'] || 'isuconp',
      },
  }
end

def db
  @client ||= Mysql2::Client.new(
      host: config[:db][:host],
      port: config[:db][:port],
      username: config[:db][:username],
      password: config[:db][:password],
      database: config[:db][:database],
      encoding: 'utf8mb4',
      reconnect: true,
  )
  @client.query_options.merge!(symbolize_keys: true, database_timezone: :local, application_timezone: :local)
  @client
end

ids = db.query('SELECT `id` FROM `posts` order by id asc ').to_a.map {|h| h[:id] }
ids.each do |id|
  post = db.query("SELECT `id`,`mime`, `imgdata` FROM `posts` WHERE id = #{id} LIMIT 1").first
  ext = ""
  if post[:mime] == "image/jpeg"
    ext = ".jpg"
  elsif post[:mime] == "image/png"
    ext = ".png"
  elsif post[:mime] == "image/gif"
    ext = ".gif"
  end

  path = "../public/image/#{post[:id]}#{ext}"

  File.write(path, post[:imgdata])
  print '.'
end
