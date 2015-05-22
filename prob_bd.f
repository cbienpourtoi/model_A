      program prob_bd
c Likelihood code to be run on a mock galaxy. Input:catalogue of PNe and input file parameters and fi file. Check if table.dat is clipping as the confidence level you desire (default 0.04). 


      parameter(m=100000,e=2.718281828)
      parameter(pi=3.141592654)
      character inputfile
      double precision id(m),ra(m),dec(m),vel(m),gi(m),cat(m),fb(m)   
      double precision l(m),v(m),sv(m),sr(m),ss(m),rmax(m),rs(m)
      double precision xp,yp,xss,yss,ps,Rc,Rmc,Rsc,Dc,Dmc,Dsc,pa,incl
      double precision vned, i_rad,lcut(m),ppm(m),xm(m),ym(m),sz_c(m)  
      double precision cos_phi(m),sin_phi(m),xs(m),ys(m),ysi(m)
      double precision vvs(m),sigmas(m),v_halos(m),bd(m),bb(m),xsi(m)
      double precision mm(m),mxl(m),mxv(m),mxs(m),mxsv(m),mxh(m)
      double precision mxf(m),rgal(m),vhel_av(m),rgalgc(m),b(m)  
      double precision likes,loglike,likes_av,loglikes_av,sg_c(m)
      double precision xs_c(m),ys_c(m),ysi_c(m),vel_c(m),bin_c(m)
      double precision fb_c(m),gi_c(m),cat_c(m),likes_c(m),comp(m)
      double precision mmm(m),vhel_all(m),vel_all_av(m),bi(m),ri(m)
      double precision xs_ca(m),ys_ca(m),ysi_ca(m),vel_ca(m),sg(m)
      double precision fb_ca(m),bba(m),bda(m),gi_ca(m),cat_ca(m)
      double precision bin_ca(m),likes_ca(m),i_ca(m),i_c(m),sz(m)
      double precision logbda(m),logbba(m),cos_phica(m),comp_c(m)
      double precision ram(m),ras(m),decm(m),decs(m),rah(m),dech(m)
      double precision errb(m),errr(m),sm(m),sm_c(m),ra_c(m),dec_c(m)
      double precision pb(m),pd(m),xpix(m),ypix(m),rs_c(m),nwrong(m)
      double precision nb,nd,ncorrect(m),lth(m),nbclip(m),nbclipno(m)
      integer flag(m),flag_c(m),idari(m),idwrong(m)
      
      

c INPUT & OUTPUT FILES
      
c     catalogue (without :) created with set_catalogue.sm
       open(11,file="phot/catalog09.cat",status="old")
c      write(*,*)'input file'
c      read(*,*)inputfile

c      write(*,*)'qui'
c       open(11,file=inputfile,status="old")
c       write(*,*)'letto'
c     f
       open(18,file= "phot/NA9_f_NaNcorrected.dat",status="old")
c     input created with create_input.f
c     comment by Loic: input.model_A.dat is now input_modelA.dat
       open(21,file="input_model_A.dat",status="old")
c     rejection 0.04 nearly 2 sigma
       open(56,file="table.dat",status="unknown")
c    likelihood from pne
c       open(10,file="likelihood.bulge.dat",status="unknown")
c bin
c       open(15,file="bin.dat",status="unknown")


c     coordinate (xs,ys,x,y,ysi)
c       open(44,file="coord.dat",status="unknown")
c     rgal(h), h, raggio di ogni bin 
       open(15,file="bin_model9.dat",status="unknown")
c     coordinate and vel v_av, xs, ysi
       open(12,file="likethresh9.dat",status="unknown")
c     likelihood
       open(10,file="likelihood_model9.dat",status="unknown")
c     data used in the program before and after sigma-clipping
c       open(66,file="cleancatalogue.dat",status="unknown")
c     errors
c       open(77,file='error.dat',status='unknown')
c       open(57,file="fdisk.dat",status="unknown")

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


       
      

c     reading parameters

        xp=0
        yp=0
        Rc=0
        Rmc=0
        Rsc=0
        Dc=0
        Dmc=0
        Dsc=0
        pa=0
        incl=0
        vned=0    
        Racc=0
        Decc=0
        nbin=0

      read(21,*)xp,yp,xss,yss,ps,Rc,Dc,pa,incl,vned,nbin

      ai=incl
 
      pa_rad=(pa-180)*pi/180      

       i_rad=ai*pi/180

       write(*,*)' i_rad=',i_rad,' i_deg=',ai, 'pa= ', pa
       write(*,*) xp,yp,Rc,Rmc,Rsc,Dc,Dmc,Dsc

       cos_i=COS(i_rad)
       sin_i=SIN(i_rad)

       write(*,*)'cos_i=',cos_i,' sin_i=',sin_i

       write(*,*)'log(e)', log(e)


ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     probability

       do j=1,10
          read(56,*)lcut(j)
          write(*,*)lcut(j)
       enddo

 56    close(56)


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       write(*,*)'starting main galaxy'


       n=0

       do i=1,m

