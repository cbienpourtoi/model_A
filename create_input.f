      program create_input

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
      


        write(1,*)xp,yp,xs,ys,ps,Rc,Dc,pa,incl,vned,nbin

      stop
      end
