pro read_log,infile,fits=fits
;;PROBLEMS AND WARNINGS WITH THIS CODE
;;1) Not sure if CD1_1 is dispersion delta
;;2) Units column is set to '1', see line 60
;;3) Can probably replace for loop with indgen
;;   see lines 30-31 for inspiration
if n_params() lt 1 then begin
    print,' Syntax - read_log,infile,fits=fits'
    print,' Syntax - read_log,"sn2006ss.log",/fits'
endif

  outfile = infile
  if strpos(infile,'.log') gt 0 then begin  ;if the infile has the log extension
  L = strpos(outfile,'.log')                ;get length of file name
  outfile = strmid(outfile,0,L)             ;get file name w/o .log extension
  endif
  outfile = outfile+'.dat'                  ;add the .dat extension
  openw,u, outfile,/get_lun

  heading1='Wavelength  Flux     EW     N1       N2      RMS      ID'
  bar     ='========================================================'
  heading2='Wavelength  Flux     EW     N1       N2      RMS       Delta      Redshift ID  U  Side'
  fmt1='(A,T11,A,T22,A,T29,A,T38,A,T46,A,T56,A)'
  fmt2='(A,T11,A,T22,A,T29,A,T38,A,T46,A,T56,A,2X,A,2X,A,2X,A,2X,A)'

  readcol,infile, F='A,A,A,A,A',col1,col2,col3,col4,col5, /silent ;read in 5 string arrays

   indices1 = where(strlen(col1) eq 3,count1) ;INDICES that have the fits name
   indices2 = where(strlen(col1) ge 7)        ;INDICES that start with wavelength
   indices3 = where(strpos(col1,'avg') eq 0)  ;INDICES that start with avg
   range = max([indices1,indices2])           ;find the last index

   name = col4[where(strlen(col1) EQ 3,count1)] ;SN NAME in ugly format
   wave = col1[indices2]                      ;WAVE values
   flux = col3[indices2]                      ;FLUX values
   eqw  = col4[indices2]                      ;EQW  values
   core = col5[indices2]                      ;CORE values
   rms  = col4[indices3]                      ;RMS  values

   L = strpos(name,'.fits')               ;length of pretty name
   i = indgen(count1)                     ;create an integer vector of # of names
   strput, name, ';', 0                   ;put a comment before the name
   name = strmid(name,0,L)                ;get the pretty name but gives matrix
   name = name[i,i]                       ;diagonal vector of matrix is good
   eqw  = strmid(eqw,1)
   N1=float(wave)-(float(flux)/float(core))
   N2=float(wave)+(float(flux)/float(core))

   matrix = strarr(range,11)              ;create an empty matrix to hold the values
   matrix[indices1, 0] = name             ;assign NAME to column 0 at rows of indices1
   matrix[indices2, 0] = wave             ;assign WAVE to column 0 at rows of indices2
   matrix[indices2, 1] = flux             ;assign FLUX to column 1 at rows of indices2
   matrix[indices2, 2] = eqw              ;assign EQW  to column 2 at rows of indices2
   matrix[indices2, 3] = strtrim(N1,1)
   matrix[indices2, 4] = strtrim(N2,1)
   matrix[indices3-1,5]= rms              ;assign RMS  to column 5 at rows of indices2
   matrix[indices2[0],6]  = ''            ;assign delt to column 6 at rows of indices2
   matrix[indices2[0],7]  = ''            ;assign dop  to column 7 at rows of indices2
   matrix[indices2[0],8]  = '1'           ;assign 1stidto column 8 at row 0of indices2
   matrix[indices2[0],9]  = '1'           ;assign unit to column 9 at rows of indices2
   matrix[indices2[0],10] = ''            ;assign side to column 10at rows of indices2
   matrix = transpose(matrix)             ;flip columns and rows
;  print,matrix                           ;this matrix has too many empty rows

   indices4 = where(matrix[0,*] EQ '',count4,complement=non) ; Find the empty and non-empty rows
   matrix = matrix[*,non]                 ;remove empty rows
;  print,matrix                           ;this matrix doesn't have id numbers

   indices5 = where(strpos(matrix[0,*],';') ge 0,count5) ;INDICES that have a comment
   indices6 = where(strpos(matrix[0,*],';') lt 0,count6) ;INDICES that have no comment
   range1 = n_elements(indices5)
   range2 = n_elements(indices6)-1
   range3 = range1 + range2

   for n=1,range2 do begin                ;loop short matrix and add id numbers
    if indices6[n]-indices6[n-1] eq 1 then begin
    matrix[8,indices6[n]] = strtrim(matrix[8,indices6[n-1]],1)
    endif else begin
    matrix[8,indices6[n]] = strtrim(matrix[8,indices6[n-1]]+1,1)
    endelse
   endfor



IF keyword_set(fits) then begin ;ACTIVATE WITH KEYWORD

 for n=0,range2 do begin                  ;loop final matrix, read fits and add columns
  if indices6[n]-indices6[n-1] eq 1 then begin
  matrix[6, indices6[n]] = strtrim(matrix[6, indices6[n-1]],1)
  matrix[7, indices6[n]] = strtrim(matrix[7, indices6[n-1]],1)
  matrix[9, indices6[n]] = strtrim(matrix[9, indices6[n-1]],1)
  matrix[10,indices6[n]] = strtrim(matrix[10,indices6[n-1]],1)
  endif else begin
  fitsfile = strmid(matrix[0,indices6[n]-1],1)+'.fits'
  img = READFITS(fitsfile, h, /SILENT)          ;read the fits file header
  z=strmid(sxpar(h,'DOPCOR01'),0,8)             ;read dopcor01 from header
  delt=strtrim(sxpar(h,'CD1_1'),1)              ;read CD1_1    from header
  instrument=sxpar(h,'INSTRUME')                ;read intsrume from header
   case instrument of 
   'LRISBLUE': side = 'B'
   'LRIS':     side = 'R'  
    else:      side = '?' 
   endcase 
  matrix[6, indices6[n]] = delt
  matrix[7, indices6[n]] = z
  matrix[9, indices6[n]] = matrix[9,indices6[0]]
  matrix[10,indices6[n]] = side
  endelse
 endfor

 ;PRINT EVERYTHING TO TERMINAL AND OUTFILE
 print, heading2
 print, bar  
 printf, u, heading2
 printf, u, bar
  for j=0, range3 do begin
  print,   matrix[0,j],matrix[1,j],matrix[2,j],matrix[3,j],matrix[4,j],matrix[5,j],$
           matrix[6,j],matrix[7,j],matrix[8,j],matrix[9,j],matrix[10,j], F=fmt2
  printf,u,matrix[0,j],matrix[1,j],matrix[2,j],matrix[3,j],matrix[4,j],matrix[5,j],$
           matrix[6,j],matrix[7,j],matrix[8,j],matrix[9,j],matrix[10,j], F=fmt2
  endfor

ENDIF else begin                ;KEYWORD NOT ACTIVATED

 ;PRINT EVERYTHING TO TERMINAL AND OUTFILE
 print, heading1
 print, bar  
 printf, u, heading1
 printf, u, bar
  for j=0, range3 do begin
  print,   matrix[0,j],matrix[1,j],matrix[2,j],matrix[3,j],matrix[4,j],matrix[5,j], matrix[8,j],F=fmt1
  printf,u,matrix[0,j],matrix[1,j],matrix[2,j],matrix[3,j],matrix[4,j],matrix[5,j], matrix[8,j],F=fmt1
  endfor

ENDELSE

print,'--> Wrote to: ',outfile
free_lun,u
end
