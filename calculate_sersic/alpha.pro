function photometric_fit,x,mue,re,n,muo,h
 Ie=10.^(-0.4*mue)
 I0=10.^(-0.4*muo)
 bn=2.*n-0.327  

 fun_bulge= Ie*exp(-bn*((x/re)^(1./n)-1.))
 fun_disk= I0*exp(-x/h)
 fun=-2.5*alog10(fun_bulge+fun_disk)
 return, fun
end

pro do_alpha,pne_cat,file_with_rad,completeness,norm,mstar,m80file,sersic_par,solar_mag,distanceMpc,output,extinction=extinction, ellipt=ellipt,alpha_1=alpha_1,alpha_25=alpha_25

;INPUT VARIABLES
;pne_cat        catalog of used PNe (rotated positions) and instrumental 
;               magnitudes. produced by estrai.pro
;               x,y,v,dv,id,r,el,m,mup,mlow
;
;file_with_rad  name of the file containing the radii where to count
;               PNe: Rbin, Rlow, Rup (es. N1023PNedensity.dat)
;
;completeness   file with completeness function produced by
;               completeness.pro 
;
;norm        [float]      Normalization of the PNLF
;mstar       [float]      PNLF cut-off
;m80file        name of the file containing the magnitude m80%
;               (or the value itself). Alpha parameter is computed
;               following paragraph $6.1 in Coccato et al. (2009)
;
;sersic_par     3 elements array with the sersic fit parameters  
;               Re (arcsec) , mue(mag/arcsc2) and n(Sersic index)
;
;solar_mag   [float]      absolute magnitude of the sun
;
;distanceMpc [float]      Galaxy distance in Mpc
;
;output         name of the desired output file, which contains the
;               details of the alpha parameter computation
;
;
; OPTIONAL INPUT VARIABLES
;extintion      total extragalactic extinction (magnitudes)
;               in the considered band. Default = 0
;
;ellipt         galaxy ellipticity (PA is aligned with vertical
;               axis). Default = 0   ellipt = 1.-b/a    
;               (0=sperical, 1 = infin. flat)


ell=0.
if n_elements(ellipt) ne 0 then ell = ellipt

readcol, pne_cat,x,y,m,/silent
rpne = sqrt((x/(1.-ell))^2.+y^2.)

readcol, file_with_rad,Rbin, Rlow, Rup,/silent 
junk=size(m80file)
if junk[1] eq 7 then readcol, m80file,m80,/silent
if junk[1] ne 7 then m80=m80file
m80=m80[0]

npne = rpne*0. ; number of PNe within m80
npne_c = rpne*0. ; number of PNe within m80 corrected for completeness
dnpne = rpne*0. ; error on number of PNe within m80


readcol,completeness,rcomp,comp,/silent
for i = 0, n_elements(rbin)-1 do begin

   indici = where(rpne gt rlow[i] and rpne le rup[i] and m le m80[0])
 
   if indici[0] ne -1 then  npne[i] = n_elements(indici)
 
   
   cf = interpol(comp,rcomp,rbin[i])
   npne_c[i] = npne[i]/cf
  ; stop
endfor
;alpha 80 and its error (N^TOT_c defined at point i) in Section 6.1 of Coccato+09)
ntot = total(npne_c)
dntot = sqrt(npne_c)


boundaries_max=[min(rlow)-15,max(rup)+15]
boundaries_min=[min(rlow)+15,max(rup)-15]
r_min1=boundaries_max[0]
r_max1=boundaries_max[1]
r_min2=boundaries_min[0]
r_max2=boundaries_min[1]

; TOTAL LUMINOSITY CALCULATION
if n_elements(extinction) eq 0 then extinction = 0.
m=sersic_par[1]-25.-5.*alog10(distanceMpc)
md=sersic_par[4]-25.-5.*alog10(distanceMpc)
total_luminosity_1=integrate_sersic(sersic_par[0],m,sersic_par[2],sersic_par[3],md,r_min1)/(10.^(-0.4*solar_mag))
total_luminosity_2=integrate_sersic(sersic_par[0],m,sersic_par[2],sersic_par[3],md,r_max1)/(10.^(-0.4*solar_mag))
total_luminosity_max = (total_luminosity_2 - total_luminosity_1)/(10.^(-0.4*extinction))

