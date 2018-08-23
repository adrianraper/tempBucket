# run like > python tagGraylogPlatform.py graylog_platform_description_scores_small.csv
# Reads a csv exported from graylog to pull out stats linked to phone or browser

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

file = open(data, 'r')
contents = file.read()
model_scores = json.loads(contents)
for score in model_scores:
  print('uid={}'.format(score['uid']))
  for question_score in score['exerciseScore']['questionScores']:
    try:
      if (question_score['tags'].count('reading') > 0):
        print(f'this is reading')
    except:
    #try:
    #  print('CEFR level is {}'.format(len(question_score['tags']), question_score['tags'][1]))
    #except IndexError:
      print('no tags')