c          Read the file containin the fi values

          read(11,*,end=1111)id(i),flag(i),xpix(i),ypix(i),rah(i),
     &                       ram(i),ras(i),
     &                       dech(i),decm(i),decs(i),vel(i)  


          read(18,*,end=118)fb(i)

c   Read coordinate ra and dec in arcsec

 

          n=n+1
          ppm(i)=n

c       gi(i)=bi(i)-ri(i)

     
          Racc=Rc/15*3600
          Decc=Dc*3600


          write(*,*)Racc, Decc

         xm(i)=0
         ra(i)=(rah(i)*3600+ram(i)*60+ras(i))
c          xm(i)=( ra(i)*3600 )-Racc
           xm(i)=( ra(i))-Racc
    
         ym(i)=0
         dec(i)=dech(i)*3600-decm(i)*60-decs(i)
c          ym(i)=dec(i)*3600 - Decc
         ym(i)=dec(i) - Decc
      
          
          y_rad=Decc*pi/(3600*180)
         

          xm(i)=xm(i)*15*cos(y_rad)

          write(*,*)'x',xm(i),xpix(i)
          write(*,*)'y',ym(i),ypix(i)

c            xm(i)=xm(i)*15
c            open(56,file="1023_PNe_f.cat",status="unknown")
c            write(56,556)ra(i),dec(i),vel(i),fb(i)
            enddo
c 556        format(4(1x,f8.3))

 118   close(18)
 1111  close(11)
       close(56)



c     rotating the galaxi in order to have the major axis on the y axis and check the rotation...

      do i=1,n

c     minor axis
          xs(i)=xm(i)*COS(pa_rad) - ym(i)*SIN(pa_rad)
c     major axis
          ys(i)=xm(i)*SIN(pa_rad) + ym(i)*COS(pa_rad)


c     average velocity & sigma
        
          av=av+vel(i)
          av2=av2+vel(i)**2
        
       enddo

      av=av/n
      
     
       av2=av2/n
       sigma_los=sqrt(av2-av**2)

       write(*,*) ' av=',av,' av2=',av2,' sig=',sigma_los,' n=',n
       write(*,*)'v_ned=',vned

c     obtaining the inclination angle and correct coordinates

       do i=1,n
          
          xs(i)=-xs(i)
c          xsi(i)=xs(i)*sqrt(cos_i)
          ysi(i)=ys(i)/(cos_i)
          rs(i)=sqrt(xs(i)**2+ysi(i)**2)

c     obtain azimuthal angle in the galaxy plain

          cos_phi(i)=xsi(i)/rs(i)
          sin_phi(i)=ysi(i)/rs(i)
          vhel_av(i)=vel(i)-av
          b(i)=rs(i)
       enddo

       do i=1,n
          do j=i+1,n
             if(b(i).gt.b(j))then
                a=b(i)
                b(i)=b(j)
                b(j)=a
             endif
          enddo                           
       enddo
                                                  
       do i=1,n
c          write(*,*)b(i),i,xm(i),ym(i)
       enddo

       do h=1,nbin
c          do i=1,n
             rgalgc(h)=b(int((h*n/nbin)))
c            enddo
c              write(*,*)'rgalgc', rgalgc(h)
             enddo

 
c GC obtaining prob for each GC
 
               open(17,file="prob_bd9.dat",status="unknown")
              open(19,file="all.dat",status="unknown")
              open(21,file="radial9.dat",status="unknown")
              open(22,file="count9.dat",status="unknown")

               likes=0
               tot_gc=0
              
               do i=1,n
                  vvs(i)=0
               enddo

               do i=1,n
                  sigmas(i)=0
                  v_halos(i)=0
                  bd(i)=0
                  bb(i)=0   
                  xs_c(i)=0
                  ys_c(i)=0
                  ysi_c(i)=0
                  vel_c(i)=0
                  fb_c(i)=0
                  gi_c(i)=0
c                  cat_c(i)=0
                  likes_c(i)=0
                  bin_c(i)=0
                  comp_c(i)=0
                  sg_c(i)=0
                  sz_c(i)=0
                  sm_c(i)=0
                  ra_c(i)=0
                  dec_c(i)=0
               enddo




                 
               cont=0
               cont1=0

               do h=1,nbin

                  read(10,*)mxl(h),mxv(h),mxs(h),mxsv(h),mxh(h),mxf(h)

                  if(rgal(nbin).le.rgalgc(nbin))rgal(nbin)=rgalgc(nbin)

                  read(15,*)rgal(h)
