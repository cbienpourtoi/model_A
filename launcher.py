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
import shutil
#import config
#reload(config)

# delete this when we work in production mode:
reload(phot)



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

""" TODO: check I/O for each process"""


#std_out_dir = "stdout/" # In this directory I'll put all the outputs from the codes that are usually displayed on screen




#######################
# Exectution create_input.f

# rewrite this in python? Should be easy.
# This file only creates input.model_A.dat

# TODO: input.model_A.dat is not a good filename convention : correct.
# TODO : Kill this code and replace it by a nnice python configuration file !



fortfile = "create_input.f"
f_exec_filename = 'a.out'
subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile])

error_code = subprocess.call(['./'+f_exec_filename], stdin=open("commands_for_create_input", 'r'))
if error_code != 0:
    print "Error while executing "+fortfile
    sys.exit()



# TODO: This should happen only once, compared to the rest that will be more frequent: do later
# TODO: for loop from here to the end: ?



#######################
# Exectution supermongo overplot.sm


""" Need the file catalog09.cat (given by lodo)"""
""" output : Kall.dat"""


workdir = "phot/"
#subprocess.check_output(['sm'], stdin=open(workdir+"overplot.sm", 'r'), cwd=workdir, stdout=open(std_out_dir+"overplot.txt", 'w'))
subprocess.check_output(['sm'], stdin=open(workdir+"overplot.sm", 'r'), cwd=workdir)



#######################
# Exectution pyraf phot.py

""" Need the file bulge.fits + galaxy.fits (come from galfit given by lodo) + Kall.dat"""

# TODO: need to produce these images (gal + pne positions + color codes with velocity) IRAF does not do it, do it by myself.

phot.execute()




#######################
# Exectution ffinder.f

# inputs are all the catalogs from before
# reads them, and divide the flux by the area for each Pn, for each image (bulge, total, division f)
# then divides the results from each PN : bulge / total and writes in NA0_f09 (also writes values of division, and then you can check consistency - could make consistency check ?)...
# f = fraction


fortfile = 'ffinder.f'
f_exec_filename = 'a.out'
workdir = "phot/"

subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile], cwd=workdir)
error_code = subprocess.call(['./'+f_exec_filename], cwd=workdir)
if error_code != 0:
    print "Error while executing "+fortfile
    sys.exit()


#######################
# Prepares the catalog with good format for use in ML.f

#TODO: put this more at the begining?

catfile = "phot/catalog09.cat"
shutil.copyfile(catfile, catfile+'.old')

f = open(catfile, "w")
for line in file(catfile+'.old', mode='r'):
    if line[0] != "#":
        f.write(line.replace(":", " "))
f.close()


# TODO: replace with the right catalog in ML.f

#######################
# Exectution ML.f

# TODO : Check that the previous catalog name will be coherent with the new one (right now it is not!)

# The file NA9_f.dat can contain NaN and we don't want them, so I replace the NaN by 0.5
# and create a new catalog NA9_f_NaNcorrected.dat, that is the one read by the fortran code ML.f

prefile = "phot/NA9_f.dat" # todo: created in ffinder.f
postfile = "phot/NA9_f_NaNcorrected.dat"

f = open(postfile, "w")
for line in file(prefile, mode='r'):
    f.write((line.replace("-NAN.", ".5        ")).replace("NAN.", ".5        "))
f.close()

# ML.f runs a maximum likelihood fitting using position to calculate the azimuthal? angle of the PNes in the galaxy plane
# outputs likely values of rotation velocity, dispersion in the bulge and in the disk = likelihood.dat in bins

# TODO: I have to make it so that it uses catalog0X all the time.

# TODO: commands_for_ML should be created here. with 1 0 0 0 and then, number of bin = do it soi that I have at least 30 objects per bin, and then number of objects in each bin.

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

