# run like > python tagGraylogPlatform.py graylog_platform_description_scores_small.csv
# Reads a csv exported from graylog to pull out stats linked to phone or browser
# The bulk of the work in here is to get the model_scores pulled out of graylog back into acceptable JSON

import pathlib
import fileinput
import regex
import sys
import os
import shutil
import csv
import json
import math

os.chdir('c:\\')
filename = sys.argv[1]
data = os.path.join('Users','Adrian','Documents',filename)

with open(data, newline='') as csv_file:
  csv_reader = csv.DictReader(csv_file)
  test_count = 0
  phone_count = browser_count = phone_target_count = browser_target_count = 0
  phone_duration = browser_duration = phone_target_duration = browser_target_duration = 0
  for row in csv_reader:
    target_duration = 0
    # platform_description
    # model_scores
    # model_remainingTime
    # model_email
    
    # sections depending on what you exported from graylog
    # seeing how long people had left when they completed
    if 'model_remainingTime' in row:
      use_duration = True
      # how long did this person have remaining when the test ended?
      if row["model_remainingTime"] == '':
        duration = 1800
      else:
        duration = 1800 - int(row["model_remainingTime"])
    else:
      use_duration = False

    # picking up detailed scores to check how long they took on one question/one exercise
    if 'model_scores' in row:
      use_model = True
      #graylog screws up JSON format when writing to csv
      # so you could regex to make it valid
      no_good_str = row['model_scores']
      # first get all stuff left of : 
      p = regex.compile(r'([{,])(\s*)([A-Za-z0-9_\-]+?)\s*(=)')
      no_good_str = p.sub(r'\1"\3":', no_good_str)
      # next get as much stuff to the right as you can
      q = regex.compile(r'(?<!\d):([A-Za-z0-9_\-\.]+?)[,]')
      no_good_str = q.sub(r':"\1",', no_good_str)
      # now pick up arrays of simple items
      r = regex.compile(r'(\[|, )+?([\w \)\'\-\.?:;!/\’]+)')
      no_good_str = r.sub(r'\1"\2"', no_good_str)      
      # bring null back to simple item not string
      s = regex.compile(r'"null"')
      no_good_str = s.sub(r'null', no_good_str)  
      # catch array of nothings [, , ,]
      t = regex.compile(r'([\[ ]){1},')
      no_good_str = t.sub(r'\1"",', no_good_str)  
      u = regex.compile(r'(, ){1}\]')
      good_str = u.sub(r'\1""]', no_good_str)  
      # finally put the whole thing into an array      
      good_str = '[' + good_str + ']'
      try:
        model_scores = json.loads(good_str)
      except:
        print(good_str)
        print(f'exit on line {test_count+1}')
        sys.exit()      
      target_q = False
      for score in model_scores:
        #print('uid={}'.format(score['uid']))
        for question_score in score['exerciseScore']['questionScores']:
          try:
            #if (question_score['tags'].count('reading') > 0):
            if (question_score['id'] == "585057c1-9722-4822-87a8-db2ecdbac91c"):
              target_q = True
              target_duration = int(score['exerciseScore']['duration'])
              #print(f'this is reading duration {target_duration}')
          except:
            #try:
            #  print('CEFR level is {}'.format(len(question_score['tags']), question_score['tags'][1]))
            #except IndexError:
            print('no tags')

    # print(model_scores)

    # parse the platform to break down into useful bits to count
    platform = row["platform_description"]
    matchObj = regex.match(r'([\w \+]+?) (\d+).+ on ([\w ()//.\-]+)',platform)
    if matchObj:
      browser = matchObj.group(1)
      browser_version = matchObj.group(2)
      os = matchObj.group(3)
      p = regex.compile(r'android|ios', regex.IGNORECASE)
      phone = p.search(os)
      if phone:
        # print(f'\t{row["model_email"]} used {browser} {browser_version} on {os}')
        # print(f'\t{row["model_email"]} took {duration} seconds')
        #if use_duration:
        #  phone_duration += duration
        if target_q:
          phone_target_duration += target_duration
          phone_target_count += 1
        phone_count += 1
      else:
        #if use_duration:
        #  browser_duration += duration
        if target_q:
          browser_target_duration += target_duration
          browser_target_count += 1
        # os_type = regex.match(r'([\w]+?) (.+)',os)   
        # print(f'\t{row["model_email"]} used {browser} {browser_version} on {os_type.group(1)}')
        browser_count += 1
    test_count += 1
  phone_average = math.ceil((phone_target_duration / phone_target_count) / 1000)
  browser_average = math.ceil((browser_target_duration / browser_target_count) / 1000)
  print(f'Analysed {test_count} tests with {phone_count} phones')
  print(f'Phone duration for A2 reading was {phone_average} and browser duration was {browser_average}')
