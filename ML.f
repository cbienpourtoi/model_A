      program likelihood

c Likelihood code to be run on a mock galaxy. Input:catalogue of PNe and input file parameters and fi file. Check if table.dat is clipping as the confidence level you desire (default 0.04). 


      parameter(m=100000,e=2.718281828)
      parameter(pi=3.141592654)

      double precision x(m),y(m),wvl(m),vel(m),vhel(m),err1(m)
      double precision err2(m),xli(m),yli(m),xri(m), yri(m),vv(m)
      double precision xs(m),ys(m),tg_phi(m),cos_phi(m),sin_phi(m)
      double precision xcs, ycs, sigma(m),i_rad,v_phi(m),vhel_av(m)
      double precision sigma_r(m),sigma_phi(m),max1(m),max2(m),ysi(m)
      double precision rs(m),v_halos(m),likes,mchi2,chi2,NORM,s3(m,10)
      double precision r(m),max,BIG,rgal(m),cos_i,sin_i,xsi(m),theta(m)
      double precision cos_phi_edo(m), sin_phi_edo(m),mxv(m),vvs(m)
      double precision mxs(m),mxsv(m),pp(m),gg(m),rgal_plot(m),sigmas(m)
      double precision velavR(m),denR(m),supp(m),dis(m),sigma_h(m),rr(m)
      double precision velavB(m),denB(m),sup(m),sigmaR(m),sigmaB(m)
      double precision v_halo(m),lnL,like,mxh(m),mxf(m),maxf,aa(m)
      double precision limit,Lmax,fb(m),ftot(m),phot(m),p1,p0,p2,p3
      double precision ppm(m),vhelm(m),xm(m),ym(m),vhelm_av(m),b(m)
      double precision xsm(m), ysm(m), ysmi(m),eee0,eee1,eee2,eee3
      double precision med(m),rb(m),ftotb(m),photb(m),con(m),mm(m)
      double precision bb(m),bd(m),sep(m),rej(m,10),mxl(m),m1(m)
      double precision xu(m), yu(m),y_rad,den(m),vhel_mM(m),xb(m),yb(m)
      double precision ra(m),ram(m),ras(m),dec(m),decm(m),decs(m)
      double precision vhel_gausd(m),gausd(m),vhel_avbin(m),gg2(m)
      double precision lcut(m),xpix(m),ypix(m),flag(m)
      double precision xp,yp,xss,yss,ps,Rc,Rmc,Rsc,Dc,Dmc,Dsc,pa,incl
      double precision vned
      double precision vhel_gausb(m),gausb(m),gmed(m),fdisk(m)
      integer id(m),control(m),ppp,g,mmb(m),delta_d,delta_b,oo
      character yes,answer,answer2,no



       oo=0 
c oo run a loop on all the PNe ti check if the exclusion of one alterate the analysis
       o=1

c o counts the number of interation due to rejections

       rejmin=0
       rejm=0
       
c       do oo=1,184  

c INPUT & OUTPUT FILES
      
c     catalogue (without :)
       open(11,file="phot/PN_catalog_cleaned.cat",status="old")
c     f
       open(18,file="phot/NA9_f_NaNcorrected.dat",status="old")
c     input created with create_input.f
c     comment by Loic: input.model_A.dat is now input_modelA.dat
       open(21,file="input_model_A.dat",status="old")
c     rejection 0.04 nearly 2 sigma
       open(56,file="table.dat",status="unknown")

c     coordinate (xs,ys,x,y,ysi)
       open(44,file="coord.dat",status="unknown")
c     rgal(h), h, raggio di ogni bin 
       open(15,file="bin.dat",status="unknown")
c     coordinate and vel v_av, xs, ysi
       open(12,file="vprofile.dat",status="unknown")
c     likelihood
       open(10,file="likelihood.dat",status="unknown")
c     data used in the program before and after sigma-clipping
       open(66,file="cleancatalogue.dat",status="unknown")
c     errors
       open(77,file='error.dat',status='unknown')
       open(57,file="fdisk.dat",status="unknown")

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c(0)Decisions
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       eee0=0
       eee1=0
       eee2=0
       eee3=0

       p0=0
       p1=0
       p2=1
       p3=0

       write(*,*)'epicyclic approximation?1=yes'
       read(*,*)eee0
       if(eee0.eq.1)p0=1

       write(*,*)'fix vh?1=yes'
       read(*,*)eee1
        if(eee1.eq.1)p1=1

       write(*,*)'free f?1=yes'
       read(*,*)eee2     
        if(eee2.eq.1)p2=0

        write(*,*)'no halo?1=yes'
        read(*,*)eee3
        if(eee3.eq.1)p3=1

        write(*,*)'how many bins?nbin,nbmax(max number PNe in each bin)'
        read(*,*)nbin, nbmax

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c (1) Reading and setting position
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
c     reading parameters

        xp=0
        yp=0
        xss=0
        yss=0
        ps=0
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

      read(21,*)xp,yp,xss,yss,ps,Rc,Dc,pa,incl,vned

      ai=incl
     
       pa_rad=((pa-180))*pi/180  
       i_rad=ai*pi/180

       write(*,*)' i_rad=',i_rad,' i_deg=',ai, 'pa= ', pa
       write(*,*) xp,yp,Rc,Rmc,Rsc,Dc,Dmc,Dsc

       cos_i=COS(i_rad)
       sin_i=SIN(i_rad)

       write(*,*)'cos_i=',cos_i,' sin_i=',sin_i

       write(*,*)'log(e)', log(e)

       


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     probability

       do j=1,10
          read(56,*)lcut(j)
          write(*,*)lcut(j)
       enddo

 56    close(56)


cc       write(*,*)'ok'
c       read(*,*)yes

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

       write(*,*)'starting main galaxy'

C       open(11,file="N2768.cat",status="old")

       n=0

       do i=1,m

c          Read the file containin the fi values


          read(18,*,end=118)fb(i)
          
          if(eee3.eq.1)fb(i)=0

          write(*,*)fb(i)

c          In case you still don't have a fi file

c          fb(i)=0

c         Read coordinate in arcsecs and velocities 

c          read(11,*,end=1111)xb(i),yb(i),vhelm(i)

c          read(11,*,end=1111)xb(i),yb(i)

