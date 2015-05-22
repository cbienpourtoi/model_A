__author__ = 'loic'

import astropy.units as u

""" General configuration file """

# [Input values (former create_input.f)]

centerPNS = {'x':0., 'y':0.}                # Center PNS image in pixel. Format: [x, y] #remove this value?

center2MASS = {'x':0., 'y':0.}              # Center 2MASS image in pixel. Format: [x, y] #check the real center from bulge.fits (or galaxy.fits)

pixel_scale = 1.                    # Pixel scale. Format: arcsec/pix

gal_coord = {'RA':54.6208*u.deg, 'Dec':-5.44980001*u.deg}  # Coordinates of the main galaxy (RA,DEC). Format = [deg, deg]

pos_angle = 0.                      # Position angle N-->E (-..), from galfit. Format = deg

inclination = 72.                    # Inclination, from galfit. Format: cos^-1(b/a)

vel_ned = 660.                         # Systemic velocity of teh galaxy, from Nasa Extragalactic Database (https://ned.ipac.caltech.edu/). Format = lm/s

nbin = 4.                           # Number of bins



""" Simulations configuration """

simulation = {"pix_scale":1.*u.arcsec}       # Pixel scale of the simulations



""" TODO: filenames here """

