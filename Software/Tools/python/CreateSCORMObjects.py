# run like > python CreateSCORMObjects.py prefix productCode level
# eg > python CreateSCORMObjects.py NMS 68 unit
# Creates a set of SCORM objects for this title/customer

import pathlib
import fileinput
import regex
import sys
import os, errno
import shutil
import json

def nc(x):
  return regex.sub(r'[,()?"\']+',r'',x.replace(' ','_'))
  
names = {
    '68': 'Tense Buster',
    '66': 'Study Skills Success'
    }
shortCodes = {
    '68': 'tb',
    '66': 'sss'
    }
    
os.chdir('d:\\')
prefix = sys.argv[1]
productCode = sys.argv[2]
# level = sys.argv[3]
productFolder = 'content-'+shortCodes.get(productCode, 'xxx')
niceName = names.get(productCode, 'xxx')
subdomain = shortCodes.get(productCode, 'xxx')

template_folder = os.path.join('ContentBench','Content','SCORMtemplate')
temp_folder = os.path.join('c:\\Temp','SCORMbuilder')
output_folder = os.path.join(r'\\ClarityStorage3\TechnicalTeam\TechnicalDelivery','Clarity','SCORM','Remote to CE.com','Couloir',prefix,nc(niceName))
manifest_file_name = os.path.join(temp_folder, 'imsmanifest.xml')
wrapper_file_name = os.path.join(temp_folder, 'SCORMWrapper.html')

print('output_folder='+output_folder)
# Make sure this folder exists and is empty
# TODO This does not work if the folder exists as it takes too long to delete it
if os.path.exists(output_folder):
  shutil.rmtree(output_folder)
try:
  #os.makedirs(output_folder)
  pathlib.Path(output_folder).mkdir(parents=True, exist_ok=False)
except OSError as e:
  print(f'Error creating output folder {e.args}')
  sys.exit()

# This reads the title menu file and parses it as a JSON object
menu_file_name = os.path.join('TestBench',productFolder,'menu.json')
print('read menu from '+menu_file_name)
with open(menu_file_name, 'r') as file:
  contents = json.load(file)

# for each unit create a temp folder from the SCORM template
# update imsmanifest.xml and SCORMWrapper.html for this prefix, productCode, unitId
# zip the folder and save as a SCORM object in the output folder  
for course in contents['courses']:
  print('Course {}'.format(course['caption']))
  for unit in course['units']:
    first_exercise = unit['exercises'][0]
    zip_file_name = os.path.join(output_folder, nc(course['caption'])+'_'+nc(unit['caption']))
    print('make zip file ' + zip_file_name + '.zip')
    # clean copy the SCORM template folder to a new one
    if os.path.exists(temp_folder):
      shutil.rmtree(temp_folder)
    shutil.copytree(template_folder, temp_folder)
    
    # edit the (2) files that need to be customised for this SCORM object
    with open(manifest_file_name, 'r') as manifest_file :
      manifest = manifest_file.read()
    manifest = manifest.replace('{caption}', unit['caption']).replace('{productName}', niceName).replace('{enabledNode}', 'unit:'+unit['id']).replace('{startNode}', 'exercise:'+first_exercise['id'])
    with open(manifest_file_name, 'w') as manifest_file:
      manifest_file.write(manifest)  
    with open(wrapper_file_name, 'r') as wrapper_file :
      wrapper = wrapper_file.read()
    wrapper = wrapper.replace('{prefix}', prefix).replace('{domain}', subdomain)
    with open(wrapper_file_name, 'w') as wrapper_file:
      wrapper_file.write(wrapper)  

    # make the zip
    shutil.make_archive(zip_file_name, 'zip', temp_folder)
