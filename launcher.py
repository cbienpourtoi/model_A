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
import config

reload(config)
from functions import *

# delete this when we work in production mode:
reload(phot)



###############################
### Test fortran compilers ####
###############################

# Automatically checks the presence of g77 and f77 compilators.

fcompilators = ["f77", "g77"]  # add your compilator here if you want

for c in fcompilators:
    try:
        subprocess.call([c])
        fcompilator = c
        break
    except:
        print c + " not found"

print "Will use " + fcompilator + " as fortran compilator"





#####################################
# Exectution of the series of codes #
#####################################

# TODO: check I/O for each process



#######################
# Convert the PN coordinates according to the galfit model coordinates system

galaxy_center_pix = get_galaxy_center(config.iraf_input_dir+config.totalfits)

PNtable = convert_coordinates(config.main_catalog, galaxy_center_pix)

# TODO: Improve a bit the images. have one for the color (velocities), and one for the positions. Maybe make a little zoom ?
plot_image(config.iraf_input_dir+config.totalfits, PNtable, "gal_and_PN.png")



# TODO: This should happen only once, compared to the rest that will be more frequent: do later
# TODO: for loop from here to the end: ?.




#######################
# Gets initial input values from the configuration file
# and creates different commanding files

# TODO: check which of the values in the config.py file can be measured automatically

# Gets the number of bins that will be used in the other codes:
nbins = get_number_bins(PNtable)

# Creates the file containings the commands to ML.f:
ML_command_file = "commands_for_ML"
create_commands_ML(ML_command_file, nbins, PNtable)


# Creates the file input_model_A.dat:
input_model_A(config, nbins, "input_model_A.dat")



#######################
# Prepares the PN catalog with good format

# RA Dec must be with ":"
clean_PN_catalog(config.main_catalog, config.clean_catalog)


#######################
# Exectution pyraf phot.py

phot.execute()


#######################
# Exectution ffinder (former ffinder.f)


# TODO:  put the catalogs somewhere in the flow!

CONTINUER CHanGER LES NOMS ET LES METRE EN CONFIG : DEJA QUaSIMENT FAIT POUR LIGNEs suiVANTEs

repcatas = "phot/"
catalog_bulge = "NABall_nb.txt"
catalog_total = "NATall_nb.txt"
catalog_fraction = "NAFall_nb.txt"
cat_flux_per_area = "NA9_f.dat"

ffinder(repcatas+catalog_bulge, repcatas+catalog_total, repcatas+catalog_fraction, repcatas+cat_flux_per_area)


#######################
# Exectution ML.f

# TODO : Check that the previous catalog name will be coherent with the new one (right now it is not!)

# TODO: I have to make it so that it uses catalog0X all the time.

# ML.f runs a maximum likelihood fitting using position to calculate the azimuthal? angle of the PNes in the galaxy plane
# outputs likely values of rotation velocity, dispersion in the bulge and in the disk = likelihood.dat in bins

fortfile = "ML.f"
f_exec_filename = 'a.out'
subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile])
error_code = subprocess.call(['./' + f_exec_filename], stdin=open("commands_for_ML", 'r'))
if error_code != 0:
    print "Error while executing " + fortfile
    # i have an error here that is new, since I used create_input. I guess it created bad values and now the code does not run automatically.
    sys.exit()



#######################
# Exectution prob_bd.f

fortfile = 'prob_bd.f'
f_exec_filename = 'a.out'
subprocess.check_output([fcompilator, '-o', f_exec_filename, fortfile])
error_code = subprocess.call(['./' + f_exec_filename])
if error_code != 0:
    print "Error while executing " + fortfile
    sys.exit()