c         In case your PNe coordinates are in RA and Dec

          read(11,*,end=1111)id(i),flag(i),xpix(i),ypix(i),ra(i),
     &                       ram(i),ras(i),
     &                       dec(i),decm(i),decs(i),vhel(i)  


          write(*,*)id(i),xpix(i),ypix(i),ra(i),
     &                       ram(i),ras(i),
     &                       dec(i),decm(i),decs(i),vhel(i)  

          n=n+1
          ppm(i)=n

          vhelm(i)=vhel(i)

          Racc=Rc/15*3600
          Decc=Dc*3600

          write(*,*)'Racc',Racc
          write(*,*)'Decc',Decc

          xm(i)=0
          xm(i)=( ra(i)*3600 + ram(i)*60 + ras(i) )-Racc
          write(*,*)'x',xm(i)*15,xpix(i)
          ym(i)=0
          ym(i)=( dec(i)*3600 - decm(i)*60 - decs(i))-Decc
         write(*,*)'y',ym(i),ypix(i)
          
          y_rad=Decc*pi/(3600*180)
         

          xm(i)=xm(i)*15*cos(y_rad)


          xpix(i)=(xpix(i)-xp)*0.3012048193
          ypix(i)=(ypix(i)-yp)*0.272479564

c Do you want to exclude some PNE??

c          if((pp(i).ne.1).and.(pp(i).ne.2).and.(pp(i).ne.11).and.
c     &         (pp(i).ne.17))then

c          if((pp(i).ne.2).and.(pp(i).ne.48))then

c          if(pp(i).ne.200) then

c          n=n+1

          write(*,*)xpix(i)**2+ypix(i)**2,xm(i)**2+ym(i)**2,id(i),ppm(i)

          theta(i)=0

c         In case you obtain the coordinate from RA and Dec
          write(66,*)xm(i),ym(i),theta(i),vhelm(i),fb(i),ppm(i)

c         In case you have coordinates already in arcsecs
c          write(66,*)-xpix(i),ypix(i),theta(i),vhelm(i),fb(i),ppm(i)


          

c          endif
        

       enddo


          
 118   close(18)
 1111  close(11)
       close(66)



c       write(*,*)'ok'
c       read(*,*)yes


        do i=1,10
           do j=1,nbin
          rej(i,j)=0
          enddo
       enddo

 666   write(*,*)'number of planetariae = ', n

c       write(*,*)log(e)

c       write(*,*)'START?'
c       read(*,*)yes

c     defining the centre in the PNS image in arcsec

       xcs=xp*0.3012048193
       ycs=yp*0.272479564

       
c     Initializing

       av=0
       av2=0
       ntot=0

       oo=oo+1

       do i=0,nbin
          mm(i)=0
          mmb(i)=0
          rgal(i)=0
          ftot(i)=0
          ftotb(i)=0
          phot(i)=0
          photb(i)=0
       enddo

       min=0
       l_min=0
       k_min=0
       j_min=0

       const=0
       sumv=0
c       pa_rad=0
         

       do i=1,n
          theta(i)=0
          x(i)=0
          y(i)=0
          fb(i)=0
          theta(i)=0
          vhel(i)=0
          xs(i)=0
          ys(i)=0
          ysi(i)=0
          rs(i)=0
          rb(i)=0
          b(i)=0
c          cos_phi(i)=0
c          sin_phi(i)=0

       enddo

c     Reading

       open(66,file="cleancatalogue.dat",status="unknown")

       do i=1,n
          read(66,*)x(i),y(i),theta(i),vhel(i),fb(i),gg(i)

         

c     rotating the galaxi in order to have the major axis on the y axis and check the rotation...

c     minor axis
          xs(i)=x(i)*COS(pa_rad) - y(i)*SIN(pa_rad)
c     major axis
          ys(i)=x(i)*SIN(pa_rad) + y(i)*COS(pa_rad)


c     average velocity & sigma
        
          av=av+vhel(i)
          av2=av2+vhel(i)**2
        

       enddo


       close(66)
       
       av=av/n
      
     
       av2=av2/n
       sigma_los=sqrt(av2-av**2)

       write(*,*) ' av=',av,' av2=',av2,' sig=',sigma_los,' n=',n
       write(*,*)'v_ned=',vned



c     obtaining the inclination angle and correct coordinates

c       i_rad=ai*pi/180

c       r_gal_pix=sqrt(Racc**2+(Decc/cos_i)**2)
c       r_gal=

c       write(*,*)'inclination corrected radius gal',r_gal_pix
c      write(*,*)'radius gal',r_gal

       do i=1,n
          theta(i)=theta(i)*pi/180
               
          ysi(i)=ys(i)/cos_i
         
          xs(i)=-xs(i)

          write(44,*)xs(i),ys(i),x(i),y(i),
     &         ysi(i),fb(i),o

c     check coordinate transformnation with macro likelihood.sm running coord
               
          rs(i)=sqrt(xs(i)**2+ysi(i)**2)
          rb(i)=sqrt(xs(i)**2+ys(i)**2)
          b(i)=rs(i)

c     obtain azimuthal angle in the galaxy plain

          cos_phi(i)=xs(i)/rs(i)
          sin_phi(i)=ysi(i)/rs(i)

          cos_phi_edo(i)=COS(theta(i))
          sin_phi_edo(i)=SIN(theta(i))

c          write(*,*)cos_phi(i), sin_phi(i), rs(i),rb(i), xs(i), ysi(i),
c     &         theta(i),cos_phi_edo(i),sin_phi_edo(i)
            
       enddo

c       close(44)

c       write(*,*)'ok?'
c       read(*,*) yes


c     It is wrong to put a fixed number of object in each bin so.... lets use a radius that in some way is good

c     binning in a way that the number of PNe in each bin is almost constant, first ordering the PNe with the radius, then binning.
                        
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
          write(*,*)b(i),i,fb(i)
       enddo

       do h=1,nbin
c          do i=1,n
             rgal(h)=b(int(h*n/nbin))
c            enddo
              write(*,*)'rgal', rgal(h)
             enddo

            
   
c       rgal(1)=118
c       rgal(2)=200
c       rgal(3)=280
c       rgal(4)=400
c       rgal(5)=1600
c       rgal(6)=1000
c       rgal(7)=2800
  
             mtot=0

       do h=1,nbin

c          rgal(h)=r_gal-100+(h*45)

