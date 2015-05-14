#! /usr/local/bin python
# -*- coding: iso-8859-1 -*-
#

""" A python file to rule them all: fortran, sm, iraf and all that ****"""


#################
### Packages ####
#################
import subprocess
import os



#######################
# Exectution create_input.f

# TODO: This should happen only once, compared to the rest that will be mnore frequent: do later



#######################
# Exectution ML.f

# TODO : One of the input catalogue.cat has wrong format, with : to delete. Where does this come from?
# TODO : make something that corrects the catalogue.cat file.

f_exec_filename = 'a.out'
subprocess.call(['f77', '-o', f_exec_filename, 'ML.f'])
subprocess.call(['./'+f_exec_filename], stdin=open("commands_for_ML", 'r'))


#######################
# Exectution prob_bd.f

f_exec_filename = 'a.out'
subprocess.call(['f77', '-o', f_exec_filename, 'prob_bd.f'])
subprocess.call(['./'+f_exec_filename])

# TODO : do you need to keep the output of this file?

