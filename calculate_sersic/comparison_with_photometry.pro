

function photometric_fit,x,mue,re,n,muo,h
 Ie=10.^(-0.4*mue)
 I0=10.^(-0.4*muo)
 bn=2.*n-0.327  

 fun_bulge= Ie*exp(-bn*((x/re)^(1./n)-1.))
 fun_disk= I0*exp(-x/h)
 fun=-2.5*alog10(fun_bulge+fun_disk)
 return, fun
end

pro comparison_with_photometry,file1,file2,fileoutphot,log=log

;COMPARISON WITH PHOTOMETRY
basic_colors, black , white , red    , green    , blue, $
              yellow, cyan  , magenta, orange   , mint, $
              purple, pink  , olive  , lightblue, gray   

     
set_plot, 'ps'

aa=findgen(30)*(!pi*2./29.)
rr=0.5
titlel='NGC 1023'
;file1='n4278phot.dat'
;file2='N4278PNedensity.dat'
;completeness_file='4278.completeness.dat'
;fileoutphot='N4278_phot_comp.ps'
; sersic B-band inner 2" excluded
mue=18.86
re=21.18
n=4.
muo=19.14 
h=66.36

; sersic B-band entire R range
;mue=23.4461
;re=48.7166
;n= 5.75994
;muo=9.99*10.^9. 
;h=9999.



readcol,file1,a,mu,/silent
readcol,file2,r,erlow,erup,density_per_bin_,n_elements_x_bin,area,delta_rho,/silent
err_radius=(erup-erlow)/2.
wkr=[a,r]

if keyword_set(log) then begin
    x_=indgen(200)/199.*5.-2
    x=10.^x_
endif else begin
    x=findgen(500)
endelse

surface_brightness=photometric_fit(x,mue,re,n,muo,h)
mu_extrapolated=photometric_fit(r,mue,re,n,muo,h)
;delta_rho=sqrt(n_elements_x_bin)/area+n_elements_x_bin/area^2.*(2.*!pi*R*err_radius)
print, sqrt(n_elements_x_bin)/area+n_elements_x_bin/area^2.*(2.*!pi*R*err_radius)
density_per_bin=-2.5*alog10(density_per_bin_)
density_up=-2.5*alog10(density_per_bin_-delta_rho)
density_low=-2.5*alog10(density_per_bin_+delta_rho)
ntot=n_elements(density_per_bin)
if ntot ge 5 then ntot=5
ntot=2
md1=interpol(mu_extrapolated(0:ntot-1),r(0:ntot-1),mean(r(0:ntot-1)));,/spline)
md2=interpol(density_per_bin(0:ntot-1),r(0:ntot-1),mean(r(0:ntot-1)));,/spline)
;md1=mean(mu_extrapolated(0:ntot-1))    
;md2=mean(density_per_bin(0:ntot-1))
density_per_bin_shifted=density_per_bin-md2+md1
num=density_per_bin_shifted
;print, density_per_bin_shifted
;print, md2
;print, md1
errnum_up=density_up-density_per_bin
errnum_low=density_per_bin-density_low
er=err_radius
readcol,file2,wkwkr,/silent;,recovered_fraction,/silent
recovered_fraction=num*0.+1.
num_recovered=num;+2.5*alog10(recovered_fraction)


modello=photometric_fit(wkwkr,mue,re,n,muo,h)
conteggi_modello=10.^(-0.4*modello)
conteggi_medi_modello=mean(conteggi_modello)
mag_media_modello=-2.5*alog10(conteggi_medi_modello)

conteggi_plan_recovered=10.^(-0.4*num_recovered)
conteggi_medi_plan_recovered=mean(conteggi_plan_recovered)
mag_media_plan_recovered=-2.5*alog10(conteggi_medi_plan_recovered)
offset=mag_media_modello-mag_media_plan_recovered
md1=interpol(mu_extrapolated(0:ntot-1),r(0:ntot-1),mean(r(0:ntot-1)));,/spline)
md2=interpol(num_recovered(0:ntot-1),r(0:ntot-1),mean(r(0:ntot-1)));,/spline)
num_recovered=num_recovered-md2+md1
set_plot,'ps'
device, filename=fileoutphot,xsize=15,ysize=10,/color
plot, [0,1],[0,1],xtitle='6 test'
device, /close
device, filename=fileoutphot,xsize=15,ysize=10,/color
ind=where(finite(surface_brightness))
yrange1=max(surface_brightness(ind))+0.15*abs(min(surface_brightness(ind))-max(surface_brightness(ind)))
yrange2=min(surface_brightness(ind))-0.05*abs(min(surface_brightness(ind))-max(surface_brightness(ind)))

if keyword_set(log) then begin
   print, 'log'
    plot,x,surface_brightness,xrange=[0.1,1000],yrange=[yrange1,yrange2],$
    xstyle=1,ystyle=1,xtitle='!6a [arcsec]',ytitle='!4l!6 [mag arcsec!U-2!N]',COLOR =black,title='!6'+titlel,/xlog,/nodata,xtickname=['0.1','1','10','100','1000']
endif else begin
    xrange2=max([a,r+abs(r-erup)])+0.1*max([a,r+abs(r-erup)])
    plot,x,surface_brightness,xrange=[0.0,xrange2],yrange=[28,13],$;,yrange=[yrange1,yrange2],$
    xstyle=1,ystyle=1,xtitle='!6R [arcsec]',ytitle='!4l!6 [mag arcsec!U-2!N]',COLOR =black,title='!6'+titlel

 endelse

 X_FINALE_DATI=120
 indici = where(X le X_FINALE_DATI)
 indici2 = where(X gt X_FINALE_DATI)


oplot,x[indici],surface_brightness[indici],color=blue,linestyle = 0 
oplot,x[indici2],surface_brightness[indici2],color=blue,linestyle = 2 
oplot,a,mu,psym=4
usersym,rr*cos(aa),rr*sin(aa),/fill
oplot,r,num_recovered,psym=8,symsize=2
oploterror,r,num_recovered,r-erup,errnum_up,ERRCOLOR =black,/hibar
oploterror,r,num_recovered,-erlow+r,errnum_low,ERRCOLOR =black,/lobar
usersym,rr*cos(aa),rr*sin(aa)
;oplot,r,num,psym=8,symsize=2,color=red
usersym,rr*cos(aa),rr*sin(aa),/fill


; R^1/4 + exp_disk B band inner 2" excluded
mue= 18.86;      20.3139      4.00000      22.3632      28.7075
Re= 21.18 
n= 4.
muo=0
h=0.0;2.84217e-14
surface_brightness=photometric_fit(x,mue,re,n,muo,h)
;oplot,x,surface_brightness,color=green

device, /close
print, 'File ', fileoutphot, ' produced'

END



