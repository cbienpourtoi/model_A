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

""" A python file to rule them all: fortran, sm, iraf and all that ****"""


#################
### Packages ####
#################
import subprocess
import os
import sys


###############################
### Test fortran compilers ####
###############################

# Automatically checks the presence of g77 and f77 compilators.

fcompilators = ["f77", "g77"] #add your compilator here if you want

for c in fcompilators:
    try:
        subprocess.call([c])
        fcompilator = c
        break
    except:
        print c+" not found"

print "Will use "+fcompilator+" as fortran compilator"




#######################
# Exectution create_input.f

# TODO: This should happen only once, compared to the rest that will be mnore frequent: do later



#######################
# Exectution ML.f

# TODO : One of the input catalogue.cat has wrong format, with : to delete. Where does this come from?
# TODO : make something that corrects the catalogue.cat file.

f_exec_filename = 'a.out'
subprocess.call([fcompilator, '-o', f_exec_filename, 'ML.f'])
subprocess.call(['./'+f_exec_filename], stdin=open("commands_for_ML", 'r'))


#######################
# Exectution prob_bd.f

f_exec_filename = 'a.out'
subprocess.call([fcompilator, '-o', f_exec_filename, 'prob_bd.f'])
subprocess.call(['./'+f_exec_filename])

# TODO : do you need to keep the output of this file?


#######################
# Exectution ffinder.f

f_exec_filename = 'phot/a.out'
subprocess.call([fcompilator, '-o', f_exec_filename, 'phot/ffinder.f'])
subprocess.call(['cd', 'phot'])
subprocess.call(['./'+f_exec_filename])

