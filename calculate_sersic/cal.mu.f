      program calc

c this program calculates mue mud from galfit output parameters, if known you can give c0(dixinex boxiness parameter), if not write c0=0. Now it is set for having n=4, or n=4.65, but you can change it just decomment fat!

      parameter(m=10000,pi=3.14)

      double precision ce,rce,qe,re,n,betae,mtote,itote,mue
      double precision cd,rcd,qd,rd,betad,mtotd,itotd,mud
      double precision bn, fb, fd, frac, frac2, fat
      integer nn

      rce=1
      rcd=1
      
      write(*,*)'calculate R(C) bulge'
      write(*,*)'give me c, diskiness boxiness parameter'
      read(*,*)ce
 
      
      if(ce.eq.0) goto 111
      ce=1/(ce+2)
      
      
      betae=sqrt(2*pi)*((ce**(ce-0.5)*(ce+1)**(ce+1-0.5))/
     &     ((ce+ce+1)**(ce+ce+1-0.5)))

      write(*,*)betae

      rce=pi*(ce**-1)/(4*betae)

 111  write(*,*)'R(C)',rce

      write(*,*)'calculate mu_e'
      write(*,*)'give me mtot, q (b/a), Re, n'
      read(*,*)mtote,qe,re,n
      
      itote=10**(mtote/-2.5)

      

      write(*,*)itote, mtote/-2.5
      
c      mue=rce*itote/(qe*re**2*2*pi**(3/2)*sqrt(n))

       bn=1.9992*n-0.3271

c       write(*,*)'give me fat, (2n-1)!'

c       read(*,*)fat

c       fat=716430.7 

       fat=5040

       mue=rce*itote/(qe*re**2*2*pi*n*bn**(-2*n)*exp(bn)*fat)

      write(*,*)mue,itote,qe,re,bn,n,fat,pi
      
      mue=-2.5 * log10(mue)

     

      write(*,*)mue


      write(*,*)'calculate R(C) disk'
      write(*,*)'give me c, diskiness boxiness parameter'
      read(*,*)cd

      if(cd.eq.0) goto 222
      
      cd=1/(cd+2)
      
      
      betad=sqrt(2*pi)*((cd**(cd-0.5)*(cd+1)**(cd+1-0.5))/
     &     ((cd+cd+1)**(cd+cd+1-0.5)))

      write(*,*)betad

      rcd=pi*(cd**-1)/(4*betad)

 222  write(*,*)'R(C)',rcd

      write(*,*)'calculate mu_d'
      write(*,*)'give me mtot, q (b/a), Rd'
      read(*,*)mtotd,qd,rd
      
      itotd=10**(mtotd/-2.5)

      

      write(*,*)itotd, mtotd/-2.5
      
      mud=rcd*itotd/(qd*rd**2*2*pi)

      write(*,*)mud,qd,rd,pi,itotd
      
      mud=-2.5 * log10(mud)

      write(*,*)mud

      write(*,*)'B/T'

c      nn=int(2*n-1)

c      write(*,*)nn

c      fat=nn

     

c      do i=1,nn-1

c         fat=fat*(nn-i) 

c         enddo

     

c     for n=4.65

         write(*,*)fat,bn

           mue=10**(mue/-2.5)


c         fb=fat * exp(bn) * bn**(-2*n)* 2 * pi* re**2 *mue *qe *n 
c         fb=sqrt(n)* 2 * pi**(2/3)* re**2 *mue *qe

         fb=rce*mue*(qe*re**2*2*pi*n*bn**(-2*n)*exp(bn)*fat)

         write(*,*)fb,mue,itote,qe,re,bn,n,fat,pi

           mud=10**(mud/-2.5)

         fd=2*pi*rd**2 * mud *qd

         write(*,*)fd,mud,qd,rd,pi,itotd

         frac=fb/(fb+fd)
         frac2=itote/(itote+itotd)
         
         write(*,*)fd,fb,itotd,itote

         write(*,*)frac,frac2
         

      stop
      end