c          rgal_plot(h)=rgal(h-1)+((rgal(h)-rgal(h-1))/2)

c        if(h.eq.nbin) rgal_plot(h)=522
           m1(h)=0
           fdisk(h)=0

          do i=1,n


c             if(((rgal(h-1)).lt.rs(i)).and.(
c     &            rs(i).lt.(rgal(h))))then
               
                if((int(rgal(h-1)).lt.int(rs(i))).and.int(
     &            rs(i)).lt.int(rgal(h)))then


         
C              if(rs(i).lt.(rgal(h)))then

                mm(h)=mm(h)+1
               

             
c                write(*,*)b(i),b(j)

c                if(h.eq.nbin)fb(i)=fb(i)+0.2

                ftot(h)=ftot(h)+fb(i)

                 if(fb(i).le.0.5) then
                 fdisk(h)=fdisk(h)+1
                 write(*,*)fb(i),gg(i)
                 endif

                if(mm(h).eq.nbmax)goto 333
c                   rgal(h)=rgal(h+1)
                                                                        
c                endif

c             else
c                if(rs(i).gt.rgal(h).and.h.eq.nbin) 
c     &               mm(h)=mm(h)+1
c                endif

 
             endif

             if(((rgal(h-1)).lt.rb(i)).and.(
     &            rb(i).lt.(rgal(h))))then
                        
                mmb(h)=mmb(h)+1

                ftotb(h)=ftotb(h)+fb(i)
                
             endif

         enddo


                         

       
c obtain the median or the radius to plot correctly and estimate the error due to the assumotion that all the galaxy follow the same inclination of the disc.          

        

 333      ntot=ntot+mm(h)
          phot(h)=ftot(h)/mm(h)
          photb(h)=ftotb(h)/mmb(h)


        
          

          med(h)=int(mm(h)/2)

        

c             m1(h)=0

            

            mtot=mtot+mm(h-1)

             med(h)=med(h)+mtot
             m1(h)=1+m1(h)+mtot
c             m2(h)=m2(h)+mm(ll-1)

             write(*,*)'mm(h-1)',mm(h-1),m1(h)

            

          
          write(*,*)'m/2',med(h),'r(m/2)',
     &     b(med(h)),'rgal',rgal(h),
     &     'r(m)',b(ntot),'r(1)',b(m1(h))

          rgal_plot(h)=b(med(h))

          write(*,*)rgal_plot(h)
        

          write(*,*)'rgal',rgal(h),'mdisc',mm(h),'mbulge',mmb(h),h, 
     &              'fb_d',phot(h),'fb',photb(h)

          write(15,*)rgal(h),h,b(med(h)),
     &     b(m1(h)),b(ntot),o
               
       enddo
c       close(15)

       write(*,*)ntot,rgal(nbin),n



c       write(*,*) 'ok?'
c       read(*,*) yes


c     use bin in macro likelihood.sm to visualize the binning respect to the distribution of the object in the real plane

c     referring the velocity to the average velocity & find the min and max

       do i=1,n

          vhel_av(i)=vhel(i)-av

c          vhel_av(i)=vhel(i)-v_edo

c          vhel_av(i)=vhel(i)-v_ned

c          vhel_av(i)=vhel(i)

c          write(*,*)vhel_av(i)
  
          write(12,*)vhel(i),xs(i),ys(i),o
       enddo

c       close(12)

      do h=1,nbin

       gausd(h)=0
       gausb(h)=0
       vhel_avbin(h)=0
       s3(h,o)=0

       enddo


       do h=1,nbin
          do i=1,n
         

c             if(((rgal(h-1)).lt.rs(i)).and.(
c     &            rs(i).lt.(rgal(h))))then


                if((int(rgal(h-1)).lt.int(rs(i))).and.(int(
     &            rs(i)).le.int(rgal(h))))then


                vhel_avbin(h)=vhel_avbin(h)+abs(vhel_av(i))

             endif
          enddo
           
           vhel_avbin(h)= vhel_avbin(h)/mm(h)

       enddo





       do h=1,nbin
          do i=1,n
         

             if(((rgal(h-1)).lt.rs(i)).and.(
     &            rs(i).lt.(rgal(h))))then

c                write(*,*)fb(i),mm(h)


                  vhel_gausd(i)=(1-fb(i))*(vhel_av(i)-
     &             (vhel_avbin(h)*cos_phi(i)))
                  gausd(h)=gausd(h)+vhel_gausd(i)**2

                  vhel_gausb(i)=(fb(i))*(vhel_av(i))
                  gausb(h)=gausb(h)+vhel_gausb(i)**2

             endif
          enddo

           gausd(h)=sqrt(gausd(h)/((1-phot(h))*mm(h))/(2*pi))
           gausb(h)=sqrt(gausb(h)/(phot(h)*mm(h))/(2*pi))
           
          
           write(*,*)gausd(h),gausb(h),fdisk(h),mm(h)

           gausd(h)=int((gausd(h)/10)+0.5)
           gausb(h)=int((gausb(h)/10)+0.5)
           
           write(*,*)gausd(h),  gausb(h)

           s3(h,o)=lcut(gausd(h))

           if(fdisk(h).eq.0.0)s3(h,o)=lcut(gausb(h))

           if(gausd(h).gt.10.0)s3(h,o)=-9.0

         
           
           write(*,*)s3(h,o),fdisk(h)

           write(57,*)fdisk(h)
           

       enddo

c       close(57)


       min_v=10000000
       max_v=0
       min_i=0
       max_i=0
        
       do i=1,n
          do j=i+1,n
             if(vhel_av(i).lt.vhel_av(j).and.
     &            vhel_av(i).lt.min_v)then

                min_v=vhel_av(i)
                min_i=i

             else
                if(vhel_av(i).gt.vhel_av(j).and.
     &               vhel_av(i).gt.max_v)then
                   max_v=vhel_av(i)
                   max_i=i

                endif
             endif
            
          enddo
       enddo
  

       write(*,*)'max=',max_v,max_i
       write(*,*)'min=',min_v,min_i

c       write(*,*)'ok?'
c       read(*,*) yes

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c     likelihood
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c       write(*,*)'likelihood?0=no'
c       read(*,*)ppp
c       if(ppp.eq.0)goto 555

