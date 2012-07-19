pro read_log,infile
;;PROBLEMS AND WARNINGS WITH THIS CODE
;;1) It still needs the log in a specific format
;;   Log must have a line with the name first
;;   only fluxes in the line immediatly after the one containing "center"
;;   will be read. this can be fixed. fix it!! 
;;2) Can probably replace for loop with indgen
;;   see lines 30-31 for inspiration
outfile = infile
  if strpos(infile,'.log') gt 0 then begin  ;if the infile has the log extension
  L = strpos(outfile,'.log')                ;get length of file name
  outfile = strmid(outfile,0,L)             ;get file name w/o .log extension
  endif
outfile = outfile+'.dat'                    ;add the .dat extension

openw,u, outfile,/get_lun

  print, FORMAT='("Center",5X,"Flux",2X,"ID")'
  print, '============================'  

  printf, u, FORMAT='("Center",5X,"Flux",2X,"ID")'
  printf, u, '============================'  

; readcol reads the data file and writes the columns to 5 vectors
  readcol,infile, F='A,A,A,A,A',col1,col2,col3,col4,col5, /silent

   name = col4[where(strlen(col1) EQ 3,count1)] ;SN NAME in ugly format
     L = strpos(name,'.fits')               ;length of pretty name
     name = strmid(name,0,L)                ;get the pretty name
     i = indgen(count1)                     ;create an integer vector
     name = name[i,i]                       ;diagonal vector of matrix
     strput, name, ';', 0                   ;put a comment before the name
   wave = col1[where(col1 EQ 'center')+1]   ;WAVE values
   flux = col3[where(col1 EQ 'center')+1]   ;FLUX values

   indices1 = where(strlen(col1) EQ 3,count1) ;INDICES that have the name
   indices2 = where(col1 EQ 'center',count2)  ;INDICES that have 'center'
   range = max([max(indices1),max(indices2)]) ;find the last index

   matrix = strarr(range,3)               ;create an empty matrix to hold the values
   matrix[indices1,0] = name              ;assign NAME to column 1 at rows of indices1
   matrix[indices2,0] = wave              ;assign WAVE to column 1 at rows of indices2
   matrix[indices2,1] = flux              ;assign FLUX to column 2 at rows of indices2
   matrix[indices2[0],2] = '1'            ;assign '1' to the first id
   matrix = transpose(matrix)             ;flip columns and rows
;  print,matrix                           ;this matrix has too many empty rows

   indices3 = where(matrix[0,*] EQ '',count4,complement=non) ; Find the empty and non-empty rows
   indices4 = non

   matrix = matrix[*,indices4]            ;remove empty rows
;  print,matrix                           ;this matrix doesn't have id numbers

   indices5 = where(strpos(matrix[0,*],';') ge 0,count5) ;INDICES that have a comment
   indices6 = where(strpos(matrix[0,*],';') lt 0,count6) ;INDICES that have no comment
   range2 = n_elements(indices6)-1

;loop through the final matrix and add id numbers to the rows that have no comment
for n=1,range2, 1 do begin    
  if indices6[n]-indices6[n-1] eq 1 then begin
  matrix[2,indices6[n]] = strtrim(matrix[2,indices6[n-1]],1)
  endif else begin
  matrix[2,indices6[n]] = strtrim(matrix[2,indices6[n-1]]+1,1)
  endelse
endfor

   print,matrix
   printf, u, matrix

free_lun,u
;stop
end
