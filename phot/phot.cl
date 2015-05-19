################NGC1023####################################################

## use GALFIT to fit and to create a model disk vs bulge##

##galfit.feedme##

imdel f.fits
imarith("../fits_inputs/bulge.fits", "/", "../fits_inputs/galaxy.fits", "f.fits")

imdel snb.fits
imdel tnb.fits
imcopy  ../fits_inputs/bulge.fits snb.fits
imcopy  ../fits_inputs/galaxy.fits tnb.fits


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

##after long reflession I decide the right PA is 90-47.11=42.89 (just turning the PNe as observed on the R image)

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


!rm NABall.mag
!rm NABall.txt
!rm NATall.mag
!rm NATall.txt
!rm NAFall.mag
!rm NAFall.txt

!rm NABall_nb.mag
!rm NABall_nb.txt
!rm NATall_nb.mag
!rm NATall_nb.txt
!rm NAFall_nb.mag
!rm NAFall_nb.txt


noao
digiphot
daophot

# On one line after
#phot("snb.fits","Kall.dat",\
#	"NABall_nb.mag",skyfile="",\
#     datapars="",scale=1.,fwhmpsf=2.27,emissio=yes,sigma=0.0,datamin=-100,\ 
#               datamax=1e5,noise="poisson",\
#     centerpars="",calgorithm="none",cbox=0,cthreshold=0.,minsnratio=1.,\
#	       cmaxiter=0,maxshift=0,clean=no,rclean=0.,rclip=0.,kclean=0.,\
#	       mkcenter=no,\
#    fitskypars="",salgorithm="constant",annulus=10,dannulus=10,skyvalue=0.,\ 
#               smaxiter=10,sloclip=0.,shiclip=0.,snreject=50,sloreject=3.,\  
#               shireject=3.,khist=3.,binsize=0.1,smooth=no,rgrow=0., mksky=no,\
#     photpars="",weighting="constant",apertures=3,zmag=0.,mkapert=no,\
#     interactive=no,radplots=no,verify=no,update=no,verbose=no,\ 
#     graphics="stdgraph",display="stdimage",icommands="",gcommands="")
 
phot("snb.fits","Kall.dat", "NABall_nb.mag",skyfile="", datapars="",scale=1.,fwhmpsf=2.27,emissio=yes,sigma=0.0,datamin=-100, datamax=1e5,noise="poisson", centerpars="",calgorithm="none",cbox=0,cthreshold=0.,minsnratio=1., cmaxiter=0,maxshift=0,clean=no,rclean=0.,rclip=0.,kclean=0., mkcenter=no, fitskypars="",salgorithm="constant",annulus=10,dannulus=10,skyvalue=0., smaxiter=10,sloclip=0.,shiclip=0.,snreject=50,sloreject=3., shireject=3.,khist=3.,binsize=0.1,smooth=no,rgrow=0., mksky=no, photpars="",weighting="constant",apertures=3,zmag=0.,mkapert=no, interactive=no,radplots=no,verify=no,update=no,verbose=no, graphics="stdgraph",display="stdimage",icommands="",gcommands="")


# Corrected to pyraf, use stdout = instead of >>
#txdump("NABall_nb.mag", "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID", yes, headers=no,paramet=no, >> "NABall_nb.txt")
txdump("NABall_nb.mag", "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID", yes, headers=no,paramet=no, Stdout="NABall_nb.txt")


phot("tnb.fits","Kall.dat",\
"NATall_nb.mag",skyfile="",\
     datapars="",scale=1.,fwhmpsf=2.27,emissio=yes,sigma=0.0,datamin=-100,\ 
               datamax=1e5,noise="poisson",\
     centerpars="",calgorithm="none",cbox=0,cthreshold=0.,minsnratio=1.,\
       cmaxiter=0,maxshift=0.,clean=no,rclean=0.,rclip=0.,kclean=0.,\
       mkcenter=no,\
     fitskypars="",salgorithm="constant",annulus=10,dannulus=10,skyvalue=0.,\ 
               smaxiter=10,sloclip=0.,shiclip=0.,snreject=50,sloreject=3.,\  
               shireject=3.,khist=3.,binsize=0.1,smooth=no,rgrow=0., mksky=no,\
     photpars="",weighting="constant",apertures=3,zmag=25.,mkapert=no,\
     interactive=no,radplots=no,verify=no,update=no,verbose=no,\ 
     graphics="stdgraph",display="stdimage",icommands="",gcommands="")


phot("tnb.fits", "Kall.dat", "NATall_nb.mag",skyfile="", datapars="",scale=1.,fwhmpsf=2.27,emissio=yes,sigma=0.0,datamin=-100, datamax=1e5,noise="poisson", centerpars="",calgorithm="none",cbox=0,cthreshold=0.,minsnratio=1., cmaxiter=0,maxshift=0.,clean=no,rclean=0.,rclip=0.,kclean=0., mkcenter=no, fitskypars="",salgorithm="constant",annulus=10,dannulus=10,skyvalue=0., smaxiter=10,sloclip=0.,shiclip=0.,snreject=50,sloreject=3., shireject=3.,khist=3.,binsize=0.1,smooth=no,rgrow=0., mksky=no, photpars="",weighting="constant",apertures=3,zmag=25.,mkapert=no, interactive=no,radplots=no,verify=no,update=no,verbose=no, graphics="stdgraph",display="stdimage",icommands="",gcommands="")



 
txdump("NATall_nb.mag",\
       "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID",\
       yes, headers=no,paramet=no, Stdout="NATall_nb.txt")

phot("f.fits","Kall.dat", "NAFall_nb.mag", skyfile="", datapars="", scale=1., fwhmpsf=2.27, emissio=no, sigma=0.0, datamin=-100, datamax=1e5, noise="poisson", centerpars="", calgorithm="none", cbox=0, cthreshold=0., minsnratio=1., cmaxiter=0, maxshift=0., clean=no, rclean=0., rclip=0., kclean=0., mkcenter=no, fitskypars="", salgorithm="constant", annulus=10, dannulus=10, skyvalue=0., smaxiter=10, sloclip=0., shiclip=0., snreject=50, sloreject=3., shireject=3., khist=3., binsize=0.1, smooth=no, rgrow=0., mksky=no, photpars="", weighting="constant", apertures=3, zmag=25., mkapert=no, interactive=no, radplots=no, verify=no, update=no, verbose=no, graphics="stdgraph", display="stdimage", icommands="", gcommands="")

txdump("NAFall_nb.mag", "XCENTER,YCENTER,STDEV,FLUX,SUM,AREA,ID", yes, headers=no,paramet=no, Stdout="NAFall_nb.txt")

###########################################################################

##use program ffinder.f to obtain a readable list input for likelihood....


############################################################################

##cp NA0_f.dat ../..

#######################################################################
 
