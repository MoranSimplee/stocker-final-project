class Value 
  include Mongoid::Document

  field :date, type: String
  field :sentimental_grade, type: Float
  field :stock_change, type: Float
  embedded_in :Stock
end