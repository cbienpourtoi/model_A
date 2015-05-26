__author__ = 'loic'

import astropy.units as u


# Main input catalog
main_catalog = "phot/catalog09.cat" # Change it!



""" General configuration """

# [Input values (former create_input.f)]

centerPNS = {'x':0., 'y':0.}                # Center PNS image in pixel. Format: [x, y] #remove this value?

center2MASS = {'x':0., 'y':0.}              # Center 2MASS image in pixel. Format: [x, y] #check the real center from bulge.fits (or galaxy.fits)

pixel_scale = 1.                    # Pixel scale. Format: arcsec/pix

gal_coord = {'RA':54.6208*u.deg, 'Dec':-5.44980001*u.deg}  # Coordinates of the main galaxy (RA,DEC). Format = [deg, deg]

pos_angle = 0.                      # Position angle N-->E (-..), from galfit. Format = deg

inclination = 72.                    # Inclination, from galfit. Format: cos^-1(b/a)

vel_ned = 660.                         # Systemic velocity of teh galaxy, from Nasa Extragalactic Database (https://ned.ipac.caltech.edu/). Format = lm/s



""" ML.f """

# Do epicyclic approximation? ("epicyclic approximation?1=yes")
epicyclic_approx = True

# Dispersion velocity fixed? ("fix vh?1=yes")
fixed_disp_vel = True

# Calculate on the basis on kinematics only (don't use the photometric probability)? (free f?1=yes)
kinematics_only = False

# Fit only the disk, without halo component? (no halo?1=yes)
no_halo = False


""" Binning """

# Minimal number of objects per bin (number of bins will be calculated from this value)
min_PN_per_bin = 30


""" Simulations configuration """

simulation = {"pix_scale":1.*u.arcsec}       # Pixel scale of the simulations



#########################
#### TEMPORARY FILES ####
#########################
# No change needed on these files

clean_catalog = "phot/PN_catalog_cleaned.cat" # Don't change it!

# Fits file inputs:
iraf_input_dir = "iraf_input/"
totalfits = "galaxy.fits"
bulgefits = "bulge.fits"

# temporary files from IRAF (phot.py) to ffinder: (No change needed usually)
iraf_tmp_dir = "iraf_tmp/"
iraf_total_file = "NATall_nb"
iraf_bulge_file = "NABall_nb"
iraf_fraction_file = "NAFall_nb"
fractionfits = "fraction.fits"

# temporary file : list of positions of PNs, measured in convert_coordinates() and passed in phot.py
position_file = "PNpositions.cat"

# temporary files:
bulgemag = iraf_tmp_dir+iraf_bulge_file+".mag"
bulgetxt = iraf_tmp_dir+iraf_bulge_file+".txt"
totalmag = iraf_tmp_dir+iraf_total_file+".mag"
totaltxt = iraf_tmp_dir+iraf_total_file+".txt"
fractionmag = iraf_tmp_dir+iraf_fraction_file+".mag"
fractiontxt = iraf_tmp_dir+iraf_fraction_file+".txt"

# temporary file created by ffinder, used by ML and prob_bd
cat_flux_per_area = "phot/flux_per_area.dat" # Don't change it!


