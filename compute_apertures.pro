pro compute_apertures,apsize_pix,ygal,ygal_b,blue=blue



if n_params() lt 2 then begin
    print,' Syntax - compute_apertures,apsize_pix,ygalred,ygalblue,/blue'
    print,' Syntax - compute_apertures,10,643,754.4,/blue'
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

n=1

startline:
read,'Enter yval HII regions = ',yh2

;blueside_factor = 1.56296 ;for LRIS blue and red sides - pre 2009 06/01
blueside_factor = 1       ;for LRIS blue and red sides - post 2009 06/01
lowerval = (-ygal+yh2) - (apsize_pix/2.)
upperval = (-ygal+yh2) + (apsize_pix/2.)
yh2_b = ygal_b - (ygal-yh2)
h2sep = (yh2-ygal)*0.135
sam1 =  (-ygal+yh2) - 20
sam2 =  (-ygal+yh2) - 10
sam3 =  (-ygal+yh2) + 10
sam4 =  (-ygal+yh2) + 20


IF KEYWORD_SET(blue) THEN BEGIN
    lowerval_b = (-ygal+yh2)* blueside_factor - [ (apsize_pix/2.) * blueside_factor]
    upperval_b = (-ygal+yh2)* blueside_factor + [ (apsize_pix/2.) * blueside_factor]

    print,"REGION             LOWER     UPPER   CENTERRed CENTERBlue ArcSecSep  BACKGROUND(-20:-10,10:20)"
    print,'HII region',n,' =',lowerval,upperval,yh2,yh2_b,h2sep,sam1,':',sam2,',',sam3,':',sam4, $
          FORMAT='(A10,I2,A2,6F10.1,A1,F-10.1,T81,A1,F-10.1,T87,A1,F-10.1)'
    print,'	aperture	',n, FORMAT='(A,I1)'
    print,'	beam	',n, FORMAT='(A,I1)'
    print,'	center	1088. ',ygal, FORMAT='(A,F-10.1)'
    print,'	low	-1087. ',lowerval, FORMAT='(A,F-10.1)'
    print,'	high	3008. ',upperval, FORMAT='(A,F-10.1)'
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


ENDIF ELSE BEGIN

;    print,'Lower value for 1st HII region = ',lowerval
;    print,'Upper value for 1st HII region = ',upperval
    lowerval_b = (-ygal+yh2)* blueside_factor - [ (apsize_pix/2.) * blueside_factor]
    upperval_b = (-ygal+yh2)* blueside_factor + [ (apsize_pix/2.) * blueside_factor]
    print,"REGION             LOWER     UPPER   CENTERRed CENTERBlue ArcSecSep  BACKGROUND(-20:-10,10:20)"
    print,'HII region',n,' =',lowerval,upperval,yh2,yh2_b,h2sep,sam1,':',sam2,',',sam3,':',sam4, $
          FORMAT='(A10,I2,A2,6F10.1,A1,F-10.1,T81,A1,F-10.1,T87,A1,F-10.1)'

ENDELSE

;h2sep = (yh2-ygal)*0.211
;print,'Separation b/w galaxy center and HII region:',h2sep
;print,'The y value for this region in the red and blue should be at',yh2,yh2_b
done=''
read,"Are you done? (y=y)",done
IF done EQ 'y' THEN BEGIN
    GOTO,fini
ENDIF ELSE BEGIN
    n=n+1
    goto,startline
ENDELSE


fini:
stop
end