c                  write(*,*)'rgal',rgal(h)

                  loglike=0
                  likes=0
                  likes_av=0
                  mm(h)=0

                  do i=1,n

                       loglike=0
c                       write(*,*)'rs',rs(i)

                     if((int(rgal(h-1)).lt.int(rs(i))).and.
     &                    (int(rs(i)).le.int(rgal(h))))then

                        cont=cont+1

                        mm(h)=mm(h)+1

                        sigmas(i)=sqrt((((mxs(h)*sin_i)**2)*
     &                       (sin_phi(i)**2))+
     &                       ((((mxsv(h)*sin_i))**2)*
     &                       (cos_phi(i)**2))) 

                      


                        vvs(i)=(((vhel_av(i)-(mxv(h)*sin_i
     &                       *(cos_phi(i))))**2))/(2*(sigmas(i)**2))

                        


                        v_halos(i)=((vhel_av(i)**2)/
     &                              (2*(mxh(h)**2)))


                           likes=(((1-fb(i))*exp(-(vvs(i)))
     &                          /sigmas(i))+(fb(i)*
     &                          exp(-(v_halos(i)))/mxh(h)))

                           loglike=log(((1-fb(i))*exp(-(vvs(i)))
     &                          /sigmas(i))+(fb(i)*
     &                          exp(-(v_halos(i)))/mxh(h)))

                           bb(cont)=log(fb(i)*
     &                          exp(-(v_halos(i)))/mxh(h))

                           bd(cont)=log((1-fb(i))*exp(-(vvs(i)))
     &                          /sigmas(i))


                           
                           
                           xs_c(cont)=xs(i)
                           ys_c(cont)=ys(i)
                           ysi_c(cont)=ysi(i)
                           vel_c(cont)=vel(i)
                           fb_c(cont)=fb(i)
                           rs_c(cont)=rs(i)
c                           gi_c(cont)=gi(i)
c                           cat_c(cont)=cat(i)
                           likes_c(cont)=loglike
                           bin_c(cont)=h
                           i_c(cont)=i
c                           comp_c(cont)=comp(i)
c                           sg_c(cont)=sg(i)
c                           sz_c(cont)=sz(i)
                           ra_c(cont)=ra(i)/3600
                           dec_c(cont)=dec(i)/3600
                           flag_c(cont)=flag(i)

c                           do j=400,1200

c                              write(*,*)'i',i
c
                                          
c                  bda(j)=0
c                  bba(j)=0   
c                  vel_ca(j)=0
c                  fb_ca(j)=0
c                  likes_ca(i)=0
c                  bin_ca(i)=0

              


c                              vhel_all(j)=j
c                              vel_all_av(j)=vhel_all(j)-vned
c                              loglike=0
c                              cont1=cont1+1
c                              mmm(h)=mmm(h)+1

c                        sigmas(j)=sqrt((((mxs(h)*sin_i)**2)*
c     &                       (sin_phi(i)**2))+
c     &                       ((((mxsv(h)*sin_i))**2)*
c     &                       (cos_phi(i)**2))) 

                      


c                        vvs(j)=(((vel_all_av(j)-(mxv(h)*sin_i
c     &                       *(cos_phi(i))))**2))/(2*(sigmas(i)**2))

                       

c                        v_halos(j)=((vel_all_av(j)**2)/
c     &                              (2*(mxh(h)**2)))


c                           likes=(((1-fb(i))*exp(-(vvs(j)))
c     &                          /sigmas(j))+(fb(i)*
c     &                          exp(-(v_halos(j)))/mxh(h)))

c                           loglike=log(((1-fb(i))*exp(-(vvs(j)))
c     &                          /sigmas(j))+(fb(i)*
c     &                          exp(-(v_halos(j)))/mxh(h)))

c                           bba(cont1)=(fb(i)*
c     &                          exp(-(v_halos(j)))/mxh(h))/likes
c                           logbba(cont1)=log(fb(i)*
c     &                          exp(-(v_halos(j)))/mxh(h))
                         


c                           bda(cont1)=((1-fb(i))*exp(-(vvs(j)))
c     &                          /sigmas(j))/likes
c                           logbda(cont1)=log((1-fb(i))*exp(-(vvs(j)))
c     &                          /sigmas(j))

