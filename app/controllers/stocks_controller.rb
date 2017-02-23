class StocksController < ApplicationController
  respond_to :html, :js

  def index

    if (params[:stocks_date] != nil)
      date = params[:stocks_date][:date].split("-")
      date = "#{date[2]}-#{date[1]}-#{date[0]}"
    else
      date = Date.today.to_s
    end

    @stocks = Stock.get_stocks_by_date(date)
    # byebug
    respond_with(@stocks) do |format|
      format.html 
    end
  end

  def twitter_run
    TwitterStreamer.run
  end

  def show

  end
end
