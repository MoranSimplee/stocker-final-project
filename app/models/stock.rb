class Stock 
  include Mongoid::Document

  field :symbol, type: String
  field :name, type: String
  embeds_many :values

  def self.all_stocks_symbols
    self.all.pluck(:symbol)
  end

  def self.get_stocks_by_date(date)
    unwind = {"$unwind" => "$values"}
    sort = {"$sort" => {"symbol" => 1}}
    matchm = {"$match" => {"values.date" => date}}

    self.collection.aggregate([unwind, sort, matchm])
  end

  def self.get_stock_by_symbol(symbol)
    self.where("symbol" => symbol).first
  end
end

