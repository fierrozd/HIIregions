pro read_dat,infile

;;PROBLEMS AND WARNINGS WITH THIS CODE
;;1) If you have the ID numbers that are the same but do not "touch"
;;   there will be an error
;;2) If you have multiple measurements of the same emission line 
;;   (same wavelength range and same id#) then this code only
;;   takes the last flux value

outfile = infile
  if strpos(infile,'.dat') gt 0 then begin  ;if the infile has the dat extension
  L = strpos(outfile,'.dat')                ;get length of file name
  outfile = strmid(outfile,0,L)             ;get file name w/o .dat extension
  endif
outfile = outfile+'.data'                   ;add the .data extension

openw,u, outfile,/get_lun

  print, FORMAT='("ID",3X,"H-a",4X,"NII",4X,"H-b",X,"OIII")'
  print, '============================'  

; readcol reads the dat file and writes the columns to 3 vectors
  readcol,infile, F='A,A,I',wave,flux,id,/silent
   flux = [flux,'0.0']

   nids = n_elements(uniq(id))           ;counts the number of repeating id numbers
   matrix = strarr(5,nids)               ;create an empty matrix to hold the values of 5 col
   matrix[0,*] = strtrim(id[uniq(id)],1) ;assign ID numbr to column 0 of matrix at row

for i=0, n_elements(uniq(id))-1, 1 do begin ;loop through each id number, col 0 of matrix

   indicesHa  = where(wave gt 6590 and wave lt 6600 and id eq matrix[0,i]) ;check for H-a line with id i
   indicesNII = where(wave gt 6612 and wave lt 6622 and id eq matrix[0,i]) ;check for NII line with id i
   indicesHb  = where(wave gt 4857 and wave lt 4867 and id eq matrix[0,i]) ;check for H-b line with id i
   indicesOIII= where(wave gt 5002 and wave lt 5012 and id eq matrix[0,i]) ;check for OIIIline with id i

   matrix[1,i] = flux[indicesHa[-1]]     ;assign H-a flux to column 1 of matrix at row with matching id
   matrix[2,i] = flux[indicesNII[-1]]    ;assign NII flux to column 2 of matrix at row with matching id
   matrix[3,i] = flux[indicesHb[-1]]     ;assign NII flux to column 2 of matrix at row with matching id
   matrix[4,i] = flux[indicesOIII[-1]]   ;assign NII flux to column 2 of matrix at row with matching id

endfor


   print,matrix
   printf, u, matrix

free_lun,u
;stop
end