c     first set parameter
  
               nv=300

               nr=300

               nf=300
               if(eee0.eq.1)nf=1

               nh=300
               if(eee1.eq.1)nh=1

               tot=0
               vp=0
               vr=0
               vphi=0
               vh=0
               step=1
               cont=0
               chi2=0
               Lmax=0
c               s3(h,o)=0
               

                            
C               do h=1,nbin
                  do j=1,nv,step
                     v_phi(j)=0

                     do k=1,nr,step
                        sigma_r(k)=0

                       do l=1,nf,step
                           sigma_phi(l)=0
                           
                           do g=1,nh,step
                              sigma_h(g)=0
                               
c
                        
                                 
                           enddo

                        enddo

                     enddo

                  enddo


                 
c     changing parameter

             
               do h=1,nbin

               cont=0
               max=-10000000
               maxj=0
               maxk=0
               maxl=0
               maxg=0
               maxf=0
               chi2=0
               Lmax=0
               ll=0
               lll=0
               tot=0
              
               nv=400

               nr=300

               nf=300
               if(eee0.eq.1)nf=1

               nh=300
               if(eee1.eq.1)nh=1

C               vp=180
C               vr=40
C               vphi=40
C               vh=150

               vp=0
               vr=0
               vphi=0
               vh=0


c     vh fix considering an average rotation velocity of 200

               if(eee1.eq.1)vh=120

 
               errj_min=10000
               errj_max=-1000

               errk_min=10000
               errk_max=-1000


               errl_min=10000
               errl_max=-1000

               if(eee0.eq.1)then
                  errl_min=0
                  errl_max=0
                  endif

               errg_min=10000
               errg_max=-1000  
      
               if(eee1.eq.1)then
                  errg_min=0
                  errg_max=0
                  endif               

               errf_min=10000
               errf_max=-10000


c               fb(1)=0.61
c               fb(2)=0.31
c               fb(3)=0.32
c               fb(4)=0.7
 
c                 phot(1)=0.32
c                 phot(2)=0.21
c                 phot(3)=0.28
c                 phot(4)=0.63
 
              

                   

c               write(*,*)'ok?'
c               read(*,*)yes



               

               step=10



 222              do j=1,nv,step
                     v_phi(j)=(vp+j)*sin_i
                     write(*,*)'v_mod=',vp,v_phi(j),j

                     do k=1,nr,step
                        sigma_r(k)=(vr+k)*sin_i
c                        sigma_phi(k)=sqrt((sigma_r(k)**2)*0.5)
                      
                        write(*,*)'sigma_rmod=',vp,vr,sigma_r(k),j,k
         
                        do l=1,nf,step
                           if(eee0.ne.1) then
                              sigma_phi(l)=(vphi+l)*sin_i
                           else
                              sigma_phi(l)=sqrt((sigma_r(k)**2)*0.5)
                           endif

                           write(*,*)'sigma_phimod=',vp,vr,vphi,
     &                          sigma_phi(l),j,k,l

                           do g=1,nh,step
                              sigma_h(g)=(vh+g)
                              write(*,*)'3sigma_hmod=',vp,vr,vphi,vh,
     &                         sigma_h(g),j,k,l,g


c     in case of FREE photometric distribution DE COOMMENT THIS
c                               
C                           f=0
C                           do f=0,1,0.1
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC                              

                              

c     initializing for every combination of j,k,l,g

                           do i=1,n
                              vv(i)=0
                           enddo

                           do i=1,n
                              sigma(i)=0
                           enddo

                           do i=1,n
                              v_halo(i)=0
                           enddo       

                           if(eee3.eq.1)then
                           do i=1,n
                              fb(i)=0
                           enddo       
                           endif


                           like=0
                           lnL=0
                           rejm=0
                                       
                           do i=1,n

                              delta_b=1
                              delta_d=1

c                              if(i.ne.o)then

                              tot=tot+1

c                              if(((rgal(h-1)).lt.rs(i)).and.
c     &                             (rs(i).lt.(rgal(h))))then


                                 if((int(rgal(h-1)).lt.int(rs(i))).and.
     &                             (int(rs(i)).le.int(rgal(h))))then


cdelta_d=1

c                              if(((rgal(h-1)).lt.rb(i)).and.
c     &                             (rb(i).lt.(rgal(h))))delta_b=1 

c                            if((delta_b.eq.0).and.(delta_d.eq.0))goto 31

c     disk like component

c     sigma_los(i)            
                             
                                 sigma(i)=sqrt(((sigma_r(k)**2)*
     &                                (sin_phi(i)**2))+
     &                                ((sigma_phi(l)**2)*
     &                                (cos_phi(i)**2)))  
                               
c     "gaussian distribution"

                                 vv(i)=((vhel_av(i)-(v_phi(j)
     &                            *(cos_phi(i))))**2)/(2*(sigma(i)**2))
                                 
c     halo like component
c     
c                                v_halo(i)=((vhel_av(i)-(0.6*sigma_h(g)*
c     &                               sin_i*cos_phi(i)))**2)/
c     &                               (2*(sigma_h(g)**2))


                                 v_halo(i)=(vhel_av(i)**2)/
     &                               (2*(sigma_h(g)**2))

                                 if(eee2.ne.1)then

                                 like=like+log(delta_d*((1-fb(i))
     &                                *exp(-(vv(i)))/sigma(i))+
     &                                delta_b*(fb(i)*exp(-(v_halo(i)))/
     &                                sigma_h(g)))

                                 else
c     in case of a free photometric distribution

                                 like=like+log(((1-f)*exp(-(vv(i)))/
     &                                sigma(i))+(f*exp(-(v_halo(i)))/
     &                                (sigma_h(g))))

             
                                                                      
                              endif
                           endif
                              
 31                        enddo
                           
c     likelihood with minus sign (===>looking for the minimum)

c                         
c                           lnL(j,k,l,g,f)=(-0.5*n*log(2*pi)+like)

                           lll=lll+1
c                           lnL=(-0.5*n*log(2*pi)+like)
                           lnL=like

                           write(*,*)'f=',phot(h),
     &                     ' lnL=', lnL,j,k,l,g,h,mm(h),chi2,oo
                                              
                           if((lnL).gt.max)then

                              max=lnL
                              maxj=j
                              maxk=k

                              if(eee0.ne.1)maxl=l
                              if(eee0.eq.1)maxl=sqrt((maxk**2)*0.5) 


                              maxg=g

