# run like > python OrchidMenuToCouloir.py course.xml menu.json
# Converts an Orchid course/menu into a Couloir menu
import fileinput
import regex
import sys
import os
import json
import xml.etree.ElementTree as ET

os.chdir('d:\\ContentBench')
file_name = os.path.join('Content','RoadToIELTS2-International', 'menu-Academic-FullVersion.xml')
new_file_name = os.path.join('R2I-Bento-ids.txt')

# This reads the course file and parses it as a simple XML object
with open(file_name, 'r') as file:
  contents = file.read()
  root = ET.fromstring(contents)

with open(new_file_name, 'w') as file:
  file.write('{},{},{}\n'.format('exerciseID', 'unitID', 'courseID'))
  for head in root:
    for script in head:
      for menu in script:
        for course in menu:
          print('open course {}, {}'.format(course.get('id'),course.get('caption')))
          for unit in course:
            if (unit.get('id')):
              print('open unit {}, {}'.format(unit.get('id'),unit.get('caption')))
              for exercise in unit:
                if (exercise.get('id')):
                  file.write('{},{},{}\n'.format(exercise.get('id'), unit.get('id'), course.get('id')))