""" List of functions needed for executing launcher.py
"""
__author__ = "Loic Le Tiran"

import aplpy
from astropy.table import Table, Column
from astropy import units as u
from astropy.coordinates import SkyCoord
from astropy.io import fits
import matplotlib.pyplot as plt
import config

reload(config)
import numpy as np


def input_model_A(config, filename):
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
    f.write(str(config.gal_coord['RA']) + ' ')
    f.write(str(config.gal_coord['Dec']) + ' ')
    f.write(str(config.pos_angle) + ' ')
    f.write(str(config.inclination) + ' ')
    f.write(str(config.vel_ned) + ' ')
    f.write(str(config.nbin) + ' ')
    # f.write(config.centerPNS['x'], config.centerPNS['y'], config.center2MASS['x'], config.center2MASS['y'], config.pixel_scale, config.gal_coord['RA'], config.gal_coord['Dec'], config.pos_angle, config.inclination, config.vel_ned, config.nbin)
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
    PNtable = Table.read(catalog, format="ascii")

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


