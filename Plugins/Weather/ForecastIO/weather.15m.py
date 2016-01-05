#!/usr/bin/python
# -*- coding: utf-8 -*-

# Weather
#
# by Daniel Seripap (daniel@seripap.com)
#
# Forecast.io weather API

import json
import urllib2
from random import randint

location = '40.7027,-73.9867' # Lat,long only. Find at forecast.io
api_key = '' # get yours at api.forecast.io // ac2ca0d3783bb686c40c9144fd647a05
units = '' # change to si for metric

def get_wx():
  wx = json.load(urllib2.urlopen('https://api.forecast.io/forecast/' + api_key + '/' + location + '?units=' + units + "&v=" + str(randint(0,100))))


  if units == 'si':
    unit = 'C'
  else:
    unit = 'F' # Default is imperial

  try:
    weather_data = {
      'temperature': str(int(round(wx['currently']['temperature']))),
      'condition': str(wx['currently']['summary']),
      'unit': '°' + unit
    }
  except KeyError:
    weather_data = False

  return weather_data

def render_wx():
  weather_data = get_wx()

  if weather_data is False:
    return 'Could not get weather'

  return weather_data['condition'] + ' ' + weather_data['temperature'] + weather_data['unit']

print render_wx()
