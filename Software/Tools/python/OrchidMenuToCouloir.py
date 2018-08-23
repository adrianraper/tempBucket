# run like > python OrchidMenuToCouloir.py course.xml menu.json
# Converts an Orchid course/menu into a Couloir menu
import fileinput
import regex
import sys
import os
import json
import xml.etree.ElementTree as ET

os.chdir('d:\\ContentBench')
file_name = os.path.join('Content','ActiveReading-International', sys.argv[1])
new_file_name = os.path.join('Couloir','content-ar', sys.argv[2])

# This reads the course file and parses it as a simple XML object
with open(file_name, 'r') as file:
  contents = file.read()
  root = ET.fromstring(contents)
  
productCode = 71
with open(new_file_name, 'w') as file:
  file.write('{{"caption": "Active Reading","courses": ['.format())
  num_courses = len(root)
  #for course in root:
  for i, course in enumerate(root):
    print('Course is {}'.format(course.get('name')))
    course_id = '2018{!s}{!s}0000'.format(f'{productCode:03}',f'{(i+1):02}')
    file.write('{{"id": "{}", "caption": "{}", \n"units": ['.format(course_id,course.get('name')))
    subFolder = course.get('subFolder')
    scaffold = course.get('scaffold')
    menu_file_name = os.path.join('Content','ActiveReading-International', 'Courses', subFolder, scaffold)
    # Note that menu.xml had to be utf-8 NOT utf-8 BOM before it can read correctly
    with open(menu_file_name, 'r') as menu_file:
      good_contents = menu_file.read()
      menu = ET.fromstring(good_contents)
      num_units = len(menu)
      for j, unit in enumerate(menu):
        #print('Unit is {}'.format(unit.get('caption')))
        unit_id = '2018{!s}{!s}{!s}'.format(f'{productCode:03}',f'{(i+1):02}',f'{(j+1):04}')
        file.write('{{"id": "{}", "caption": "{}", "exercises": ['.format(unit_id,unit.get('caption')))
        num_exercises = len(unit)
        for k, item in enumerate(unit):
          #print('Exercise is {}'.format(item.get('caption')))
          exercise_id = '2018{!s}{!s}{!s}{!s}'.format(f'{productCode:03}',f'{(i+1):02}',f'{(j+1):02}',f'{(k+1):02}')
          file.write('{{"id": "{}", "caption": "{}", "href": "international/{}", "tags": ["practice-zone"]}}'.format(exercise_id,item.get('caption'),exercise_id+'.html'))
          if k < num_exercises-1:
            file.write(',')
          # Also rename the exercise.html from old to new
          # It might not exist if it could not be converted...
          old_ex_name = os.path.join('Couloir','ActiveReading-International', 'Exercises', item.get('id')+'.html')
          new_ex_name = os.path.join('Couloir','content-ar', 'international', exercise_id+'.html')
          if os.path.exists(old_ex_name):
            os.rename(old_ex_name, new_ex_name)
        file.write(']}')
        if j < num_units-1:
          file.write(',\n')
      menu_file.close() 
    file.write(']}')
    if i < num_courses-1:
      file.write(',\n')
  file.write(']}')
