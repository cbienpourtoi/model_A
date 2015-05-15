      program ffinder

      parameter(m=10000)

      double precision xb(m),yb(m),sb(m),fb(m)
      double precision xd(m),yd(m),sd(m),fd(m),ftot(m),f(m)
      double precision sub(m),areb(m),sut(m),aret(m),f2(m)
      double precision xf(m),yf(m),sf(m),ff(m),suf(m),aref(m),idf(m)
      integer idb(m),idd(m)


      open(1,file='phot/NABall_nb.txt',status='old')
      open(2,file='phot/NATall_nb.txt',status='old')
      open(4,file='phot/NAFall_nb.txt',status='old')
      open(3,file='phot/NA9_f.dat',status='unknown')
c     TODO: change number previous line (iterative) - 
c     or always the same? Use python to rename file 
c     instead of using a iterator

      do i=1,m
         n=n+1
         write(*,*)'ĺoic is amazing'
         

         read(1,*,end=11)xb(i),yb(i),sb(i),fb(i),sub(i),areb(i),idb(i)
         read(2,*,end=22)xd(i),yd(i),sd(i),ftot(i),sut(i),aret(i),idd(i)
         read(4,*,end=44)xf(i),yf(i),sf(i),ff(i),suf(i),aref(i),idf(i)

c         ftot(i)=fb(i)+fd(i)

         f(i)=fb(i)/ftot(i)
         f2(i)=ff(i)/aref(i)

         write(3,*)f(i),f2(i),idb(i)

         enddo

 11      close(1)
 22      close(2)
         close(3)
 44      close(4)

         stop
         end



