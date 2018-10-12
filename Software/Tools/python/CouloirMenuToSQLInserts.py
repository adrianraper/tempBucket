# run like > menu-ac-full.json SQLInserts.txt
# Converts a Couloir menu into more readable deep links
import fileinput
import regex
import sys
import os
import json

os.chdir('d:\\TestBench')
file_name = os.path.join('content-rti', 'menu-gt-full.json')
new_file_name = os.path.join('content-rti', 'T_ScoreCache inserts.txt')

# This reads the file and parses it as a JSON object
with open(file_name, 'r') as file:
  contents = json.load(file)

#print('Title caption is {}\n'.format(contents['caption']))
#for course in contents['courses']:
#  print('Course is {}\n'.format(course['caption']))
#  for unit in course['units']:
#    print('  Unit {} &startNode=unit:{}&enabledNode=unit:{}\n'.format(unit['caption'], unit['id'], unit['id']))

#for course in root.findall("./head/script/menu/course"):
     
# If you want to use regex, but difficulty is that id and caption appear in changing orders
# and ideally we want to do course, unit, exercise in one sweep
# contents = regex.sub(r'<course .*?id="([\d]*?)" caption="([a-zA-Z -]*?)"[\S ]*?>',r'course \2 &course=\1',contents)

# This iterates through every unit in every course writing out a new line in a file
with open(new_file_name, 'a') as file:
  for course in contents['courses']:
    if 'units' in course:
      file.write('(@productCode,{},null,0,60,1000,@dateStamp,\'Worldwide\'),\n'.format(course['id']))
      for unit in course['units']:
        file.write('(@productCode,{},{},0,60,1000,@dateStamp,\'Worldwide\'),\n'.format(course['id'], unit['id']))
