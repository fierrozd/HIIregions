pro write_apfile,apid,tracefile,apsize_pix,ygal,ygal_b

if n_params() lt 2 then begin
    print,' Syntax - write_apfile,apid,apsize_pix,ygalred,ygalblue'
    print,' Syntax - write_apfile,"sn04bu","trace",10,643,754.4'
    print,' Also See - compute_apertures.pro'
    print,' PURPOSE: Compute the lower and upper aperture values for a given aperturesize'
    print,'          for when the position to be extracted is different from ygal, but '
    print,'          galaxy is used for defining trace - default values for LRIS pre 2009'
    print,' INPUT: - apsize = total aperturse size in pixels, e.g. -5:5 is 10 pixels'
    print,'        - ygal = read from curser  where the center of galaxy at Halpha is -RED'
    print,'        PROMPTED: other y values for HII regions'
    print,' KEYWORD: - /blue  = when wanting to extract on blue side: '
    print,'                     input the same values as for red side and  '
    print,'                     script will compute values for the pixel scale of blue CCD'
    print,'OUTPUT: lower,upper: to be used for apall when centering on galaxy for '
    print,'        trace but  wanting to extract HII regions'
    print,'        separation: separation b/w ygal and HIIregion in arcsec'
    return
endif

n=0

readcol,apid,x,COUNT=ngood, /SILENT ;count how many apertures there are in apid

;read the "name" of the tracefile. Can I name the file with this + pix?
readcol,tracefile,name, skipline=2, numline=1, FORMAT='(X,A)'

;read the x (dispersion) axis center (Halpha), low and high of the image
readcol,tracefile,xcenter, skipline=5, numline=1, FORMAT='(X,A5)',/SILENT
readcol,tracefile,xlow, skipline=6, numline=1, FORMAT='(X,A6)',/SILENT
readcol,tracefile,xhigh, skipline=7, numline=1, FORMAT='(X,A5)',/SILENT

;read in the coefficients of the trace from the tracefile
readcol,tracefile,coef1, skipline=21, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef2, skipline=22, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef3, skipline=23, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef4, skipline=24, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef5, skipline=25, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef6, skipline=26, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef7, skipline=27, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef8, skipline=28, numline=1, FORMAT='(A)',/SILENT

repeat begin

   readcol,apid,x,yh2, $
	skipline = n, numline = 1, /SILENT

 lowerval = (-ygal+yh2) - (apsize_pix/2.)
 upperval = (-ygal+yh2) + (apsize_pix/2.)
 yh2_b = ygal_b - (ygal-yh2)
 h2sep = (yh2-ygal)*0.135
 sam1 =  (-ygal+yh2) - 20
 sam2 =  (-ygal+yh2) - 10
 sam3 =  (-ygal+yh2) + 10
 sam4 =  (-ygal+yh2) + 20


;    print,"REGION             LOWER     UPPER   CENTERRed CENTERBlue ArcSecSep  BACKGROUND(-20:-10,10:20)"
;    print,'HII region',n+1,' =',lowerval,upperval,yh2,yh2_b,h2sep,sam1,':',sam2,',',sam3,':',sam4, $
;          FORMAT='(A10,I2,A2,6F10.1,A1,F-10.1,T81,A1,F-10.1,T87,A1,F-10.1)'
    print,'# ',systime()
    print,'begin	aperture ',name,n+1,xcenter,ygal, FORMAT='(A,A,I2,X,A,X,F-10.1)'
    print,'	image	',name, FORMAT='(A,A)'
    print,'	aperture	',n+1, FORMAT='(A,I1)'
    print,'	beam	',n+1, FORMAT='(A,I1)'
    print,'	center	',xcenter,ygal, FORMAT='(A,A,X,F-10.1)'
    print,'	low	',xlow,lowerval, FORMAT='(A,A,X,F-10.1)'
    print,'	high	',xhigh,upperval, FORMAT='(A,A,X,F-10.1)'
    print,'	background'
    print,'		xmin ',sam1, FORMAT='(A,F-10.1)'
    print,'		xmax ',sam4, FORMAT='(A,F-10.1)'
    print,'		function legendre'
    print,'		order 2'
    print,'		sample  ',sam1,':',sam2,',',sam3,':',sam4, $
         		FORMAT='(A,F-10.1,T16,A1,F-10.1,T22,A1,F-10.1,T28,A1,F-10.1)'
    print,'		naverage -100'
    print,'		niterate 3'
    print,'		low_reject 3.'
    print,'		high_reject 3.'
    print,'		grow 0.'
    print,'	axis	',2, FORMAT='(A,I1)'
    print,'	curve	',8, FORMAT='(A,I1)'
    print,'		',coef1, FORMAT='(A,A)'
    print,'		',coef2, FORMAT='(A,A)'
    print,'		',coef3, FORMAT='(A,A)'
    print,'		',coef4, FORMAT='(A,A)'
    print,'		',coef5, FORMAT='(A,A)'
    print,'		',coef6, FORMAT='(A,A)'
    print,'		',coef7, FORMAT='(A,A)'
    print,'		',coef8, FORMAT='(A,A)'
    print,''

    n=n+1

endrep until n eq ngood

stop
end
