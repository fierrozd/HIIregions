pro read_dat,infile

;;PROBLEMS AND WARNINGS WITH THIS CODE
;;1) If you have the ID numbers that are the same but do not "touch"
;;   there will be an error
;;2) If you have multiple measurements of the same emission line 
;;   (same wavelength range and same id#) then this code only
;;   takes the last flux value

; ## output in 12 columns (ID number, fluxes) corresponding to:
; ## ID number, [OII]3727, Hb, [OIII]4959, [OIII]5007, [OI]6300, Ha, [NII]6584, 
; ## [SII]6717, [SII] 6731,[SIII]9069, [SIII]9532


outfile = infile
  if strpos(infile,'.dat') gt 0 then begin  ;if the infile has the dat extension
  L = strpos(outfile,'.dat')                ;get length of file name
  outfile = strmid(outfile,0,L)             ;get file name w/o .dat extension
  endif
outfile = outfile+'.data'                   ;add the .data extension

openw,u, outfile,/get_lun

  print, 'ID  OII H-b 03a 03b OI  H-a NII S2a S2b S3a S3b'
  print, '============================'  

; readcol reads the dat file and writes the columns to 3 vectors
  readcol,infile, F='A,A,I',wave,flux,id,/silent
   flux = [flux,'0.0']                   ;this appends 0.0 at the end so this way when -1 it works

   nids = n_elements(uniq(id))           ;counts the number of repeating id numbers
   matrix = strarr(12,nids)               ;create an empty matrix to hold the values of 5 col
   matrix[0,*] = strtrim(id[uniq(id)],1) ;assign ID numbr to column 0 of matrix at row

for i=0, n_elements(uniq(id))-1 do begin ;loop through each id number, col 0 of matrix

   indicesHa  = where(wave gt 6590 and wave lt 6600 and id eq matrix[0,i]) ;check for H-a line with id i   <----OFF!
   indicesNII = where(wave gt 6615 and wave lt 6625 and id eq matrix[0,i]) ;check for NII line with id i   <----OFF!
   indicesHb  = where(wave gt 4857 and wave lt 4867 and id eq matrix[0,i]) ;check for H-b line with id i
   indicesOIIIb=where(wave gt 5002 and wave lt 5012 and id eq matrix[0,i]) ;check for OIIIline with id i
   indicesOII = where(wave gt 3722 and wave lt 3732 and id eq matrix[0,i]) ;check for OII line with id i

   indicesOIIIa=where(wave gt 4959 and wave lt 4959 and id eq matrix[0,i]) ;check for OIIIline with id i
   indicesOI  = where(wave gt 6300 and wave lt 6300 and id eq matrix[0,i]) ;check for OI  line with id i
   indicesSIIa= where(wave gt 6717 and wave lt 6717 and id eq matrix[0,i]) ;check for S2a line with id i
   indicesSIIb= where(wave gt 6731 and wave lt 6731 and id eq matrix[0,i]) ;check for S2b line with id i
   indicesSIIIa=where(wave gt 9069 and wave lt 9069 and id eq matrix[0,i]) ;check for S2a line with id i
   indicesSIIIb=where(wave gt 9532 and wave lt 9532 and id eq matrix[0,i]) ;check for S2b line with id i

   matrix[1,i] = flux[indicesOII[-1]]   ;assign OII flux to column 1 of matrix at row with matching id
   matrix[2,i] = flux[indicesHb[-1]]    ;assign H-b flux to column 2 of matrix at row with matching id
   matrix[3,i] = flux[indicesOIIIa[-1]] ;assign O3a flux to column 3 of matrix at row with matching id
   matrix[4,i] = flux[indicesOIIIb[-1]] ;assign O3b flux to column 4 of matrix at row with matching id
   matrix[5,i] = flux[indicesOI[-1]]    ;assign OI  flux to column 5 of matrix at row with matching id
   matrix[6,i] = flux[indicesHa[-1]]    ;assign H-a flux to column 6 of matrix at row with matching id
   matrix[7,i] = flux[indicesNII[-1]]   ;assign NII flux to column 7 of matrix at row with matching id
   matrix[8,i] = flux[indicesSIIa[-1]]  ;assign S2a flux to column 8 of matrix at row with matching id
   matrix[9,i] = flux[indicesSIIb[-1]]  ;assign S2b flux to column 9 of matrix at row with matching id
   matrix[10,i]= flux[indicesSIIIa[-1]] ;assign S3a flux to column 10of matrix at row with matching id
   matrix[11,i]= flux[indicesSIIIb[-1]] ;assign S3b flux to column 11of matrix at row with matching id

endfor


   print,matrix
   printf, u, matrix

free_lun,u
;stop
end
