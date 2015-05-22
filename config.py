__author__ = 'loic'

""" General configuration file """

# [Input values (former create_input.f)]

centerPNS = [0., 0.]                # Center PNS image in pixel. Format: [x, y] #remove this value?

center2MASS = [0., 0.]              # Center 2MASS image in pixel. Format: [x, y] #check the real center from bulge.fits (or galaxy.fits)

pixel_scale = 1.                    # Pixel scale. Format: arcsec/pix

gal_coord = [54.6208, -5.44980001]  # Coordinates of the main galaxy (RA,DEC). Format = [deg, deg]

pos_angle = 0.                      # Position angle N-->E (-..), from galfit. Format = deg

inclination = 72.                    # Inclination, from galfit. Format: cos^-1(b/a)

vel_ned = 660.                         # Systemic velocity of teh galaxy, from Nasa Extragalactic Database (https://ned.ipac.caltech.edu/). Format = lm/s

nbin = 4.                           # Number of bins




      double precision xp,yp,xs,ys,pa,ps,incl,vhel,nbin


      open(1,file="input.model_A.dat",status="unknown")

      write(*,*)'center PNS image in pixel'
      read(*,*)xp,yp
      write(*,*)'center 2MASS image in pixel'
      read(*,*)xs,ys
      write(*,*)'pixel scale, arcsec/px'
      read(*,*)ps

      write(*,*)'coordinate main galaxy(RA,DEC):h,min,sec,g,arcm,arcs'
      read(*,*)Rc,Dc

      write(*,*)'position angle N-->E (-..),galfit'
      read(*,*)pa

      write(*,*)'axis ratio cos-1(b/a),galfit'
      read(*,*)incl

      write(*,*)'vhel,ned'
      read(*,*)vned

        write(*,*)'NBIN'
        READ(*,*)nbin



        write(1,*)xp,yp,xs,ys,ps,Rc,Rmc,Rsc,Dc,Dmc,Dsc,pa,incl,vned,nbin

