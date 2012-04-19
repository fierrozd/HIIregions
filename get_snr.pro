; return the (approximate) signal-to-noise ratio (SNR) by subtracting a smoothed version of the spectrum
;	from the spectrum itself to get an approximate noise spectrum and then dividing the actual spectrum
;	by the noise spectrum
;
; input  - an ASCII file with two columns: wavelength (in Angstroms) and Flux (in F_lambda);
;		   usually a .flm file
;
; output - an approximation of the signal-to-noise ratio
;
;
FUNCTION get_snr, file

; suppress warning messages
!QUIET = 1

; read the fits file data and header
rdfloat,file,wavelength,data

; get the pixel scale
pixel_scale = median((wavelength-shift(wavelength,1)),/even)

; smooth the spectrum
smoothed_data = smooth(data,50./pixel_scale,/edge_truncate)

; subtract the smoothed data from the actual data
noise = abs(data - smoothed_data)

; plot the actual data, the smoothed data, and the noise
; plot,wavelength,data
; oplot,wavelength,smoothed_data,col=1000
; oplot,wavelength,noise,col=50000,psym=1

; calculate the SNR of each pixel where noise is nonzero
; if noise *is* zero, then set SNR at that pixel to ~Inf
snr_array = data*0+1e6
nonzeros = where(noise NE 0)
snr_array(nonzeros) = data(nonzeros) / noise(nonzeros)

; get the median SNR while ignoring non-positive values (coming from negative data)
snr = median(snr_array(where(snr_array GT 0)),/even)

; unsuppress warning messages
!QUIET = 0

; return SNR
return,snr

END
