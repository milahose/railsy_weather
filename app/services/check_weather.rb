require 'net/http'

class CheckWeather
 attr_accessor :city, :country

  def initialize(city, country)
    @city = city
    @country = country
  end

  def call
    search_url(city, country)
  end

  def base_url
    "http://api.openweathermap.org/data/2.5/weather?"
  end

  def build_params(city)
    # Collect Open Weather Map data parameters
    {
      q: city,
      APPID: ENV['OPEN_WEATHER_KEY']
    }
  end

  def search_url(city, country)
    url = base_url + build_params(city).to_query + ',' + country
    uri = URI(url)
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    if parsed_response['cod'] == 200 || parsed_response['cod'] == '200'
      parsed_response
    else
      false
    end
  end
end
