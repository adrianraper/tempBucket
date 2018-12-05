# run like > python OrchidMenuToCouloir.py course.xml menu.json
# Converts an Orchid course/menu into a Couloir menu
import fileinput
import regex
import sys
import os
import json
import xml.etree.ElementTree as ET

os.chdir('d:\\ContentBench')
file_name = os.path.join('Content','RoadToIELTS2-International', 'course.xml')
new_file_name = os.path.join('R2I-old-ids.txt')

# This reads the course file and parses it as a simple XML object
with open(file_name, 'r') as file:
  contents = file.read()
  root = ET.fromstring(contents)
  
productCode = 52
with open(new_file_name, 'w') as file:
  num_courses = len(root)
  #for course in root:
  for i, course in enumerate(root):
    course_id = course.get('id')
    subFolder = course.get('subFolder')
    scaffold = course.get('scaffold')
    menu_file_name = os.path.join('Content','RoadToIELTS2-International', 'Courses', subFolder, scaffold)
    # Note that menu.xml had to be utf-8 NOT utf-8 BOM before it can read correctly
    with open(menu_file_name, 'r') as menu_file:
      good_contents = menu_file.read()
      menu = ET.fromstring(good_contents)
      num_units = len(menu)
      for j, unit in enumerate(menu):
        unit_id = unit.get('id')
        num_exercises = len(unit)
        for k, item in enumerate(unit):
          exercise_id = item.get('id')
          file.write('{},{},{}\n'.format(course_id, unit_id, exercise_id))
      menu_file.close() 
