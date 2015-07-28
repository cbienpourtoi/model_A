""" This is a version of phot.cl converted to python/pyraf by LLT"""
""" Comments are the initial comments from the IRAF script, except when written 'LLT:'"""

from pyraf import iraf
import os, errno
import shutil
import config
reload(config)

def silentremove(filename):
    try:
        os.remove(filename)
    except OSError as e: # this would be "except OSError, e:" before Python 2.6
        if e.errno != errno.ENOENT: # errno.ENOENT = no such file or directory
            raise # re-raise exception if a different error occured

def execute():

    ################NGC1023####################################################
    ## use GALFIT to fit and to create a model disk vs bulge##
    ##galfit.feedme##

    iraf.images()

    # path to fits files:
    total = config.iraf_input_dir+config.totalfits
    bulge = config.iraf_input_dir+config.bulgefits
    fraction = config.iraf_tmp_dir+config.fractionfits

    input_dir = config.iraf_input_dir
    tmp_dir = config.iraf_tmp_dir
    if not os.path.exists(tmp_dir):
        os.mkdir(tmp_dir)

    if os.path.exists(fraction):
         iraf.imdelete(fraction)

    print fraction
    print bulge

    # Makes the fraction image by dividing the bulge by the total:
    iraf.imarith(bulge, "/", total, fraction)

    """ LLT: I don't think we need this anymore:

    if os.path.exists(tmp_dir+"snb.fits"):
        iraf.module.imdelete(tmp_dir+"snb.fits")
    if os.path.exists(tmp_dir+"tnb.fits"):
        iraf.module.imdelete(tmp_dir+"tnb.fits")

    iraf.module.imcopy(bulge, tmp_dir+"snb.fits")
    iraf.module.imcopy(total, tmp_dir+"tnb.fits")
    """

    ##########################################################################
    ##Note: the coordinate in pixel as obtained from RA and Dec differ from the
    ##pixels one because of distorsion corrections as done with astrometry==>

    ##RA and Dec coordinate in arcsec are the correct one and don't need do be
    ##transfer in pixels

    ############################################################################
    ##Consistency check

    #displ(image="../fits_inputs/galaxy.fits",frame=1) 
    #tvmark(frame=1,coords="Kall.dat",color=205,lab-,num+)

    #displ(image="f.fits",zrange=no,zscale=no,ztrans="linear",z1=0,z2=1,frame=3) 
    #tvmark(frame=3,coords="Kall.dat",color=201,mark="rectangle",lengths="6",lab-,num-)

    ###########################################################################
    ##Use program overplot.sm to create both Kall.dat & compagna.dat
    ##in the RA & Dec of PNS there is a rotation of 90deg respect to the pixel
    ## x-->-x 
    ##after long reflexion I decide the right PA is 90-47.11=42.89 (just turning the PNe as observed on the R image)

    ##########################################################################
    ############################################################################

    ## to measure the relative flux use phot (daophot) ##with centerpars=none!!!###

    ##I used sigma=stdv(skys)=0  ===> no bg 
    ##fwhmpsf=2.27 as in galfit psf2.fits (imexam A enclosed)
    ##skyvalue=0 ===> no bg

    ##no centerpars
    ##apertures=3.0 pixels (=1.8 arcsec)

    ##zmag=25

    ##snb.fits & tnb.fits without bg (when I made the model)

    # filenames

    silentremove(config.bulgemag)
    silentremove(config.bulgetxt)
    silentremove(config.totalmag)
    silentremove(config.totaltxt)
    silentremove(config.fractionmag)
    silentremove(config.fractiontxt)

    iraf.noao(_doprint=False)
    iraf.digiphot(_doprint=False)
    iraf.daophot(_doprint=False)

    iraf.phot(bulge,config.position_file, config.bulgemag, skyfile="", datapars="",scale=1.,fwhmpsf=2.27,emissio="yes",sigma=0.0,datamin=-100, datamax=1e5,noise="poisson", centerpars="",calgorithm="none",cbox=0,cthreshold=0.,minsnratio=1., cmaxiter=0,maxshift=0,clean="no",rclean=0.,rclip=0.,kclean=0., mkcenter="no", fitskypars="",salgorithm="constant",annulus=10,dannulus=10,skyvalue=0., smaxiter=10,sloclip=0.,shiclip=0.,snreject=50,sloreject=3., shireject=3.,khist=3.,binsize=0.1,smooth="no",rgrow=0., mksky="no", photpars="",weighting="constant",apertures=3,zmag=0.,mkapert="no", interactive="no",radplots="no",verify="no",update="no",verbose="no", graphics="stdgraph",display="stdimage",icommands="",gcommands="")

    # LLT: Corrected to pyraf, use stdout = instead of >>
    iraf.txdump(config.bulgemag, "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID", "yes", headers="no",paramet="no", Stdout=config.bulgetxt)

    iraf.phot(total, config.position_file, config.totalmag, skyfile="", datapars="",scale=1.,fwhmpsf=2.27,emissio="yes",sigma=0.0,datamin=-100, datamax=1e5,noise="poisson", centerpars="",calgorithm="none",cbox=0,cthreshold=0.,minsnratio=1., cmaxiter=0,maxshift=0.,clean="no",rclean=0.,rclip=0.,kclean=0., mkcenter="no", fitskypars="",salgorithm="constant",annulus=10,dannulus=10,skyvalue=0., smaxiter=10,sloclip=0.,shiclip=0.,snreject=50,sloreject=3., shireject=3.,khist=3.,binsize=0.1,smooth="no",rgrow=0., mksky="no", photpars="",weighting="constant",apertures=3,zmag=25.,mkapert="no", interactive="no",radplots="no",verify="no",update="no",verbose="no", graphics="stdgraph",display="stdimage",icommands="",gcommands="")

    iraf.txdump(config.totalmag, "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID", "yes", headers="no",paramet="no", Stdout=config.totaltxt)

    iraf.phot(fraction,config.position_file, config.fractionmag, skyfile="", datapars="", scale=1., fwhmpsf=2.27, emissio="no", sigma=0.0, datamin=-100, datamax=1e5, noise="poisson", centerpars="", calgorithm="none", cbox=0, cthreshold=0., minsnratio=1., cmaxiter=0, maxshift=0., clean="no", rclean=0., rclip=0., kclean=0., mkcenter="no", fitskypars="", salgorithm="constant", annulus=10, dannulus=10, skyvalue=0., smaxiter=10, sloclip=0., shiclip=0., snreject=50, sloreject=3., shireject=3., khist=3., binsize=0.1, smooth="no", rgrow=0., mksky="no", photpars="", weighting="constant", apertures=3, zmag=25., mkapert="no", interactive="no", radplots="no", verify="no", update="no", verbose="no", graphics="stdgraph", display="stdimage", icommands="", gcommands="")

    iraf.txdump(config.fractionmag, "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID", "yes", headers="no",paramet="no", Stdout=config.fractiontxt)

    ###########################################################################
    ##use program ffinder.f to obtain a readable list input for likelihood....
    ############################################################################
    ##cp NA0_f.dat ../..
    #######################################################################


