pro compute_offset,leg1,leg2



if n_params() lt 2 then begin
    print,' Syntax - compute_offset,leg1,leg2'
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

hyp =  (leg1^2 + leg2^2)
arc =  sqrt(hyp)
pix =  arc/.135

print, 'LEG1       LEG2 ARCSECONDS PIXELS'
print, leg1,leg2,arc,pix, Format='(4F-10.2)'

stop
end
