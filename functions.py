""" List of functions needed for executing launcher.py
"""
__author__ = "Loic Le Tiran"

import aplpy
from astropy.table import Table, Column
from astropy import units as u
from astropy.coordinates import SkyCoord
from astropy.io import fits
import matplotlib.pyplot as plt
from math import *
import config

reload(config)
import numpy as np


def input_model_A(config, nbins, filename):
    """ creates a file with the parameters from the config.py, to be used by fortran
    :param config: configuration parameters
    :param filename: simple text file in which the config parameters are put, to be read in the fortran code
    """
    f = open(filename, "w")
    f.write(str(config.centerPNS['x']) + ' ')
    f.write(str(config.centerPNS['y']) + ' ')
    f.write(str(config.center2MASS['x']) + ' ')
    f.write(str(config.center2MASS['y']) + ' ')
    f.write(str(config.pixel_scale) + ' ')
    f.write(str(config.gal_coord['RA']/u.deg) + ' ')
    f.write(str(config.gal_coord['Dec']/u.deg) + ' ')
    f.write(str(config.pos_angle) + ' ')
    f.write(str(config.inclination) + ' ')
    f.write(str(config.vel_ned) + ' ')
    f.write(str(int(nbins)) + ' ')
    f.close()


def clean_PN_catalog(old, new):
    """ Cleans a catalog : deteles the comments ("#...") and the ":"
    :param old: The catalog file to be cleaned
    :param new: Cleaned catalog filename
    """
    f = open(new, "w")
    for line in file(old, mode='r'):
        if line[0] != "#":
            f.write(line.replace(":", " "))
    f.close()


def plot_image(fitsfile, PNtable, imagefile):
    """ Makes images of the PN positions and velocities with respect to the galaxy
    :param fitsfile: the fits file to be used as galaxy image
    :param PNtable: The table containing the PN properties (pos, vel)
    :param imagefile: The output file
    :return:
    """
    gc = aplpy.FITSFigure(fitsfile)
    gc.show_grayscale(stretch="log")
    plt.scatter(PNtable['PNx_pix'], PNtable['PNy_pix'], c=PNtable["VEL"], edgecolor="none", marker='o', s=30, alpha=0.9)
    plt.colorbar()
    #gc.show_markers(PNtable['PNx_pix'], PNtable['PNy_pix'], edgecolor="green", facecolor='none', marker='o', s=10, alpha=0.5)
    #plt.show()
    gc.save(imagefile)
    plt.close()


def convert_coordinates(catalog, galaxy_center_pix, PNpos_file):
    """ Converts coordinates of the PNs to their pixel positions in the galfit image
    :param catalog: file containing the RA, Dec of the PNs
    :param galaxy_center_pix: center of teh galaxy in pixels
    :param PNpos_file: file in which we will write the positions of the PNs in pixel, on the galfit image
    :return: A table containing the initial data + the PN pixel positions
    """

    #TODO: add a rotation using the position angle!
    #TODO: make it work also for different observations (header will be different, pixel scale also...)

    # Coordinates of the galaxy center (from config.py)
    coord_gal = SkyCoord(config.gal_coord["RA"], config.gal_coord["Dec"])
    # PN positions in RA(h:m:s), Dec(d:m:s)
    PNtable = Table.read(catalog, format="ascii", delimiter=" ", header_start=-1, data_start=0)

    # Will calculate the differences between the galaxy center coordinates and the PN coordinates: dRA, dDec
    dRA = []
    dDec = []
    for PN in PNtable:
        coord_PN = SkyCoord(PN['RA'], PN['DEC'], unit=(u.hourangle, u.deg))
        dRA.append(coord_PN.ra - coord_gal.ra)
        dDec.append(coord_PN.dec - coord_gal.dec)

    # Converts the differences dRA dDec from coordinates to pixels
    dPNx = [d / config.simulation["pix_scale"].to(dRA[0].unit) for d in dRA]
    dPNy = [d / config.simulation["pix_scale"].to(dDec[0].unit) for d in dDec]

    # Calculates the PN positions in pixels from the center of the galaxy in pixels.
    PNx = [galaxy_center_pix["x"] - d for d in dPNx] # Minus sign from Arianna.
    PNy = [galaxy_center_pix["y"] + d for d in dPNy]

    colPNx = Column(PNx, name="PNx_pix")
    colPNy = Column(PNy, name="PNy_pix")
    PNtable.add_column(colPNx)
    PNtable.add_column(colPNy)
    Table([colPNx, colPNy]).write(PNpos_file, format= "ascii")

    return PNtable



def get_galaxy_center(fitsfile):
    """ Will get the center position from the fits file. Won't work on real observations right now.
    :param fitsfile: a fits where the galaxy is centered.
    :return: position center [x,y] in pixels
    """
    #TODO: it works only for simulations. What about observations ? (tip? take simple the central pixel from the total size / 2)
    hdulist = fits.open(fitsfile)
    xchar = hdulist[0].header["1_XC"]
    ychar = hdulist[0].header["1_YC"]
    xvalue = float(xchar.split("+/-", 1)[0])
    yvalue = float(ychar.split("+/-", 1)[0])
    return {"x":xvalue, "y":yvalue}


def create_commands_ML(ML_command_file, nbins, PNtable):
    """ Creates a file that will be fed to ML.f containing its parameters
    :param ML_command_file: the file name of the parameters that will be used as stdin by ML.f
    :param PNtable: the Table of PN, to have the number of objects
    :return:
    """

    f = open(ML_command_file, "w")
    commands = ""

    # Input values from config.py:
    for confitem in [config.epicyclic_approx, config.fixed_disp_vel, config.kinematics_only, config.no_halo]:
        if confitem:
            commands += "1"
        else:
            commands += "0"
        commands += "\n"

    # Bins calculation:
    nPN = len(PNtable)
    nobj_bin = int(floor(nPN/nbins))
    commands += str(nbins) + "\n"
    commands += str(nobj_bin)

    f.write(commands)
    f.close()


def get_number_bins(PNtable):
    """
    :param PNtable: PN table
    :return: the number of bins that will be used
    """

    nPN = len(PNtable)
    nbins = int(floor(nPN / config.min_PN_per_bin))

    return nbins




def replace_NANs(prefile, postfile):
    """ Replace the NAN and -NAN values in a file by 0.5
    :param prefile: file containing NANs
    :param postfile: new file
    :return:
    """

    f = open(postfile, "w")
    for line in file(prefile, mode='r'):
        f.write((line.replace("-NAN.", ".5        ")).replace("NAN.", ".5        "))
    f.close()