c     in case of free photometric distribution

                              if(eee2.eq.1)then
                              maxf=f         
                              else
                              maxf=phot(h)  
                              endif                            
                                              
                           endif

                           write(*,*)Lmax,max

                           if((cont.eq.2).and.(lnL.gt.(Lmax-chi2)))
     &                      then

                              ll=ll+1

                              if(j.lt.errj_min) errj_min=j                     
                              if(j.gt.errj_max) errj_max=j
                              if(k.lt.errk_min) errk_min=k
                              if(k.gt.errk_max) errk_max=k

                              if(l.lt.errl_min) errl_min=l
                              if(l.gt.errl_max) errl_max=l

                              if(eee0.eq.1)then
                                 errl_min=0
                                 errl_max=0
                                 endif                     
      
                              if(g.lt.errg_min) errg_min=g
                              if(g.gt.errg_max) errg_max=g

                              if(eee2.eq.1)then
c     in case of free photometric distribution
                              if(f.lt.errf_min) errf_min=f
                              if(f.gt.errf_max) errf_max=f
                              endif

                           endif

c     IN CASE OF FREE PHOT DECOMMMENT THIS
C                        enddo
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

                     enddo
                     
                  enddo

               enddo
                     

            enddo

                  write(*,*) 'maxv',maxj,'max sigma_r',maxk,
     &                 'max sigma_phi',maxl,'max sigma_halo',maxg,
     &                 'max f',maxf,'max L', max, 'cont', cont,
     &                 'll',ll,'lll',lll,'Lmax',Lmax

c                  write(*,*)'ok?'
c                  read(*,*)yes

c                  write(*,*) 'maxv',maxj,'max sigma_r',maxk,
c     &                 'max sigma_phi',maxl,'max sigma_halo',sigmah,
c     &                 'max f',maxf



                  if(cont.eq.0)then
c                     write(*,*)'do you want to change vp, vr, vphi '
c                     read(*,*)answer
c                     if(answer.eq.yes)then

c                        max=-10000000
c                        maxj=0
c                        maxk=0
c                        maxl=0
c                        maxg=0
c                        maxf=0
c                        lnL=0
c                        lll=0
                 

c                        write(*,*) 'new vp, nv'
c                        read(*,*)vp,nv
c                        write(*,*) 'new vr, nr'
c                        read(*,*)vr,nr
c                        write(*,*) 'new vphi, nf'
c                        read(*,*)vphi,nf
c                        write(*,*)'new vh, nh'
c                        read(*,*)vh,nh
c                        write(*,*)'step?'
c                        read(*,*)step

c                        goto 222


c                     else

                        cont=1
                       
                        write(*,*)'chi2=',chi2

c                        write(*,*)'ok?'
c                        read(*,*)yes
                                             
                        vp=vp+maxj-(step)
                        nv=2*step

                      

                        vr=vr+maxk-(step)
                        nr=2*step

                        if(eee0.ne.1)then
                        vphi=vphi+maxl-(step)
                        nf=2*step
                        endif

                        if(eee1.ne.1)then
                        vh=vh+maxg-(step)
                        nh=2*step
                        endif


c     assure no negative value

                          if(vp.le.0)vp=0
                          if(vr.le.0)vr=0
                          if(vphi.le.0)vphi=0
                          if(vh.le.0)vh=0
                      
                         step=1

c                        vp=0
c                        nv=300
c                        vr=0
c                        nr=300
c                        vphi=0
c                        nf=300
c                        vh=0
                        
c                        nh=300
c                        step=1



c                        norm=mchi2
c                        mchi2=0
                                              
                        max=-10000000
                        maxj=0
                        maxk=0
                        maxl=0
                        maxg=0
                        maxf=0
                        lnL=0
                        lll=0
                        
                     goto 222
c                  endif
                        
                  
               else
                  if(cont.eq.1)then


                  aa(h)=(rgal(h)**2-rgal(h-1)**2)/10000
c                  if(h.eq.nbin) aa(h)=b(ntot)**2-rgal(h-1)**2
c                  if(h.eq.1)aa(h)=rgal(h)**2-b(1)**2

                  if(eee0.eq.1)then

                  vphi=sqrt(((vr+maxk)**2)*0.5)

                  write(10,1010)max,vp+maxj,vr+maxk,
     &             vphi,
     &             vh+maxg,maxf,h,rgal_plot(h),mm(h),aa(h)

                  else

                  write(10,1010)max,vp+maxj,
     &             vr+maxk,
     &             vphi+maxl,
     &             vh+maxg,maxf,h,rgal_plot(h),mm(h),aa(h)

                  endif
                  
                     write(*,*)'find errors'

                     if((p0+p1+p2+p3).eq.0)chi2=6.63/2
                     if((p0+p1+p2+p3).eq.1)chi2=5.39/2
                     if((p0+p1+p2+p3).eq.2)chi2=4.11/2
                     if((p0+p1+p2+p3).eq.3)chi2=2.77/2



              write(*,*)'yuo have',5-(p0+p1+p2+p3),'free parameters'


c                   if((mm(h)-5+(p0+p1+p2+p3)-1).gt.45)then

c                         s3=86.7/2
c                         s3=79.5/2
c                         s3=76.2/2
c                        s3=71.4/2
c                         s3=67.5/2
c                     else
c                        if((mm(h)-5+(p0+p1+p2+p3)-1).gt.35)then
                           
c                           s3=73.4/2
c                            s3=66.8/2
c                            s3=63.7/2
c                           s3=59.3/2
c                            s3=55.8/2
c                        else

c                            s3=59.7/2
c                           s3=53.7/2
c                            s3=50.9/2
c                            s3=47.0/2
c                            s3=43.8/2
c                        endif
c                     endif



c                  rejm=(max-s3)/(mm(h)-1-5+(p0+p1+p2+p3))
c                  if(rejm.le.rejmin)rejmin=rejm
                  
                  write(*,*)max,mm(h)