total_luminosity_1=integrate_sersic(sersic_par[0],m,sersic_par[2],sersic_par[3],md,r_min2)/(10.^(-0.4*solar_mag))
total_luminosity_2=integrate_sersic(sersic_par[0],m,sersic_par[2],sersic_par[3],md,r_max2)/(10.^(-0.4*solar_mag))
total_luminosity_min = (total_luminosity_2 - total_luminosity_1)/(10.^(-0.4*extinction))

total_luminosity = fltarr(2)
total_luminosity[0] = 0.5*(total_luminosity_max + total_luminosity_min)
total_luminosity[1] = 0.5*(total_luminosity_max - total_luminosity_min)



mcompl=m80
;observed alpha between m* and m*+mcompl
alpha_=(ntot)/total_luminosity[0]

;teoretical alpha bewteewn m* and  m*+mcompl
alpha_teor=integrate_pnlf(mcompl,norm,mstar)- integrate_pnlf(mstar,norm,mstar)

;teoretical alpha between m* and m*+1
alpha_teor_1=integrate_pnlf(mstar+1.,norm,mstar)-integrate_pnlf(mstar,norm,mstar)
alpha_teor_25=integrate_pnlf(mstar+2.5,norm,mstar)-integrate_pnlf(mstar,norm,mstar)

;measured alpha_1.0
alpha_1=fltarr(2)
alpha_25=fltarr(2)
alpha_1[0]=alpha_*alpha_teor_1/alpha_teor
alpha_1[1]= sqrt(   (sqrt(ntot)/total_luminosity[0])^2.  +  (ntot/total_luminosity[0]^2.*total_luminosity[1])^2.   )*sqrt(alpha_teor_1/alpha_teor)
;alpha_1[1]= sqrt(   (sqrt(ntot)/total_luminosity[0])^2.  +  (ntot/total_luminosity[0]^2.*0.3)^2.   )*sqrt(alpha_teor_1/alpha_teor)

alpha_25[0]=alpha_*alpha_teor_25/alpha_teor
alpha_25[1]=sqrt(ntot)/total_luminosity[0]+ntot/total_luminosity[0]^2.*total_luminosity[1]
alpha_25[1]=alpha_25[1]*alpha_25[0]/alpha_1[0]


close, 1
openw,1,output,width=5000
printf,1,'m*, mcompl= ',mstar,mcompl
printf,1,'boundaries= ',r_min1,r_max1,r_min2,r_max2
printf,1,'Ntot PNe (m < mcompl) = ',total(npne)
printf,1,'Corrected Ntot PNe (m < mcompl) = ',ntot
printf,1,'Total extinction corrected luminoisty integrated between boundaries ', total_luminosity[0], ' +/- ',total_luminosity[1] , '  [solar units]'
printf,1,'Measures alpha between m* and m*+mcomp= ',alpha_[0]
printf,1,'Teoretical alpha between m* and m*+1 / Teoretical alpha between m* and m*+mcomp= ',alpha_teor_1/alpha_teor
printf,1,'Teoretical alpha between m* and m*+2.5 / Teoretical alpha between m* and m*+mcomp= ',alpha_teor_25/alpha_teor
printf,1,''
printf,1,'Alpha_1 = ',alpha_1[0], ' +/- ', alpha_1[1]
printf,1,'Alpha_25 = ',alpha_25[0], ' +/- ', alpha_25[1]
close, 1
print, ''
print, 'Output file ',output, ' produced.'

print, ''
print,'Alpha_1 = ',alpha_1[0], ' +/- ', alpha_1[1]
print, ''

end

pro alpha,norm,mstar
pne_cat='PNe_used_mag.dat'
file_with_rad='N1023PNedensity.dat'
completeness='1023.completeness.dat'
output='1023.alpha'
m80file='m80.dat';
sersic_par=[21.18, 20.46, 4,66.36, 20.74]  ;add color to move from R-band to B-band B=R+1.6
a=0.22  ;extinction in B band according to NED (a=0.132 R) 0.22 B
distanceMpc=10.6
m_b_sun=5.48
m_v_sun=4.83

do_alpha,pne_cat,file_with_rad,completeness,norm ,mstar,m80file,sersic_par,m_b_sun,distanceMpc,output,extinction=a, ellipt=ellipt,alpha_1=alpha_1,alpha_25=alpha_25

end
