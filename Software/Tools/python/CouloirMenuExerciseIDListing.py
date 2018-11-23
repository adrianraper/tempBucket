# run like > menu-ac-full.json SQLInserts.txt
# Converts a Couloir menu into more readable deep links
import fileinput
import regex
import sys
import os
import json

os.chdir('d:\\TestBench')
file_name = os.path.join('content-rti', 'menu-gt-full.json')
new_file_name = os.path.join('content-rti', 'rti-gt-exercise-id-conversion.txt')

# This reads the file and parses it as a JSON object
with open(file_name, 'r') as file:
  contents = json.load(file)


# This iterates through every unit in every course writing out a new line in a file
with open(new_file_name, 'a') as file:
  for course in contents['courses']:
    if 'units' in course:
      for unit in course['units']:
        if 'exercises' in unit:
          for exercise in unit['exercises']:
            file.write('{},{}\n'.format(exercise['id'], exercise['href']))
        if 'sets' in unit:
          for set in unit['sets']:
            if 'exercises' in set:
              for exercise in set['exercises']:
                file.write('{},{}\n'.format(exercise['id'], exercise['href']))