c                  write(*,*)'pippo'
c                  read(*,*)yes


                     Lmax=max
                     cont=2

                  
                     max=-10000000
                     maxj=0
                     maxk=0
                     maxl=0
                     maxg=0
                     maxf=0
                     lnL=0
                     lll=0

                     vp=0
                     nv=400

                     vr=0
                     nr=300

                     vphi=0
                     if(eee0.ne.1)nf=300
                  

                     if(eee1.eq.1)then
                     vh=120
                     nh=1
                     else
                     vh=0
                     nh=300
                     endif


                     step=10

            
                  
                     goto 222
                                    
                  else

                     if(eee0.eq.1)then
                    errl_min=errk_min*sqrt(0.5)
                    errl_max=errk_max*sqrt(0.5)  
                    endif


                    write(77,20) errj_min+vp,errj_max+vp,errk_min+vr, 
     &                         errk_max+vr,errl_min+vphi,errl_max+vphi, 
     &                         errg_min+vh,errg_max+vh,errf_min,
     &                         errf_max
                  

c                  if(cont.eq.3)then
                     
c                  write(*,*) 'maxv',maxj,'max sigma_r',maxk,
c     &                 'max sigma_phi',maxl,'max sigma_halo',maxg,
c     &                 'max f',maxf
c                  write(*,*)'ok?'
c                  read(*,*)yes
c                  endif

                 endif
                 endif
               
               
               enddo
              
               close(77)

               write(*,*)'number of planetariae',n
               close(10)
c
 20          format(10(1x,f8.3))
 1010        format(10(1x,f8.3))
c rotation curve


 555            open(unit=32,file='velav.cat',status='unknown')
                open(unit=33,file='histov.dat',status='unknown')


                  do i=1,n

                        vhel_mM(i)=(vhel_av(i))
                                           
                         if(xs(i).lt.0)then



                             vhel_mM(i)=-(vhel_mM(i))
                          
                                                                             
                         endif

                         enddo


                nmax=4
                alpha=30*pi/180
                write(*,*) TAN(alpha)
                
                do i=1,nmax
                   velavR(i)=0
                   denR(i)=0
                   den(i)=0
                   sigmaR(i)=0
                enddo

                do i=1,nmax
                   velavB(i)=0
                   denB(i)=0
                   sigmaB(i)=0
                enddo




               supp(1)=66
c                supp(2)=70
c                supp(2)=108
                supp(2)=142
c                supp(2)=160
c                supp(2)=190
c                supp(4)=245
                supp(3)=242
c                supp(4)=265
c                supp(5)=500
                supp(4)=1100                              
                                    
                do j=1,nmax
                   do i=1,n
                                         
                        

c                      if((gg(i).ne.191).and.(gg(i).ne.43))then

                      dis(i)=abs(xs(i))*TAN(alpha)
                    
                     

c                      if(j.eq.nmax)dis(j)=200

                      if(((supp(j-1).le.abs(xs(i)))
     &                 .and.(abs(xs(i)).lt.supp(j)))
     &                     .and.((abs(ysi(i))).le.dis(i)))then

                         den(j)=den(j)+1

c                       if(((rs(i).lt.supp(j)))
c     &                     .and.((abs(ysi(i))).le.dis(j)))then
                     

c                         if(xs(i).gt.0)then


                          
                              
        
c                            velavB(j)=velavB(j)+(vhel_av(i))
c                            denB(j)=denB(j)+1
c                            write(33,*)vhel_av(i),xs(i)
                            
C                            if(denB(j).eq.20)
                         
c                         else

c                            velavR(j)=velavR(j)+(vhel_av(i))
c                            denR(j)=denR(j)+1

c                            velavR(j)=velavR(j)+(vhel_av(i))
c                            denR(j)=denR(j)+1
c                            write(33,*)vhel_av(i),xs(i)
                                                   
 

                           velavR(j)=velavR(j)+(vhel_mM(i))
                         
       
                      endif

c                   endif
                   enddo

                   enddo

                   do j=1,nmax
                       
c                      velavB(j)=velavB(j)/denB(j)
c                      velavR(j)=velavR(j)/denR(j)

                       velavR(j)=abs(velavR(j)/den(j))
                      
                      do i=1,n

c                         if((gg(i).ne.191).and.(gg(i).ne.43))then

                            if(((supp(j-1).le.abs(xs(i)))
     &                           .and.(abs(xs(i)).lt.supp(j)))
     &                           .and.((abs(ysi(i))).le.dis(i)))then
                     
c                               if(xs(i).gt.0)then
                         
c                                  sigmaB(j)=sigmaB(j)+((vhel_av(i))
c     &                                 -velavB(j))**2
                         
c                               else

c                                  sigmaR(j)=sigmaR(j)+((vhel_av(i))
c     &                                 -velavR(j))**2

c                               if(xs(i).lt.0)then

c                                  vhel_av(i)=-(vhel_av(i))

c                               endif
                                  sigmaR(j)=sigmaR(j)+(vhel_mM(i)
     &                                 -velavR(j))**2

                            endif
c                         endif
                      enddo
c                      sigmaB(j)=sqrt(sigmaB(j)/(denB(j)-1))
c                      sigmaR(j)=sqrt(sigmaR(j)/(denR(j)-1))

                      sigmaR(j)=sqrt(sigmaR(j)/(den(j)-1))                         

c                      write(*,*)velavB(j),denB(j),j,sigmaB(j),supp(j)
c                      write(*,*)velavR(j),denR(j),j,sigmaR(j),supp(j)

                       write(*,*)velavR(j),den(j),j,sigmaR(j),supp(j)

c                   if(j.eq.nmax)supp(j)=450
                   
                      write(32,*)velavB(j),sigmaB(j),supp(j),
     &                  velavR(j),sigmaR(j),j
                enddo
            
          
                close(32)      
                close(33)

                open(unit=16,file='velavmin.cat',status='unknown')

                nmax=4
                alpha=30*pi/180
  
                do i=1,nmax
                   velavR(i)=0
                   denR(i)=0
                   den(i)=0
                   sigmaR(i)=0
                enddo

                do i=1,nmax
                   velavB(i)=0
                   denB(i)=0
                   sigmaB(i)=0
                enddo

                supp(1)=60
c                supp(2)=70
c                 supp(2)=130
                supp(2)=158
c                supp(2)=160
c                supp(2)=190
                supp(3)=242
c                supp(4)=265
c                supp(3)=360
c                supp(10)=500
                supp(4)=1100                              
c                                    
                do j=1,nmax
                   do i=1,n

c                      if((gg(i).ne.191).and.(gg(i).ne.43))then

                         dis(i)=abs(ysi(i))*TAN(alpha)
