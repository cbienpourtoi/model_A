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
import phot.phot as phot


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


#std_out_dir = "stdout/" # In this directory I'll put all the outputs from the codes that are usually displayed on screen




#######################
# Exectution create_input.f

fortfile = "create_input.f"
f_exec_filename = 'a.out'
subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile])

""" # TODO: Commented until I know how to feed the code
error_code = subprocess.call(['./'+f_exec_filename], stdin=open("commands_for_create_input", 'r'))
if error_code != 0:
    print "Error while executing "+fortfile
    sys.exit()
"""

# TODO: This should happen only once, compared to the rest that will be more frequent: do later
# TODO: for loop from here to the end: ?


#######################
# Exectution supermongo overplot.sm

workdir = "phot/"
#subprocess.check_output(['sm'], stdin=open(workdir+"overplot.sm", 'r'), cwd=workdir, stdout=open(std_out_dir+"overplot.txt", 'w'))
subprocess.check_output(['sm'], stdin=open(workdir+"overplot.sm", 'r'), cwd=workdir)




#######################
# Exectution pyraf phot.py

phot.execute()



#######################
# Prepares the catalog with good format for use in ML.f

prefile = "catalog01before.cat"
postfile = "catalog01after.cat"

f = open(postfile, "w")
for line in file(prefile, mode='r'):
    if line[0] != "#":
        f.write(line.replace(":", " "))
f.close()

# TODO: replace with the right catalog in ML.f

#######################
# Exectution ML.f

# TODO : Check that the previous catalog name will be coherent with the new one (right now it is not!)

# The file NA9_f.dat can contain NaN and we don't want them, so I replace the NaN by 0.5
# and create a new catalog NA9_f_NaNcorrected.dat, that is the one read by the fortran code ML.f

prefile = "phot/NA9_f.dat"
postfile = "phot/NA9_f_NaNcorrected.dat"

f = open(postfile, "w")
for line in file(prefile, mode='r'):
    f.write((line.replace("-NAN.", ".5        ")).replace("NAN.", ".5        "))
f.close()


fortfile = "ML.f"
f_exec_filename = 'a.out'
subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile])
error_code = subprocess.call(['./'+f_exec_filename], stdin=open("commands_for_ML", 'r'))
if error_code != 0:
    print "Error while executing "+fortfile
    # i have an error here that is new, since I used create_input. I guess it created bad values and now the code does not run automatically.
    sys.exit()


#######################
# Exectution prob_bd.f

fortfile = 'prob_bd.f'
f_exec_filename = 'a.out'
subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile])
error_code = subprocess.call(['./'+f_exec_filename])
if error_code != 0:
    print "Error while executing "+fortfile
    sys.exit()



#######################
# Exectution ffinder.f

fortfile = 'ffinder.f'
f_exec_filename = 'a.out'
workdir = "phot/"

subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile], cwd=workdir)
error_code = subprocess.call(['./'+f_exec_filename], cwd=workdir)
if error_code != 0:
    print "Error while executing "+fortfile
    sys.exit()
