; return the seeing (in arcsec) by fitting a Gaussian to a crosscut of a point source
;
; input  - a 2D .fits file spectrum (preferrably flattened)
;
; output - the seeing in arcseconds, assuming the object is a point source;
;		   if the calculated seeing is not in the range 0.5 <= x <= 10.0, it is
;		   assumed that the object was not a point source or that the Gaussian
;		   fit used to calculate the seeing failed somehow and 0.0 is returned
;
;
FUNCTION get_seeing, file

; suppress warning messages
!QUIET = 1

; read the fits file data and header
spec2d = readfits(file,head)

; figure out which instrument we're using
instrument = strlowcase(strtrim(sxpar(head,'INSTRUME')))
if strcompress(instrument,/remove_all) EQ '0' then instrument = strlowcase(strtrim(sxpar(head,'VERSION')))
CASE instrument OF
	 'kastr': begin
		    ; Kast on the 3-m at Lick
                    ; taken from http://mtham.ucolick.org/techdocs/instruments/kast/hw_detectors.html
		    ; print,"Instrument used is Kastr"
		      disp = 0.798
                      end
         'kastb': begin
		    ; Kast on the 3-m at Lick
                    ; taken from http://mtham.ucolick.org/techdocs/instruments/kast/hw_detectors.html
		    ; print,"Instrument used is Kastb"
		      disp = 0.43
		      end
'kast spectrograph': begin
                     ; print,"Instrument used is Kast"
                      disp = 0.798
                      end
             'kast': begin
                     ; print,"Instrument used is Kast"
                      disp = 0.798
                      end
	'deimos': begin
		    ; DEIMOS on Keck II
		    ; assuming a 15 micron pixel, taken from http://www2.keck.hawaii.edu/inst/deimos/specs.html
		    ; print,"Instrument used is DEIMOS"
		      disp = 0.1185
		      end
	   'esi': begin
		    ; ESI on Keck II
		    ; below is the imaging pixel scale, the website below has
		    ; 	the pixel scales for each of the ten echellette orders
            	    ; 	http://www2.keck.hawaii.edu/inst/esi/QuickRef.html#E_Scales
		    ; print,"Instrument used is ESI"
		      disp = 0.1542
		      end
	  'lris': begin
		    ; LRIS on Keck I
		    ; taken from http://www2.keck.hawaii.edu/inst/lris/detectors.html
		    ; print,"Instrument used is LRIS"
		      disp = 0.135;0.215
		      end
      'lrisblue': begin
		    ; LRIS on Keck I
		    ; taken from http://www2.keck.hawaii.edu/inst/lris/detectors.html
		    ; print,"Instrument used is LRISBLUE"
		      disp = 0.135
		      end
	    ELSE: begin
		      print,"**** Unknown instrument : ",instrument," in get_seeing.pro ****"
		      return,0
	          end
ENDCASE

; get length and width of the 2D spectrum
length = (SIZE(spec2d))[1]
width = (SIZE(spec2d))[2]

; initialize array of seeing values from across the chip
seeings = fltarr(9)

; loop through sections of the chip and calculate the seeing in each section
for k=1,9 do begin

	; define the center of the section
	center_col = length/10.0*k

	; get the region to sum the flux over
	sum_region_low = center_col - 20
	sum_region_high = center_col + 20

	; array of fluxes
	sum_spec = fltarr(width)*0.0

	; loop through 2D spectrum and add up flux
	FOR i = 0, width - 1 DO sum_spec[i] = total(spec2d[sum_region_low:sum_region_high, i])
	
	; define the dispersion axis (in arcsec)
	dispersion = findgen(width)*disp

        if (instrument EQ 'lris') OR (instrument EQ 'lrisblue') then begin
            sum_spec = sum_spec[width/2:width-1]
            dispersion = dispersion[width/2:width-1]

             ; mask out huge spike due to chip gap
             ;    and/or stupid masking of rows in bias correction
            cut = WHERE(sum_spec GT 1.e5)
            if cut[0] NE -1 then sum_spec[cut] = median(sum_spec)
            ;plot,dispersion,sum_spec
         endif

	; find the peak for the Gaussian (assumed to be the highest point in the 2D spectrum)
	peak = WHERE(sum_spec EQ MAX(sum_spec))
	
	; define the initial guess for the Gaussian's parameters:
	;  [peak value, mean, standard dev, average background level, background slope]
	params = [sum_spec[peak], dispersion[peak], 2., median(sum_spec), 0.]
        ;print,params

	; fit a Gaussian to the data
	result = lmfit(dispersion, sum_spec, params, function_name = 'lmfitgauss',/DOUBLE, ITMAX=200, TOL=1.e-6)

	; plot the data and the fit just to check
	;window,0
	;titlestring = file + ' Fit #' + string(k)
	;plot, dispersion, sum_spec, psym=10,title=titlestring
	;oplot, dispersion, gaussian(dispersion,params), col=1000
	;print, "Press any key to continue...."
        ;key = get_kbrd(1)

	; calculate seeing (FWHM) in arcsec
	seeings[k-1] = params[2]*2*sqrt(2*alog(2))

endfor

; unsuppress warning messages
!QUIET = 0

; get the average seeing from across the entire chip,
;  ignoring where the seeing is less than 0 or greater than 1
goodseeings = WHERE(seeings GT 0 AND seeings LT 10)
IF goodseeings[0] EQ -1 THEN BEGIN
    ; if all the seeing fits failed, set the seeing to zero
    seeings2 = [0,0]
ENDIF ELSE BEGIN
    ; else save only the seeing fits that are good
    seeings2 = seeings[goodseeings]
ENDELSE

; plot the seeing across the chip
;window,1
;plot,length/10.*[1,2,3,4,5,6,7,8,9],seeings,psym=2

; calculate mediam of all good seeings
seeing = median(seeings2,/EVEN)

; if Gaussian fitting failed
if (seeing GE 5.0) or (seeing LE 0.5) then begin
	print,"**** The Gaussian fit used to calculate the seeing for ",file," (probably) failed! ****"
	RETURN,0.0
endif else begin
	RETURN,seeing
endelse

END
