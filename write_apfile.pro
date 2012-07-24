pro write_apfile,tracefile,apid,galnum,apsize_pix

if n_params() lt 2 then begin
    print,' Syntax - write_apfile,tracefile,apid,ygalnum,apsize_pix'
    print,' Syntax - write_apfile,"trace_sn04bu","id_sn04bu",4,10'
    print,' Also See - compute_apertures.pro'
    print,' WARNING: Your apfile can be written over!! This code writes an apfile with the name'
    print,'          that comes from inside the input apfile. If you want to keep that one then copy it and'
    print,'          rename it something else and it will not be written over.'
    print,' PURPOSE: Compute the lower and upper aperture values for a given aperturesize'
    print,'          for when the position to be extracted is different from ygal, but '
    print,'          galaxy is used for defining trace - default values for LRIS pre 2009'
    print,' INPUT: - apid = a simple table that has the number and y value of HII regions seen in implot'
    print,'        - tracefile = this is a previously created apfile that has the nucleus traced'
    print,'        - apsize = total aperturse size in pixels, e.g. -5:5 is 10 pixels'
    print,'        - ygal = the y value of the nucleus which should match the exact value in the apid table'
    print,'OUTPUT: lower,upper: to be used for apall when centering on galaxy for '
    print,'        trace but  wanting to extract HII regions'
    print,'        separation: separation b/w ygal and HIIregion in arcsec'
    print,'AFTER:  Run apall again and review the apertures, their backgrounds need to be edited'
    print,'        interactively and give the apertures titles to if you want eg :title HII_3'
    print,'        but do yourself a favor and do not title the first aperture because that can error'
    return
endif

n=0

;read the apidfile
readcol,apid,x,y,COUNT=ngood, /SILENT                       ;count how many apertures there are
readcol,apid,x,ygal, skipline=galnum-1, numline=1, /SILENT  ;retrieve the y value of the nucleus

;read the "name" of the tracefile. Can I name the file with this + pix?
readcol,tracefile,name, skipline=2, numline=1, FORMAT='(X,A)'

;read the x (dispersion) axis center (Halpha), low and high of the image
readcol,tracefile,xcenter,ycenter, skipline=5, numline=1, FORMAT='(X,A,A)',/SILENT
readcol,tracefile,xlow, skipline=6, numline=1, FORMAT='(X,A)',/SILENT
readcol,tracefile,xhigh, skipline=7, numline=1, FORMAT='(X,A)',/SILENT

;read in the coefficients of the trace from the tracefile
readcol,tracefile,coef1, skipline=21, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef2, skipline=22, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef3, skipline=23, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef4, skipline=24, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef5, skipline=25, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef6, skipline=26, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef7, skipline=27, numline=1, FORMAT='(A)',/SILENT
readcol,tracefile,coef8, skipline=28, numline=1, FORMAT='(A)',/SILENT

    openw,u,'ap'+name,/get_lun
    print,"REGION             LOWER     UPPER     CENTER ArcSecSep  BACKGROUND(-20:-10,10:20)"

repeat begin

   readcol,apid,x,yh2, skipline = n, numline = 1, /SILENT

 lowerval = (-ygal+yh2) - (apsize_pix/2.)
 upperval = (-ygal+yh2) + (apsize_pix/2.)
 h2sep = (yh2-ygal)*0.135
 sam1 =  (-ygal+yh2) - 20.0
 sam2 =  (-ygal+yh2) - 10.0
 sam3 =  (-ygal+yh2) + 10.0
 sam4 =  (-ygal+yh2) + 20.0

;here is an attempt to fix the background problem
  str1=string(sam1)
  str2=string(sam2)
  str12=str1+str2
  left=strjoin(strsplit(str12, /EXTRACT),':')
  remchar,left, '00'

  str3=string(sam3)
  str4=string(sam4)
  str34=str3+str4
  right=strjoin(strsplit(str34, /EXTRACT),':')
  remchar,right, '00'

; print,left,right


;    print,"REGION             LOWER     UPPER   CENTER ArcSecSep  BACKGROUND(-20:-10,10:20)"
    print,'HII region',n+1,' =',lowerval,upperval,yh2,h2sep,sam1,':',sam2,',',sam3,':',sam4, $
          FORMAT='(A10,I2,A2,5F10.1,A1,F+-10.1,T71,A1,F+-10.1,T77,A1,F+-10.1)'
;    print,'HII region',n+1,' =',lowerval,upperval,yh2,h2sep,sam1,':',sam2,',', $
;          FORMAT='(A10,I2,A2,5F10.1,A1,F-10.1,T71,A1)'

 printf,u,'# ',systime()
 printf,u,'begin	aperture ',name,n+1,xcenter,ycenter, FORMAT='(A,A,I2,X,A,X,A)'
 printf,u,'	image	',name, FORMAT='(A,A)'
 printf,u,'	aperture	',n+1, FORMAT='(A,I1)'
 printf,u,'	beam	',n+1, FORMAT='(A,I1)'
 printf,u,'	center	',xcenter,ycenter, FORMAT='(A,A,X,A)'
 printf,u,'	low	',xlow,lowerval, FORMAT='(A,A,X,F-10.1)'
 printf,u,'	high	',xhigh,upperval, FORMAT='(A,A,X,F-10.1)'
 printf,u,'	background'
 printf,u,'		xmin ',sam1, FORMAT='(A,F-10.1)'
 printf,u,'		xmax ',sam4, FORMAT='(A,F-10.1)'
 printf,u,'		function legendre'
 printf,u,'		order 2'
 printf,u,'		sample  ',sam1,':',sam2,',',sam3,':',sam4, $
         		FORMAT='(A,F+-10.1,T16,A1,F+-10.1,T22,A1,F+-10.1,T28,A1,F+-10.1)'
 printf,u,'		naverage -100'
 printf,u,'		niterate 3'
 printf,u,'		low_reject 3.'
 printf,u,'		high_reject 3.'
 printf,u,'		grow 0.'
 printf,u,'	axis	',2, FORMAT='(A,I1)'
 printf,u,'	curve	',8, FORMAT='(A,I1)'
 printf,u,'		',coef1, FORMAT='(A,A)'
 printf,u,'		',coef2, FORMAT='(A,A)'
 printf,u,'		',coef3, FORMAT='(A,A)'
 printf,u,'		',coef4, FORMAT='(A,A)'
 printf,u,'		',coef5, FORMAT='(A,A)'
 printf,u,'		',coef6, FORMAT='(A,A)'
 printf,u,'		',coef7, FORMAT='(A,A)'
 printf,u,'		',coef8, FORMAT='(A,A)'
 printf,u,''

    n=n+1

endrep until n eq ngood

free_lun,u

stop
end
