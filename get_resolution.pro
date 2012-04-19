; return the resolution (in Angstroms) by fitting a Gaussian to several sky lines
;
; input  - a 1D .fits file spectrum, already flattened and dispersion corrected
;
; output - the resolution in Angstroms of the spectrum
;
;
FUNCTION get_resolution, file

; suppress warning messages
!QUIET = 1

; read the fits file data and header
spec2d = readfits(file,head)

; get length of 2D spectrum
length = (size(spec2d))[1]

; define starting wavelength (in Angstroms)
lambda0 = strtrim(sxpar(head,'crval1'))

; define the dispersion axis (in Angstroms)
disp = strtrim(sxpar(head,'cd1_1'))
dispersion = findgen(length)*disp + lambda0

; figure out which observatory we're at
observatory = strlowcase(strtrim(sxpar(head,'OBSERVAT')))
allowed_uncertainty = 2.
default_res = 0.
CASE observatory OF
          'lick': begin
   		  ; print,"**Lick sky lines used**"
		  ; taken from Osterbrock and Martel,1992,PASP,104:76-82,1992 January

		  ; line centers in Angstroms
          	  ; 		 	   [HgI,   HgI,   HgI,     [OI],     [OI],     [OI],
                    center_wavelengths = [4047., 4358., 5460., 5577.338, 6300.304,    6362.,	$
		  ; 		              OH(5-1) P_1 3,  OH(6-2) P_1 3,  OH(7-3) P_1 3,  OH(8-4) P_1 3]
			      	                      7992.,          8429.,       8920.610,          9475.]
                  ; approximate Gaussian half-widths ( = stnd dev = sigma ) in Angstroms
                    halfwidth_wavelengths = [6.,6.,7.,7.,7.,7.,6.,6.,6.,6.]

		  ; get which side of the spectrograph we're on
		    side = strlowcase(strtrim(sxpar(head,'VERSION')))
                    side2 = strlowcase(strtrim(sxpar(head,'SPSIDE')))
		  ; define a range of acceptable resolutions
		    if (side EQ 'kastb') OR (side2 EQ 'blue') then begin
                       default_res = 4.
		    endif else begin
                       default_res = 10.
                       if (MAX(dispersion) LT 8800.) then default_res = 5.
		    endelse
                  end
          'keck': begin
                  ; print,"**Keck sky lines used**"
		  ; taken from LRIS website: www2.keck.hawaii.edu/inst/lris/skylines.html

                  ; line centers in Angstroms
		  ;                      [  [OI],  [OI],  [OI],  OH P_1(1.5),    OH P_1(2),
                    center_wavelengths = [ 5575., 6296., 6357.,        7313.,        7790.,       $
		  ;	  	                     OH P_1(2),  OH P_1(2.5),  OH P_1(3.5),  OH P_1(2),  OH P_1(3),
			                                 7961.,        8395.,        8425.,      8881.,      8914., $
		  ;	                                OH P_1,   OH P_1]
		 	                              9439.660, 9476.870]
                  ; approximate Gaussian half-widths ( = stnd dev = sigma ) in Angstroms
		    halfwidth_wavelengths = [4.,4.,4.,4.,4.,4.,4.,4.,4.,4.,4.,4.]/2.
                  
                  ; get instrument
                    instrume = strlowcase(strtrim(sxpar(head,'INSTRUME')))

                  ; DEIMOS 600 line grating
                    if instrume EQ 'deimos' then begin
                       default_res = 3.
                       allowed_uncertainty = 1.
                       synop = strlowcase(strtrim(sxpar(head,'SYNOPSIS')))
                       ; DEIMOS 1200 line grating
                       if (strpos(synop,'1200G') NE -1) then default_res = 1.5
                    endif else begin
                       ; (assume) LRIS
                       ; get which side of the spectrograph we're on
                       side = strlowcase(strtrim(sxpar(head,'INSTRUME')))
                       if side EQ 'lrisblue' then begin
                          grism = strlowcase(strtrim(sxpar(head,'GRISNAME')))
                          if grism EQ '300/5000' then default_res = 9.
                          if grism EQ '400/3400' then default_res = 6.5
                          if grism EQ '600/4000' then default_res = 4.5
                       endif else begin
                          grating = strlowcase(strtrim(sxpar(head,'GRANAME')))
                          if grating EQ '400/8500' then begin
                             date = strlowcase(strtrim(sxpar(head,'DATE-OBS')))
                             if date EQ 0 then date = strlowcase(strtrim(sxpar(head,'DATE')))
                             utdate = gettok(date,'-')
                             utdate = utdate + gettok(date,'-')
                             utdate = utdate + date
                             if utdate LT 20090601 then default_res = 7. $
                             else default_res = 6.
                          endif
                          if grating EQ '1200/7500' then begin
                             default_res = 3.
                             allowed_uncertainty = 1.
                          endif
                       endelse
                    endelse
                  end
          ELSE:   begin
                    print,"**** Unknown observatory: ",observatory," for ",file," in get_resolution.pro ****"
                    RETURN,0.
                  end
