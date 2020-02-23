require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
require "date"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "8cce7274e1f85a1faa1553e47d98095c"
news = HTTParty.get("https://newsapi.org/v2/top-headlines?country=us&apiKey=51da86f30127472987330dc7a0a2da27").parsed_response.to_hash

get "/" do
  view "ask"
end

get "/news" do
    # Convert inputted location in form to coordinates
    results = Geocoder.search(params["q"])
    lat_long = results.first.coordinates

    # Get lat-long for weather API and store current weather
    @forecast = ForecastIO.forecast(lat_long[0],lat_long[1]).to_hash
    @current_temperature = @forecast["currently"]["temperature"]
    @current_summary = @forecast["currently"]["summary"]
    @icon = @forecast["currently"]["icon"]
    
    # Declare arrays for forecast data
    @forecast_temperature = Array.new
    @forecast_summary = Array.new
    @forecast_icon = Array.new

    # For loop to create arrays for weather API
    i = 0
    for day in @forecast["daily"]["data"] do
        @forecast_temperature[i] = day["temperatureHigh"]
        @forecast_summary[i] = day["summary"]
        @forecast_icon[i] = day["icon"]
        i = i+1
    end

    # Declare arrays for news API
    @title = Array.new
    @story_url = Array.new
    a = 0

    # For loop to create arrays from news API
    for story in news["articles"] do
        @title[a] = story["title"]
        @story_url[a] = story["url"]
        a = a+1
    end

    # Display todays date for new headlines section
    time = Time.new
    @year = time.year
    @month = time.month
    @day = time.day
    @date = Date.new(@year, @month, @day)

    view "news"

end
