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


def convert_coordinates(catalog, galaxy_center_pix):
    """ Converts coordinates of the PNs to their pixel positions in the galfit image
    :param catalog: file containing the RA, Dec of the PNs
    :param galaxy_center_pix: center of teh galaxy in pixels
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


    dRA_arcsec = []
    dDec_arcsec = []
    for (r, d) in zip(dRA, dDec):
        dRA_arcsec.append((r.to("arcsec"))/u.arcsec)
        dDec_arcsec.append((d.to("arcsec"))/u.arcsec)

    colPNdRA = Column(dRA_arcsec, name="PNdRA_arcsec")
    colPNdDec = Column(dDec_arcsec, name="PNdDec_arcsec")
    colPNx = Column(PNx, name="PNx_pix")
    colPNy = Column(PNy, name="PNy_pix")
    PNtable.add_column(colPNx)
    PNtable.add_column(colPNy)
    PNtable.add_column(colPNdRA)
    PNtable.add_column(colPNdDec)
    Table([colPNx, colPNy, colPNdRA, colPNdDec]).write(config.position_file, format= "ascii")


    #PNtable.write("ari.txt", format= "ascii")
    #print PNtable
    #sys.exit()

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
    """ Not Used anymore, since I rewrote ffinder.f
    Replace the NAN and -NAN values in a file by 0.5
    :param prefile: file containing NANs
    :param postfile: new file
    :return:
    """

    f = open(postfile, "w")
    for line in file(prefile, mode='r'):
        f.write((line.replace("-NAN.", ".5        ")).replace("NAN.", ".5        "))
    f.close()


def ffinder(catalog_bulge, catalog_total, catalog_fraction, cat_flux_per_area):
    """ Gives fluxes of the PN per area and saves them in a file
    :param catalog_bulge: the IRAF catalog with the flux values from the bulge
    :param catalog_total: the IRAF catalog with the flux values from the total
    :param catalog_fraction: the IRAF catalog with the flux values from the division
    :param cat_flux_per_area: the output catalog with the fluxes per area
    :return:
    """

    bulge = Table.read(catalog_bulge, format="ascii")
    total = Table.read(catalog_total, format="ascii")
    fraction = Table.read(catalog_fraction, format="ascii")

    list_tables = [bulge, total, fraction]
    list_tables = rename_columns_catalogs(list_tables)

    # Replaces the nan values by 0.5
    f_bulge_over_total = bulge["flux"] / total["flux"]
    f_fraction_per_area = fraction["flux"] / fraction["area"]

    f_bulge_over_total[np.isnan(f_bulge_over_total)] = .5
    f_fraction_per_area[np.isnan(f_fraction_per_area)] = .5

    f = open(cat_flux_per_area, "w")
    for i in np.arange(len(total)):
        f.write(str(f_bulge_over_total[i]) +" ")
        f.write(str(f_fraction_per_area[i]) +" ")
        f.write(str(bulge["ID"][i]) +"\n")
    f.close()


def rename_columns_catalogs(list_of_catalogs):
    """ Gives names to the catalog columns outputs by IRAF
    :param list_of_catalogs: a list of tables to rename columns in
    :return: the upgraded list
    """

    for t in list_of_catalogs:
        t.rename_column('col1', 'X')
        t.rename_column('col2', 'Y')
        t.rename_column('col3', 'error_position')
        t.rename_column('col4', 'flux')
        t.rename_column('col5', 'sum')
        t.rename_column('col6', 'area')
        t.rename_column('col7', 'ID')

    return list_of_catalogs


def passes_bindata_for_probbd():
    """ prob_bd() needs data from bin.dat (created by ML.f), but only the last lines,
    which correspond to the last iteration. Here we make a new file lastbin.dat
    with only these last lines, that will be read y prob_bd.f.
    :return:
    """

    bintable = Table.read(config.bintablename, format="ascii")
    bintable.rename_column("col6", "iteration")
    bintable.rename_column("col2", "bin_number")
    last_iteration = np.max(bintable["iteration"])
    subtable = bintable[bintable["iteration"] == last_iteration]
    # tests that the new table is in the right order:
    if np.any(subtable["bin_number"] != np.sort(subtable["bin_number"])):
        print "The subtable created from "+config.bintablename+" seems to be badly ordered in the bin_number. This should not happen..."
        print subtable
        print "Will quit now"
        sys.exit()
    else:
        f = open(config.subtablename, "w")
        for row in subtable:
            for value in row:
                f.write(str(value)+" ")
            f.write("\n")
        f.close()


