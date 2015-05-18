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




#####################################
# Exectution of the series of codes #
#####################################

""" TODO: check the right order of things """
""" TODO: check I/O for each process"""




#######################
# Exectution supermongo overplot.sm

workdir = "phot/"
subprocess.call(['sm'], stdin=open(workdir+"overplot.sm", 'r'), cwd=workdir)






#######################
# Exectution create_input.f

# TODO: This should happen only once, compared to the rest that will be more frequent: do later



#######################
# Prepares the catalog with good format for use in ML.f

prefile = "catalog01before.cat"
postfile = "catalog01after.cat"

f = open(postfile, "w")
for line in file(prefile, mode='r'):
    if line[0] != "#":
        f.write(line.replace(":", " "))
f.close()


#######################
# Exectution ML.f

# TODO : Check that the previous catalog name will be coherent with the new one (right now it is not!)

f_exec_filename = 'a.out'
subprocess.call([fcompilator, '-o', f_exec_filename, 'ML.f'])
subprocess.call(['./'+f_exec_filename], stdin=open("commands_for_ML", 'r'))


#######################
# Exectution prob_bd.f

f_exec_filename = 'a.out'
subprocess.call([fcompilator, '-o', f_exec_filename, 'prob_bd.f'])
subprocess.call(['./'+f_exec_filename])



#######################
# Exectution ffinder.f

f_exec_filename = 'a.out'
workdir = "phot/"
subprocess.call([fcompilator, '-o', f_exec_filename, 'ffinder.f'], cwd=workdir)
subprocess.call(['./'+f_exec_filename], cwd=workdir)

sys.exit()

