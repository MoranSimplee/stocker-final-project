class Stock 
  include Mongoid::Document

  field :symbol, type: String
  field :name, type: String
  embeds_many :values

  def self.all_stocks_symbols
    self.all.pluck(:symbol)
  end

  def self.get_stocks_by_date(date)
    self.where("values.date" => date)
  end

  def self.get_stock_by_symbol(symbol)
    self.where("symbol" => symbol).first
  end
end

