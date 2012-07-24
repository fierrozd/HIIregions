pro dplotter,infile1,infile2,infile3,infile4,infile5,infile6,infile7

IF N_PARAMS() EQ 0 THEN BEGIN
    print,'SYNTAX: dplotter,infile'
    print,'        Program to take a iraf splot log and grab the useful information'
    print,'        and put it into a nice table format'
    print,'INPUT: -infile = Splot log with measured line fluxes etc in the following format'
    print,'                center      cont      flux       eqw      core     gfwhm     lfwhm '
    print,'         e.g.   7077.229  1237.586   18059.7    -14.59    2752.8     6.163        0.'
    print,'NOTES:  flux      = measured emission line flux [usually using splot in IRAF-> "k"]'
    print,'        ew        = measured equivalent width '
    print,'        n1,n2     = wavelengths n1 and n2 [in A] for start and end of line'
    print,'                     HOW TO MEASURE IT: in splot, mark "m" near line using'
    print,'                                        200A box redward of all lines except [NII],Ha'
    print,'                                        choose rms value. Use "m" on both sides '
    print,'                                         of the line, and take an average'
    print,'                                        AVOID sky lines and other lines'
    print,'        z_gal     = redshift of galaxy   '          
    print,'        Delta_gal = wavelength dispersion in A/pixel of telescope/instrument'
    print,""
    print,'OUTPUT: on commandline: wavelength, flux, flux_err'
ENDIF


set_plot, 'ps'            ; create a copy in a postcript file

PLOTSYM, 3          ;activate star symbol (3) for sym number eight

readcol,'results.txt', bx, by, erry, f='f,f,f'
plot,bx,by,/NODATA, xtitle='Wavelength', ytitle='Flux', title='SN2004bu', $
	xrange=[min(bx)-5,max(bx)+5], yrange=[min(by)-min(by)*0.1, max(by)+max(by)*0.1]

readcol,infile1, x, y, erry,f='f,f,f'
oploterr, x, y, erry, 5

readcol,infile2, x, y, erry,f='f,f,f'
oploterr, x, y, erry, 6

readcol,infile3, x, y, erry, f='f,f,f'
oploterr, x, y, erry, 7

readcol,infile4, x, y, erry, f='f,f,f'
oploterr, x, y, erry, 8

readcol,infile5, x, y, erry, f='f,f,f'
oploterr, x, y, erry, 1

readcol,infile6, x, y, erry, f='f,f,f'
oploterr, x, y, erry, 2

readcol,infile7, x, y, erry, f='f,f,f'
oploterr, x, y, erry, 4

legend,['HII Region 1','HII Region 2','HII Region 3','HII Region 4','HII Region 5','HII Region 6','HII Region 7'], $
	psym=[5,6,7,8,1,2,4], /right

end
