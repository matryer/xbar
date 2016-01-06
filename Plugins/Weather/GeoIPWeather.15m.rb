#!/usr/bin/env ruby
# coding: utf-8

### USER VARIABLES
UNITS = 'F' # This can be: (F)ahrenheit, (C)elsius, (K)elvin

require 'json'
require 'net/http'

def no_data(message = nil)
  if message
    puts message
  else
    puts 'Cannot get weather.'
  end
  exit
end

def location
  location_uri = URI('http://ipinfo.io/json')

  location_data = Net::HTTP.get location_uri

  location_json = JSON.parse location_data

  zip = nil
  country = nil

  if location_json['postal']
    zip = location_json['postal']
  else
    no_data
  end

  if location_json['country']
    country = location_json['country']
  else
    no_data
  end

  [zip, country]
end

def weather(zip_code, country)
  temperature_unit =
    case UNITS.upcase
    when 'F'
      '&units=imperial'
    when 'C'
      '&units=metric'
    else
      ''
    end

  temperature_symbol =
    case UNITS.upcase
    when 'F'
      '℉'
    when 'C'
      '℃'
    else
      'K'
    end

  weather_uri =
    URI('http://api.openweathermap.org/data/2.5/weather' \
        "?zip=#{zip_code},#{country}" \
        '&appid=2de143494c0b295cca9337e1e96b00e0' \
        "#{temperature_unit}")

  weather_data = Net::HTTP.get(weather_uri)

  no_data unless weather_data

  weather_json = JSON.parse weather_data

  no_data weather_json['message'] if weather_json['cod'] == '404'

  temperature = weather_json['main']['temp'].round

  city = weather_json['name']
  country = weather_json['sys']['country']

  puts "#{city}, #{country}: #{temperature}#{temperature_symbol}"
end

weather(*location)
