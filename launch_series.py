#! /usr/local/bin python
# -*- coding: iso-8859-1 -*-
#

__author__ = "Loic Le Tiran"
__copyright__ = "Copyright 2015"
__credits__ = "Loic Le Tiran"
__license__ = "GPL"
__version__ = "1.0.1"
__maintainer__ = "Loic Le Tiran"
__email__ = "loic.letiran@gmail.com"
__status__ = "Development"

""" This code prepares the files in the case we have many files to analyse
It prepares the inputs to launcher.py, runs launcher.py, and saves the results
The initial files should all be in inputs/model_XYZ.
Outputs will be in ouputs/model_XYZ"""


#################
### Packages ####
#################
import subprocess
import os
import sys
import shutil
import config
import glob
import launcher
import datetime

reload(config)
reload(launcher)
from functions import *


# Change this if you want to run it only on one model/catalog. Else, put a '*' to do everything
model_number = '*'
catalog_number = '*'

# Creates the IRAF input directory where the fits files will be stored
if not os.path.isdir(config.iraf_input_dir):
	os.mkdir(config.iraf_input_dir)

# Creates the directory where to put the outputs:
if not os.path.isdir(config.all_outputs):
    os.mkdir(config.all_outputs)


# Will get all the models from the name of their directory
# All models should be in inputs/model_XXXXX/
list_of_supposed_models = glob.glob(config.all_inputs+'model_'+model_number)
list_of_models = []
for each in list_of_supposed_models:
    if os.path.isdir(each):
        list_of_models.append(each)
print list_of_models

for model in list_of_models:
    print "working on " + model


    mainDirOutput = config.all_outputs+model[len(config.all_inputs):]
    if not os.path.isdir(mainDirOutput):
        os.mkdir(mainDirOutput)

    # Copies the fits file from input/model_XYZ to the good location set in config.py
    shutil.copyfile(model+"/"+config.totalfits, config.iraf_input_dir + config.totalfits)
    shutil.copyfile(model+"/"+config.bulgefits, config.iraf_input_dir + config.bulgefits)

    list_of_catalogs = glob.glob(model+"/catalog"+catalog_number+".cat")
    for catalog in list_of_catalogs:
        print catalog
        # Copies the catalog file in the right folder ready for launcher
        shutil.copyfile(catalog, config.main_catalog)

        # correct output directory (depends on the catalog number)
        catalogDicrectory = mainDirOutput+"/"+os.path.splitext(os.path.basename(catalog))[0]+'/'
        if os.path.isdir(catalogDicrectory):
            shutil.rmtree(catalogDicrectory)
        os.mkdir(catalogDicrectory)

        error_code = launcher.main()
        if error_code == 0:
            for code in config.filestosave:
                for file in config.filestosave[code]:
                    shutil.copyfile(file, catalogDicrectory+file)
        else:
            errorMessage = "There was an error running " + error_code + ". Only the files created before "+ error_code+" will be transfered to output."
            errorFile = catalogDicrectory+"ERROR_MESSAGE.txt"
            logError = open(errorFile, 'w')
            logError.write(str(datetime.datetime.now())+" -- ")
            logError.write(errorMessage)
            logError.close()
            if error_code == 'ML.f':
                for file in config.filestosave["Ffinder"]:
                    shutil.copyfile(file, catalogDicrectory+file)
            if error_code == 'prob_bd.f':
                for file in config.filestosave["Ffinder"]:
                    shutil.copyfile(file, catalogDicrectory+file)
                for file in config.filestosave["ML"]:
                    shutil.copyfile(file, catalogDicrectory+file)
                # Add creates an error and continues

