require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'gchart'
require 'enumerator'
require File.dirname(__FILE__) + '/lib/porter'
require File.dirname(__FILE__) + '/lib/bishop'
require File.dirname(__FILE__) + '/lib/fixnum'

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/db/tweets.db")

BAYES_CLASSIFIER = Bishop::Bayes.new
BAYES_CLASSIFIER.load('db/bayesdata.yml')

require File.dirname(__FILE__) + '/lib/tweet'