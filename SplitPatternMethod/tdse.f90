! T‎his is a fortran code for solving time dependent Schrodinger Equation using 
! split pattern method (Contains methods using fft and dft)

program main

use constants
implicit none
integer::i,j,m,k
real::km,t,absolute 
real,dimension(256)::x,v
complex,dimension(256)::psi0,phi,diff,psit,psit2
complex::sumwave
character(20)::filename

!calculating the values of x and V grid
open(unit = 10,file = './datafiles/potential.txt')
x(1) = xmin
v(1) = 0.0
do i = 2,256
x(i) = x(i-1) + 0.02
if(x(i).ge.0)then
v(i) = 0.1
else
v(i) = 0.0
endif
write(10,*)x(i),v(i)
enddo

! Initial gaussian wave packet
open(unit = 11,file = './datafiles/psi0.')
do i=1,256
psi0(i) = ((2*alpha)/pi)**0.25 * exp((-1)*alpha*((x(i)-x0)**2)) * exp(iota*p0*(x(i)-x0))
write(11,*)x(i),absolute(psi0(i)) !This is for plotting psi square vs x grid
enddo

! Extending psi at time t=0 to all times
psit = psi0
t = 0.2
do k = 1,steps

do i = 1,256
psit(i) = psit(i)*exp((-1)*iota*dt*v(i)*0.5)
enddo

! Start of fourier transform
diff = psit !Comment out in case of dft
!call fourier(psit,phi,x,diff) !This is for dft
! Start fft
call fft (diff,256,1)	
do m=1,256
diff(m) = diff(m) * exp((iota*dt*(km(m)**2) * (-1))/(2*mass))
enddo
call fft (diff,256,-1)	!This will do the inverse fourier transform
diff = diff/real(256)
! End fft

! Creating a file for each 100th step
write(filename,1)t
1 format('./datafiles/psi',f4.0)
if(mod(k,100).eq.0)then
open(unit = 5,file = filename)
endif

! Finding next wave packet
do i=1,256
psit2(i) = exp((-1)*iota*dt*v(i)*0.5) * diff(i)
if(mod(k,100).eq.0)then
print*,'Value of t:',t,'Wavefunction:',psit2(i)
write(5,*)x(i),absolute(psit2(i)) !This is for plotting psi square vs x grid
endif
enddo

if(mod(k,100).eq.0) close(5)	! Closing the file

t = t+dt
psit = psit2
enddo



end program main

!-------------------------------------------------------------End of main----------------------------------------------------

! Function to find Km
function km(m)
use constants
real::L,N,km
integer::m
N = 256.0
L = 256*0.02
if(m.lt.N/2.0) then 
km = (2.0*pi*m)/L
else if(m.ge.n/2.0) then
km = (2.0*pi*(m-N))/L
endif
return
end function km

! Function to find psi squared
function absolute(psi)
complex::psi
absolute = real(psi)**2 + aimag(psi)**2
return 
end function absolute


! Subroutine for Double differentiation using Fourier Transform
subroutine fourier(psit,phi,x,diff)
use constants
integer::j,m
real::km,t
real,dimension(256)::x
complex,dimension(256)::phi,diff,psit
complex::sumwave


do m = 1,256
sumwave = 0.0
do j = 1,256
sumwave = sumwave + psit(j)*exp((-1)*iota*km(m)*x(j))
enddo
sumwave = sumwave/(sqrt(256.0))
phi(m) = sumwave * exp((iota*dt*(km(m)**2) * (-1))/(2*mass))
enddo

do j = 1,256
sumwave = 0.0
do m = 1,256
sumwave = sumwave + phi(m)*exp(iota*km(m)*x(j))
enddo
sumwave = sumwave/(sqrt(256.0))
diff(j) = sumwave
enddo
end subroutine fourier