c                         if(j.eq.nmax)dis(j)=200
                      

                         if(((supp(j-1).le.abs(ysi(i)))
     &                        .and.(abs(ysi(i)).lt.supp(j)))
     &                        .and.((abs(xs(i))).le.dis(i)))then
                     
                         den(j)=den(j)+1
c                            if(ysi(i).gt.0)then
c        
c                               velavB(j)=velavB(j)+(vhel_av(i))
c                               denB(j)=denB(j)+1
                            
                                                     
c                            else
c                            velavR(j)=velavR(j)+(vhel_av(i))
c                            denR(j)=denR(j)+1

c                         if(ysi(i).lt.0)then
                                
c                            vhel_av(i)=-(vhel_av(i))
                                                   
c                         endif
                         
                         velavR(j)=velavR(j)+(vhel_mM(i))  

                      endif
c                   endif
                enddo

             enddo

             do j=1,nmax
                       
c                velavB(j)=velavB(j)/denB(j)
c                velavR(j)=velavR(j)/denR(j)
                velavR(j)=abs(velavR(j)/den(j))   
                      
                do i=1,n
                   
c                   if((gg(i).ne.191).and.(gg(i).ne.43))then

                      if(((supp(j-1).le.abs(ysi(i)))
     &                     .and.(abs(ysi(i)).lt.supp(j)))
     &                     .and.((abs(xs(i))).le.dis(i)))then
                     

c                         if(ysi(i).gt.0)then
                         
c                            sigmaB(j)=sigmaB(j)+((vhel_av(i))
c     &                           -velavB(j))**2
                         
c                         else

c                            sigmaR(j)=sigmaR(j)+((vhel_av(i))
c     &                           -velavR(j))**2

c                         endif

c                         if(ysi(i).lt.0)then

c                            vhel_av(i)=-(vhel_av(i))

c                         endif

                         sigmaR(j)=sigmaR(j)+(vhel_mM(i)
     &                        -velavR(j))**2

                      endif
c                   endif
                enddo

c                sigmaB(j)=sqrt(sigmaB(j)/(denB(j)-1))
c                sigmaR(j)=sqrt(sigmaR(j)/(denR(j)-1))

                         
                sigmaR(j)=sqrt(sigmaR(j)/(den(j)-1))

c                write(*,*)velavB(j),denB(j),j,sigmaB(j),supp(j)
c                write(*,*)velavR(j),denR(j),j,sigmaR(j),supp(j)

                write(*,*)velavR(j),den(j),j,sigmaR(j),supp(j)

c     if(j.eq.nmax)supp(j)=450
                   
                write(16,*)velavB(j),sigmaB(j),supp(j),
     &               velavR(j),sigmaR(j),j
             enddo
            
          
             close(16)      

c             do i=1,n
c                write(*,*)vhel_mM(i), vhel_av(i)
c                enddo

              
c             write(*,*)tot
c             write(*,*)'sigma clipping?  0=no'
c             read(*,*) cc
c             if(cc.eq.0)goto 777

               
c     sigma clipping

               open(66,file="cleancatalogue.dat",status="unknown")
               open(10,file="likelihood.dat",status="unknown")
               open(17,file="unliky.dat",status="unknown")
               open(14,file="rejected.dat",status="unknown")
               open(23,file="unliky_d.dat",status="unknown")
               open(24,file="unliky_b.dat",status="unknown")

               
               g=0
               l=0
               likes=0
              
              
               do i=1,n
                  vvs(i)=0
               enddo

               do i=1,n
                  sigmas(i)=0
                  v_halos(i)=0
                  con(i)=0
                  bd(i)=1
                  bb(i)=0
                  sep(i)=0
               enddo

c              s3(h,o)=0

             

               do h=1,nbin
                  mm(h)=0

                  read(10,*)mxl(h),mxv(h),mxs(h),mxsv(h),mxh(h),mxf(h),
     &              s,s,mm(h)


c                         s3(1,1)=-8
c                         s3(2,1)=-7.7
c                         s3(3,1)=-7.6
c                         s3(4,1)=-7.4
c                          s3(5,1)=-7.3 


c                         s3(1,2)=-8
c                         s3(2,2)=-7.7
c                         s3(3,2)=-7.6
c                         s3(4,2)=-7.4
c                         s3(5,2)=-7.3 
                         
                        
c                         s3(1,3)=-8
c                         s3(2,3)=-7.7
c                         s3(3,3)=-7.6
c                         s3(4,3)=-7.2
c                         s3(5,3)=-7.1 
                         
                       
 

                  likes_av=0
c                  rej(oo,h)=(mxl(h)-s3)/(mm(h)-1-5+(p0+p1+p2+p3))
                  write(*,*)mxl(h),s3(h,o),mm(h)

c                  write(*,*)'pippo'
c                  read(*,*)yes

                

                  do i=1,n

                     if(eee3.eq.1)fb(i)=0

c                     bd(i)=1
c                     bb(i)=0
c                     con(i)=0

c                     if(((rgal(h-1)).le.rs(i)).and.
c     &                    (rs(i).lt.(rgal(h))))then


                     delta_b=1
                     delta_d=1

                     
c                     if(((rgal(h-1)).lt.rs(i)).and.
c     &                    (rs(i).le.(rgal(h))))then



                      if((int(rgal(h-1)).lt.int(rs(i))).and.
     &                    (int(rs(i)).le.int(rgal(h))))then


c                        delta_d=1
c                        bd(i)=0.5
c                     endif

c                     if(((rgal(h-1)).lt.rb(i)).and.
c     &                    (rb(i).le.(rgal(h))))then
c                        delta_b=1 
c                        bb(i)=0.5
c                        endif

c                     if((delta_b.eq.0).and.(delta_d.eq.0))goto 315


c                        delta_b=1
c                        delta_d=1
                  
                        sigmas(i)=sqrt((((mxs(h)*sin_i)**2)*
     &                       (sin_phi(i)**2))+
     &                       ((((mxsv(h)*sin_i))**2)*
     &                       (cos_phi(i)**2))) 

                      

                        vvs(i)=(((vhel_av(i)-(mxv(h)*sin_i
     &                       *(cos_phi(i))))**2))/(2*(sigmas(i)**2))

                        
