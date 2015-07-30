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

reload(config)
reload(launcher)
from functions import *


# Will get all the models from the name of their directory
# All models should be in inputs/model_XXXXX/
list_of_supposed_models = glob.glob('inputs/model_*')
list_of_models = []
for each in list_of_supposed_models:
    if os.path.isdir(each):
        list_of_models.append(each)
print list_of_models

for model in list_of_models:
    print "working on " + model
    # Copies the fits file from input/model_XYZ to the good location set in config.py
    shutil.copyfile(model+"/"+config.totalfits, config.iraf_input_dir + config.totalfits)
    shutil.copyfile(model+"/"+config.bulgefits, config.iraf_input_dir + config.bulgefits)

    list_of_catalogs = glob.glob(model+"/catalog*.cat")
    for catalog in list_of_catalogs:
        shutil.copyfile(catalog, config.main_catalog)
        launcher.main()

        sys.exit()


#list_of_models =
