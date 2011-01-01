require 'twitterstats'
require 'twitter'
require 'haml'

task :get_tweets do
  ctoken, csecret = [ENV['CTOKEN'], ENV['CSECRET']]
  atoken, asecret = [ENV['ATOKEN'], ENV['ASECRET']]
  oauth = Twitter::OAuth.new(ctoken, csecret)
  oauth.authorize_from_access(atoken, asecret)
  
  client = Twitter::Base.new(oauth)
  page = 1
  bound = Tweet.max(:id) || 1
  
  tweets = client.user_timeline(:since => bound, :page => 1)
  while tweets.any?
    tweets.each do |tweet|
      Tweet.create(:id => tweet.id, :text => tweet.text, :created_at => tweet.created_at,
                   :in_reply_to => tweet.in_reply_to, :favorited => tweet.favorited) unless Tweet.get(tweet.id)
    end
    page += 1
    tweets = client.user_timeline(:since => bound, :page => page)
  end
end

task :write_html do
  template_path = File.join(File.dirname(__FILE__), %w(lib index.haml))
  index_path = File.join(File.dirname(__FILE__), %w(public index.html))
  engine = Haml::Engine.new(File.read(template_path))
  html = engine.render
  File.open(index_path, 'w') do |file|
    file << html
  end
end

task :default => [:get_tweets, :write_html]
