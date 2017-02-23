class TwitterStreamer

  @client = Twitter::Streaming::Client.new do |config|
            config.consumer_key        = "BaAGlwr3gLEY5m2fzxtDfbupU"
            config.consumer_secret     = "WQ2Y3tD6TzQrZlg1pisRMJ4swlxK3vZA0SIcetl1XdakTZZ13K"
            config.access_token        = "833631357351903232-CPhIQ3RN91lE7kS0wsCFFAdSK15FXJC"
            config.access_token_secret = "nwGapUPqPWT2wl0GQas2df2fFDIrdj60p0YhzYJmYHQsk"
          end

  # List of the key word we're tracking from twitter
  @twitter_key_words = Array.new 

  # Analyzer object for the sentimental grade
  @analyzer = Sentimental.new 

  # Saves the stocks data while the streamer runs
  @stocks_daily_data = Array.new

  @last_mongo_update = Time.new.wday - 1

  def self.run
    init_analyzer
    init_daily_hash
    run_twitter_analyzer  
  end

  private

  def self.init_analyzer
    @analyzer.load_defaults
    @analyzer.threshold = 0.1

    # Track twitter by the stocks symbols hashtags
    @twitter_key_words = Stock.all_stocks_symbols.map{|symbol| "#" + symbol}
    @twitter_key_words = @twitter_key_words.join(",")
    byebug 
  end

  def self.init_daily_hash
    Stock.all.each do |stock|
      @stocks_daily_data << {symbol: stock[:symbol], count: 0, grade: 0}
    end
  end

  def self.run_twitter_analyzer
    @client.filter({language: "en", track: @twitter_key_words}) do |tweet|
      @stocks_daily_data.each do |stock| 
        if tweet.text.include? stock[:symbol]
          stock[:count] += 1
          stock[:grade] += @analyzer.score tweet.text              
        end
        puts tweet.text
      end

      update_mongo
    end 
  end

  def self.update_mongo

    curr_time = Time.new.min

    if ((@last_mongo_update != curr_time) && (curr_time % 5 == 0))
      @stocks_daily_data.each do |stock_daily_data|
        if (stock_daily_data[:count] != 0)
          stock_document = Stock.get_stock_by_symbol(stock_daily_data[:symbol])
          stock_document.values.create(date: Date.today.to_s, 
                                       sentimental_grade: calc_value(stock_daily_data[:grade], stock_daily_data[:count]), 
                                       stock_change: get_stock_change(stock_daily_data[:symbol]))
        end
      end
      @last_mongo_update = curr_time
      puts "last mongo update: #{@last_mongo_update}"
    end
  end

  def self.calc_value(grade, count)
    behave = (grade/count <= -0.25) ? -1 : 1
  end

  # Gets the real stock change. The change will be positive of the stock went up, or negative if the stock went down
  def self.get_stock_change(stock_symbol)
    StockQuote::Stock.quote(stock_symbol).change || 0
  end
end
