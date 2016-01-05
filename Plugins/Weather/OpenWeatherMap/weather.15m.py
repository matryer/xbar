#!/usr/bin/python
# -*- coding: utf-8 -*-

# Weather
#
# by Daniel Seripap (daniel@seripap.com)
#
# Simple weather. Change location ID to openweathermap.org location id
# (http://openweathermap.org/city/5110302)

import json
import urllib2
from random import randint

location = '5110302'
api_key = '2de143494c0b295cca9337e1e96b00e0'
units = 'imperial' # kelvin, metric, imperial

def get_wx():

  if api_key == "":
    return False

  wx = json.load(urllib2.urlopen('http://api.openweathermap.org/data/2.5/weather?id=' + location + '&units=' + units + '&appid=' + api_key + "&v=" + str(randint(0,100))))

  if units == 'metric':
    unit = 'C'
  elif units == 'imperial':
    unit = 'F'
  else:
    unit = 'K' # Default is kelvin

  try:
    weather_data = {
      'temperature': str(int(round(wx['main']['temp']))),
      'condition': str(wx['weather'][0]['main']),
      'city': wx['name'],
      'unit': '°' + unit
    }
  except KeyError:
    return False

  return weather_data

def render_wx():
  weather_data = get_wx()

  if weather_data is False:
    return 'Could not get weather'

  return weather_data['condition'] + ' ' + weather_data['temperature'] + weather_data['unit']

print render_wx()
