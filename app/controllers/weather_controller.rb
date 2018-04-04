class WeatherController < ApplicationController
  def create
    # Determine whether a cookie exists before making a new API call
    cookie_check = cookies[['Railsy Weather', params[:city], params[:country]].join('')].to_s.to_sym
    if cookie_check.present?
      @clean_weather = clean_hash_string(cookie_check.to_s)
      render :new
    else
      @weather = check_weather
      if weather_params[:city].empty?  
        flash[:notice] = "Oops, that doesn't appear to be a valid city. Please check for typos and try again."
        redirect_to new_weather_path
      elsif weather_params[:country].empty?  
        flash[:notice] = "Oops, your country must be selected in order to proceed."
        redirect_to new_weather_path
      else
        set_session(@weather)
        @clean_weather = clean_hash_string(@weather.to_s)
        render :new
      end
    end
  end

  def weather_params
    params.permit(:city, :country)
  end

  def check_weather
    CheckWeather.new(params[:city], params[:country]).call
  end

  def set_session(weather)
    # Set cookie with city and country converted to strings
    cookies[['Railsy Weather', params[:city], params[:country]].join('')].to_s.to_sym
    # Sets 30 minute time limit for data retrieved per call made
    weather_group = {value: weather, expires: 30.minutes.from_now}
    cookies[['Railsy Weather', params[:city], params[:country]].join('')] = weather_group
    # Sets and returns weather object
    @weather = cookies[['Railsy Weather', params[:city], params[:country]].join('')]
    return @weather
  end

  def clean_hash_string(dirty_hash)
    clean_weather = JSON.parse(dirty_hash.gsub('=>', ':'), object_class: OpenStruct)
  end
end
