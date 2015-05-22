""" List of functions needed for executing launcher.py
"""
__author__ = "Loic Le Tiran"

def input_model_A(config):
    f = open("input_model_A.dat", "w")
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