c
c                           vel_ca(cont1)=vhel_all(j)
c                           cos_phica(cont1)=cos_phi(i)
c                           fb_ca(cont1)=fb(i)
c                           likes_ca(cont1)=loglike
c                           bin_ca(cont1)=h
c                          i_ca(cont1)=i
c                           enddo

 
                              endif


                             
               
               enddo

             
 
                 

              
               
 
c               write(*,*)mm(h),mmm(h)
                tot_gc=mm(h)+tot_gc

               enddo

               write(*,*)'here'

c               write(*,*)n,tot_gc,cont,cont1

               do h=1,nbin
                  write(*,*)rgal(h),rgalgc(h),mm(h)
                  read(12,*)lth(h)
                     
                       nwrong(h)=0
                       ncorrect(h)=0
                       nbclip(h)=0
                    

                  enddo

                  nb=0
                  nd=0
                  nbl=0
c                  nbclip=0

                 do i=1,n
                    idwrong(i)=0
                    idari(i)=flag_c(i)
                    bb(i)=exp(bb(i))
                    bd(i)=exp(bd(i))
                    pb(i)=bb(i)/(bb(i)+bd(i))
                    pd(i)=bd(i)/(bb(i)+bd(i))


                    if((pb(i)).ne.pb(i))pb(i)=0

                    if((pb(i)).ne.pb(i))pd(i)=1

                    if((pd(i)).ne.pd(i))pd(i)=0

                    if((pd(i)).ne.pd(i))pb(i)=1
                    
                    if(pb(i).ge.0.55) idari(i)=1
                     if(pb(i).lt.0.45) idari(i)=0
                     if(idari(i).ne.flag_c(i)) idwrong(i)=1

c                    write(*,*)'pb',pb(i),pd(i),flag_c(i),idwrong(i)
                    
                    nb=nb+pb(i)
                    write(*,*)'nb',nb,pb(i)
c                    nbclip=nbclip+idari(i)
                    nd=nd+pd(i)
                    nbl=nbl+flag_c(i)
                    
                    

c                     write(*,*)gi_c(i)
                    write(17,771)ra_c(i),dec_c(i),
     &              vel_c(i),
     &              fb_c(i),pb(i),pd(i),likes_c(i),bin_c(i),
     &              xs_c(i),ys_c(i),flag_c(i)


         
                    do h=1,nbin
                   if((int(rgal(h-1)).lt.int(rs_c(i))).and.
     &              (int(rs_c(i)).le.int(rgal(h))))then
                      
                      
                 if(likes_c(i).ge.lth(h))nwrong(h)=nwrong(h)+idwrong(i)
                  if(likes_c(i).ge.lth(h))ncorrect(h)=ncorrect(h)+1
c                      nwrong(h)=nwrong(h)+idwrong(i)
c                      ncorrect(h)=ncorrect(h)+1

                  if(likes_c(i).ge.lth(h))nbclip(h)=nbclip(h)+pb(i)

c                 nwrong(h)=nwrong(h)+idwrong(i)
c                 ncorrect(h)=ncorrect(h)+1
                 nbclipno(h)=nbclipno(h)+pb(i)
                 
                write(*,*)nwrong(h),mm(h),idwrong(i),lth(h),likes_c(i),
     &                    nbclip(h),pb(i)
                      
                      endif
                   
                      enddo


                    enddo
                  
                  nbxlipnotot=0
                  nbcliptot=0
                   do h=1,nbin
                      nbcliptot=nbcliptot+nbclip(h)
                      nbclipnotot=nbclipnotot+nbclipno(h)
                       enddo

                    ntot=nb+nd
                    ndl=n-nbl

                   write(*,*)nb,nbl,nd,ndl,ntot,n,nbcliptot,nbclipnotot
                   write(22,*)nb,nbl,nd,ndl,ntot,n,nbcliptot,nbclipnotot



c                     do i=1,n
c                   write(17,771)xs_c(i),ys_c(i),ysi_c(i),vel_c(i),
c     &              fb_c(i),bb(i),bd(i),likes_c(i),bin_c(i),i_c(i)
c                    enddo


c                  do i=1,cont1
c                    write(19,778)vel_ca(i),fb_ca(i),likes_ca(i),
c     &              bin_ca(i),i_ca(i),logbba(i),logbda(i),cos_phica(i)
c                    enddo

                    




                      do h=1,nbin
                         write(21,*)nwrong(h),ncorrect(h),rgal(h),mm(h)
                         enddo



 771           format(2(1x,f8.4),9(1x,f8.2))
c 778           format(8(1x,f8.2))
               
               close(10)
               close(15)
               close(19)
               close(17)
               close(21)
               close(22)
              stop
              end
 
