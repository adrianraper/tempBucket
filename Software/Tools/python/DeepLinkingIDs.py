# run like > DeepLinkingIDs.py menu-FullVersion.xml DeepLinking-PW.txt
# Converts a Bento menu into more readable deep links
import fileinput
import regex
import sys
import os
import xml.etree.ElementTree as ET

os.chdir('d:\\ContentBench\\Content')
file_name = os.path.join('PracticalWriting-International', sys.argv[1])
new_file_name = sys.argv[2]
# This reads the file and parses it as a simple XML object
with open(file_name, 'r') as file:
  contents = file.read()
  root = ET.fromstring(contents)

#for course in root.findall("./head/script/menu/course"):
     
# If you want to use regex, but difficulty is that id and caption appear in changing orders
# and ideally we want to do course, unit, exercise in one sweep
# contents = regex.sub(r'<course .*?id="([\d]*?)" caption="([a-zA-Z -]*?)"[\S ]*?>',r'course \2 &course=\1',contents)

# This iterates through every unit in every course writing out a new line in a file
with open(new_file_name, 'w') as file:
  for head in root:
    for script in head:
      for menu in script:
        for course in menu:
          file.write('Course {} &course={}\n'.format(course.get('caption'), course.get('id')))
          for unit in course:
            file.write('  Unit {} &course={}&startingPoint=unit:{}\n'.format(unit.get('caption'), course.get('id'), unit.get('id')))
