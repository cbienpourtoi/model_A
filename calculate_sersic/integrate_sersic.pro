function integrate_sersic,Re,mue,n,h,muo,R_lim,itot=itot,help=help

; PURPOSE
; The functin returns the integral of the light surface brightness
; profile, performed out to a certain radius.
;
; USAGE
; integrated_light = integrate_sersic(mue,Re,n,R_lim,itot=itot,/help)
;
;
; RETURN VALUE
; integrated_light   [float] the total light of the sersic profile
;                            within R_lim. If /help is set, the return
;                            value is -1, and the help is printed.
;
; INPUTS
; Re                 [float] Effective radius (in arcsec) of the
;                            sersic profile
;
; mue                [float] effective surface brightness (mag/arcsec2)
;
; n                  [float] sersic index
;
;
; OPTIONAL OUTPUTS
;
; itot=itot          [float] Variable which will contain the extrapolated 
;                            value of the total luminosity (R_lim=infinity)
;
;
; OPTIONAL KEYWORDS
;
; \help                      If set, the help is printed and return value is -1
;
;
; HISTORY
; Version 1.0 by L. Coccato 10/06/2008
;

if keyword_set(help) then goto, print_help

;[mueB,reB,4,mu0,h]. 
; Formulas are from Graham et al. 1996, ApJ 465, 534 

ie=10.^(-0.4*mue)
bn=1.9992*n-0.3271  
ics=bn*(R_lim/re)^(1./n)
gamma_=IGAMMA(2.*n,ics)*GAMMA(2.*n)
lighte=ie*re^2.*2.*!pi*n*exp(bn)/bn^(2.*n)*gamma_
ITOTe =ie*re^2.*2.*!pi*n*exp(bn)/bn^(2.*n)*gamma(2.*n)
print, ics
io=(10.^(-0.4*muo))
;bn=1.9992-0.327
;h=h*bn
ics=(R_lim/h)
;gamma_=IGAMMA(2.,ics)*GAMMA(2.)
;lighto=io*h^2.*2.*!pi*exp(bn)/bn^(2.)*gamma_
;ITOTo =io*h^2.*2.*!pi*exp(bn)/bn^(2.)*gamma(2.)
lighto=io*h^2.*2.*!pi*(-exp(-ics)*(1+ics)+1)
ITOTo =io*h^2.*2.*!pi

ITOT = ITOTe + ITOTo
light=lighto+lighte

print,'light',lighto,lighte,R_lim,ics,gamma_,GAMMA(2.)


goto,fine
print_help:
print, ';' 
print, '; PURPOSE'
print, '; The functin returns the integral of the light surface brightness'
print, '; profile, performed till a certain radius.'
print, ';'
print, '; USAGE'
print, '; integrated_light = integrate_sersic(mue,Re,n,R_lim)'
print, ';'
print, ';'
print, '; RETURN VALUE'
print, '; integrated_light   [float] the total light of the sersic profile'
print, ';                            within R_lim. If /help is set, the return'
print, ';                            value is -1, and the help is printed.'
print, ';'
print, '; INPUTS'
print, '; Re                 [float] Effective radius (in arcsec) of the'
print, ';                            sersic profile'
print, ';'
print, '; mue                [float] effective surface brightness (mag/arcsec2)'
print, ';'
print, '; n                  [float] sersic index'
print, ';'
print, ';'
print, '; OPTIONAL OUTPUTS'
print, ';'
print, '; itot=itot          [float] Variable which will contain the extrapolated '
print, ';                            value of the total luminosity (R_lim=infinity)'
print, ';'
print, ';'
print, '; OPTIONAL KEYWORDS'
print, ';'
print, '; \help                      If set, the help is printed and return value is -1'
print, ';'
print, ';'
print, '; HISTORY'
print, '; Version 1.0 by L. Coccato 10/06/2008'
print, ';'
light=-1
fine:
return,light
end
