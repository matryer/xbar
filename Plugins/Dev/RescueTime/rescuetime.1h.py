#!/usr/bin/env python2.7
import os
import math

# Testing Hack
import pip._vendor.requests as requests

API_KEY = os.path.expanduser('~/Library/RescueTime.com/api.key')

MAPPING = {
    2: 'Very Productive',
    1: 'Productive',
    0: 'Neutral',
    -1: 'Unproductive',
    -2: 'Very Unproductive'
}

if not os.path.exists(API_KEY):
    print('X')
    print('---')
    print('Missing API Key')
    exit()

with open(API_KEY) as fp:
    key = fp.read().strip()
    result = requests.get('https://www.rescuetime.com/anapi/data', params={
        'key': key,
        'resolution_time': 'day',
        'restrict_begin': '2016-01-05',
        'restrict_end': '2016-01-05',
        'format': 'json',
        'restrict_kind': 'productivity',
    }).json()
    pulse = requests.get('https://www.rescuetime.com/anapi/current_productivity_pulse.json', params={
        'key': key,
    }).json()

print('%s | color=%s' % (pulse['pulse'], pulse['color']))
print('---')
print('Rescue Time | href=https://www.rescuetime.com/dashboard?src=bitbar')
for rank, seconds, people, productivty in result['rows']:
    print('%s %s' % (MAPPING[productivty], round(seconds / 60, 2)))