c                        v_halos(i)=((vhel_av(i)-(0.6*mxh(g)*
c     &                               sin_i*cos_phi(i)))**2)/
c     &                               (2*(mxh(h)**2))

                        v_halos(i)=((vhel_av(i)**2)/
     &                              (2*(mxh(h)**2)))

c                         likes=log(((1-phot(h))*exp(-(vvs(i)))/
c     &                         sigmas(i))+(phot(h)*exp(-(v_halos(i)))/
c     &                         mxh(h)))


                        if(eee2.ne.1)then

c ln likelihood as it is, ie with the gaussian normalization factor in

                           likes=log((delta_d*(1-fb(i))*exp(-(vvs(i)))
     &                          /sigmas(i))+(delta_b*fb(i)*
     &                          exp(-(v_halos(i)))/mxh(h)))

c ln likelihood without normalization but without dividing for halo and disc

c                           likes=log((delta_d*(1-fb(i))*exp(-(vvs(i)))
c     &                          )+(delta_b*fb(i)*
c     &                          exp(-(v_halos(i)))))

c -chi2/2 = ln L without normalization diveded in disc and halo and weighted for f 

c                           likes=(log(1-fb(i))+(-(vvs(i))))
c     &                          +(log(fb(i))+(-(v_halos(i))))

                                 else
c     in case of a free photometric distribution
c
c                                 likes=log((((1-mxf(h))*exp(-(vvs(i))))
c     &                                +(mxf(h)*
c     &                                 exp(-(v_halos(i))))))

                                   likes=log(((1-mxf(h))*exp(-(vvs(i)))/
     &                                   sigmas(i))+(mxf(h)*
     &                                   exp(-(v_halos(i)))/
     &                                   (mxh(h))))
                                                                      
                              endif

                         likes_av=likes_av+likes

                         write(*,*)likes,fb(i),mxf(h),con(i),mm(h),ys(i)
                         write(*,*)'likelihood threshold',rej(oo,h),oo,h

c                         if(bd(i).eq.1)then
                         
c                         sep(i)=1

c                         if(bb(i).eq.bd(i))then

                         write(17,771)likes,
     &                        h,mm(h),xs(i),ysi(i),gg(i),vhel(i),o,
     &                        fb(i),ys(i),bb(i),bd(i)
c                         else
                            
c                            if(sep(i).eq.1)then
                            
c                          write(23,771)likes,
c     &                        h,mm(h),xs(i),ysi(i),gg(i),vhel_av(i),o,
c     &                        mxf(h),ys(i),bb(i),bd(i)
                         
c                          else
c                             write(24,771)likes,
c     &                        h,mm(h),xs(i),ysi(i),gg(i),vhel_av(i),o,
c     &                        mxf(h),ys(i),bb(i),bd(i)
                          
c                          endif   
c                          endif
                        if(likes.lt.s3(h,o)) then

                         
c                           con(i)=con(i)+1
                                                      
c                           if(con(i).eq.2)then
                              l=l+1
                               write(*,*)'**rejected***'
                              write(*,*)l,likes,i,gg(i),'cont',con(i)
c     if(bb(i).eq.bd(i))then
                              write(14,*)likes,h,mm(h),xs(i),ys(i),
     &                         gg(i),vhel(i),oo
c                           endif
c                        endif

                              else

c                           if(con(i).lt.2)then
c                              if(bb(i).eq.bd(i))then
                                 g=g+1
                                 theta(i)=theta(i)*180/pi
                                 write(66,*)x(i),y(i),theta(i),
     &                            vhel(i),fb(i),gg(i)
c                              endif
                           endif
                        endif



c                     else 
c                        if(rs(i).gt.rgal(h).and.h.eq.nbin) then
                  
c                           sigma(i)=sqrt(((mxs(h)**2)*
c     &                                (sin_phi(i)**2))+
c     &                                (((mxsv(h))**2)*
c     &                                (cos_phi(i)**2)))  

c                             vv(i)=(((vhel_av(i)-mxv(h))
c     &                          *(cos_phi(i)))**2)/((sigma(i)**2))

c                             if(sqrt(vv(i)).ge.3) then
c                                l=l+1
c                                write(*,*)l,vv(i),i,gg(i)

c                             else
c                                g=g+1
c                                theta(i)=theta(i)*180/pi
c                             write(66,*)x(i),y(i),theta(i),vhel(i),gg(i)
c                             endif
c                          endif
c                     endif
 315              enddo
                  write(*,*)likes_av/mm(h)
               enddo

 771           format(12(1x,f8.2))
               

               close(66)
               close(10)
c               close(17)

               write(*,*)g,l,n,nbin,oo
                write(*,*)s3(1,o),s3(2,o),s3(3,o),s3(4,o),s3(5,o)
               

c               write(*,*)'carry on?0=no'
               write(*,*)'yuo have',5-(p0+p1+p2+p3),'free parameters'
               write(*,*)'v_av=',av
c               read(*,*)lll

               if((l.eq.0).or.(lll.eq.0)) goto 777
               tot=0
               n=g
               o=o+1
               open(44,file="coord.dat",status="unknown")      
               open(15,file="bin.dat",status="unknown")
               open(12,file="vprofile.dat",status="unknown")
               open(10,file="likelihood.dat",status="unknown")
               open(77,file='error.dat',status='unknown')

               goto 666
                  

c     finding the minimum or the value that maximize L

c              do h=1,nbin

c                max=-100000000
c                maxj=0
c                maxk=0
c                maxl=0
c                nn=0

c                do j=1,nv,step
c                   do k=1,nr,step 
c                      do l=1,nf,step 
c                      do h=1,nbin
c                         nn=nn+1
c                         write(10,*) lnL(j,k,l,h),j,k,l,h,rgal(h),nn
   
c                         if(lnL(j,k,l,h).gt.max)then

c                            max=lnL(j,k,l,h)
c                            maxj=j
c                            maxk=k
c                            maxl=l 
                       
                       
c                         endif

c 
c                      enddo
c                   enddo
c                enddo

c                    write(*,*)'max lnL',max,' v_phi',maxj,' sigma_r',
c     &                 maxk,' sigma_phi',maxl,' nbin=', h,rgal(h),mm(h)

                    
c                   write(10,*) max,maxj,maxk,maxl,h,rgal(h),mm(h)   
                    
                    
c                 enddo

c 777        enddo

 777           close(44)
               close(12)
               close(17)
               close(14)
               close(15)
               stop
               end