ENDCASE
if default_res EQ 0. then begin
   print,"**** Unknown instrumental setup for ",file," in get_resolution.pro ****"
   RETURN,0.
endif

; define the centers and widths of the lines in array indices
centers = round((center_wavelengths-lambda0)/disp)
widths = round(halfwidth_wavelengths/disp)

; see which lines have centers and at least 3/4 of the total line width within the data's range
temp = WHERE((centers-widths/2. GE 0),count)
low_cutoff = (SIZE(centers))[1] - count
temp = WHERE((centers+widths/2. GE length),count)
high_cutoff = (SIZE(centers))[1] - count - 1

; ignore lines that aren't mostly within the data's range
centers = centers[low_cutoff:high_cutoff]
widths = widths[low_cutoff:high_cutoff]

; define the left and right edges of the lines (half-width = 3*sigma)
lows = centers - widths*3
highs = centers + widths*3

; if the left edge of the first line goes too far
IF lows[0] LT 0 THEN lows[0] = 0
; if the right edge of the last line goes too far
IF highs[(size(highs))[1]-1] GE length THEN highs[(size(highs))[1]-1] = length-1

; plot entire 2d spectrum and highlight the lines used
;window,0
;plot,dispersion,spec2d[*,0,2]
;FOR i=0,(size(centers))[1]-1 DO BEGIN
;	oplot,dispersion[lows[i]:highs[i]],spec2d[lows[i]:highs[i],0,2],color=1000
;ENDFOR

; define array to hold the standard deviation of each line
sigmas = findgen((size(centers))[1])

; fit Gaussians to all lines
FOR i=0,(size(centers))[1]-1 DO BEGIN
	; define the initial guess for the Gaussian's parameters for each line:
	;  [peak value, mean, standard dev, average background level, background slope]
	params = [spec2d[centers[i],0,2], dispersion[centers[i]], widths[i], (spec2d[lows[i],0,2]+spec2d[highs[i],0,2])/2., 0.]

	; fit a Gaussian to the data while fixing the average background level
	; NOTE: fixing the average background level only changes the sigmas by at most ~0.2% (0.01A),
	;		 but "forces" the fits to line up nicely on top of the data when plotted together
	result = lmfit(dispersion[(lows[i]):(highs[i])], spec2d[(lows[i]):(highs[i]),0,2], $
		params, function_name = 'lmfitgauss',/DOUBLE, ITMAX=200, TOL=1.e-6,FITA=[1,1,1,0,1])

	; save standard deviation of fit
	sigmas[i] = params[2]

	; plot each line's data and fit
	;window,1
	;line_num = 'line #' + string(i+1)
	;plot,dispersion[(lows[i]):(highs[i])],spec2d[(lows[i]):(highs[i]),0,2],title=line_num
	;oplot,dispersion[lows[i]:highs[i]],gaussian(dispersion[lows[i]:highs[i]],params), col=1000

	; wait for user to make sure the fit is decent
	; if it isn't decent, then we might have a problem
	;print, "Press any key to continue...."
	;key = get_kbrd(1)
ENDFOR

; convert standard deviations into FWHM's...
FWHM2 = sigmas*2*sqrt(2*alog(2))
; ...ignoring where the FWHM is less than 0 or greater than 30
goodFWHM = WHERE(FWHM2 GT 0 AND FWHM2 LT 30)
IF goodFWHM[0] EQ -1 THEN BEGIN
    ; if all the FWHM fits failed, set the resolution to zero
    FWHM = [0,0]
ENDIF ELSE BEGIN
    ; else save only the FWHM fits that are good
    FWHM = FWHM2[goodFWHM]
ENDELSE

; plot resolutions to check for outliers and such
;window,2
;plot,indgen((size(FWHM))[1])+1,FWHM,psym=2,xrange=[0,((size(FWHM))[1]+1)],xtitle='Line #',ytitle='Resolution (Angstroms)',xtickinterval=1,xminor=1,yrange=[.8*min(FWHM),1.1*max(FWHM)]

; unsuppress warning messages
!QUIET = 0

; calculate median of all lines' resolution (FWHM) in Angstroms
medFWHM = median(FWHM,/EVEN)

; if Gaussian fitting failed
if (medFWHM GT (default_res+allowed_uncertainty)) or (medFWHM LT (default_res-allowed_uncertainty)) then begin
	print,"**** The resolution measurement for ",file," (probably) failed, using average resolution for instrumental setup. ****"
	RETURN,default_res
endif else begin
	RETURN,medFWHM
endelse

END
