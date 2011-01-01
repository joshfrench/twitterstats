class Tweet
  include DataMapper::Resource
  property :id,           Integer, :key => true
  property :text,         String
  property :in_reply_to,  String
  property :favorited,    Boolean
  property :created_at,   DateTime

  @tweets = self.all.freeze
  
  def length
    text.length
  end

  def wday
    # input: 0 = Sun, 6 = Sat
    # output: 6 = mon, 0 = Sun
    {0 => 0, 1 => 6, 2 => 5, 3 => 4, 4 => 3, 5 => 2, 6 => 1}[created_at.wday]
  end

  def hour
    created_at.strftime("%H").to_i
  end

  def category(classifier)
    guess = classifier.guess(text)
    case guess
    when Array : guess[0] && guess[0][0]
    when Hash  : keys.first
    end
  end
  
  class << self
    def length_chart
      ticks = 140.every_nth(10)
      ranges= []
      ticks.each_cons(2) { |r| ranges << (r[0]+1..r[1]) }
      data = ranges.collect { |size| @tweets.select { |t| size.include?(t.text.length) }.size }
      length_label = ranges.collect { |s| "#{s.min}-#{s.max}" }.join('|')
      upper = data.max.round_up_to(10)
      count_label = upper.every_nth(10).join('|')
      Gchart.bar :data => data, :size => '600x200', :axis_with_labels => 'x,y,r', :bar_color => 'f2d41a',
        :axis_labels => [length_label, count_label, count_label], :custom => 'chxs=0,333333,8',
        :max_value => upper, :bar_width_and_spacing => { :spacing => 5, :width => 35 }
    end
    
    def time_chart
      hours = @tweets.collect { |t| [t.hour, t.wday] }
      data = hours.uniq.map do |time|
        time << hours.select { |hour| hour == time }.size
      end
      x = data.collect { |d| d[0] }
      y = data.collect { |d| d[1] }
      size = data.collect { |d| d[2] }      
      times = '|' + (0..23).collect { |t| t.to_s.rjust(2, "0")}.join('|') + '|'
      days = '|Sun|Sat|Fri|Thurs|Wed|Tues|Mon|'
      Gchart.scatter(:data => [x, y, size], :size => '600x250', :axis_with_labels => 'x,y', 
                     :axis_labels => [times, days, days], :encoding => :text,
                     :custom => "chm=o,f2d41a,1,1.0,25&chds=-1,24,-1,7,0,#{size.max}")
    end

    def name_chart
      names = @tweets.map{|t| t.text}.join.scan /@\w+/
      data = names.uniq.inject({}) { |c,n| c[n] = names.select { |i| i == n }.size ; c}.sort_by {|c| c[1]}.reverse[0..9]
      labels = []
      data.each_with_index do |d,i|
        labels << "t%20#{d[0]},000000,0,#{i},13"
      end
      counts = data.map { |d| d[1] }
      upper = counts.max.round_up_to(10)
      axis = upper.every_nth(2).join('|')
      Gchart.bar(:data => counts, :orientation => 'horizontal', :axis_with_labels => 'x,t', :bar_color => 'f2d41a',
                 :bar_width_and_spacing => [20,4], :axis_labels => [axis,axis], :size => '600x300',
                 :max_value => upper, :custom => "chm=#{labels.join('|')}&chds=0,#{upper}")
    end

    def subject_chart(classifier=nil)
      classifier ||= BAYES_CLASSIFIER
      categories = {}
      @tweets.each do |tweet|
        category = tweet.category(classifier)
        if category
          categories[category] ||= 0
          categories[category] += 1
        end
      end
      categories = categories.sort do |a,b|
        b[1] <=> a[1]
      end
      labels = categories.map { |c| c[0] }
      data   = categories.map { |c| c[1] }
      Gchart.pie(:data => data, :labels => labels, :size => '600x300', :custom => 'chco=f2d41a')
    end
  end # << self
end