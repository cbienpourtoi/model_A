""" List of functions needed for executing launcher.py
"""
__author__ = "Loic Le Tiran"

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
    #f.write(config.centerPNS['x'], config.centerPNS['y'], config.center2MASS['x'], config.center2MASS['y'], config.pixel_scale, config.gal_coord['RA'], config.gal_coord['Dec'], config.pos_angle, config.inclination, config.vel_ned, config.nbin)
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

