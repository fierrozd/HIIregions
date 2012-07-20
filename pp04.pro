pro pp04,filename
close,1

readcol,filename,F='I',a,count=num,/silent ;count the number of lines in the infile

data=fltarr(12,num)
openr,1,filename      ;###  FLUXES
readf,1,data
close,1

; ## input in 12 columns (ID number, fluxes) corresponding to:
; ## ID number, [OII]3727, Hb, [OIII]4959, [OIII]5007, [OI]6300, Ha, [NII]6584, 
; ## [SII]6717, [SII] 6731,[SIII]9069, [SIII]9532


;Reading the data file
name=intarr(num)
name=floor(data(0,*))
OII3727_raw=data(1,*)
Hb_raw=data(2,*)
OIII4959_raw=data(3,*)
OIII5007_raw=data(4,*)
OI6300_raw=data(5,*)
Ha_raw=data(6,*)
NII6584_raw=data(7,*)
SII6717_raw=data(8,*)
SII6731_raw=data(9,*)
SIII9069_raw=data(10,*)
SIII9532_raw=data(11,*)

; correction constants from Miller & Mathews 1972
fNII=0.650591
fHa=0.655 
fHb=1.0
fOIII=0.961067   ; for OIII5007, but is only 0.01 different from OIII4959 (0.973617)

;prepare to hold floating point
EB_V=fltarr(num)
logNIIHa=fltarr(num) 
logOIIIHb=fltarr(num)


;compute B-V using H-alpha and H-beta for extinction correction
EB_V=2.1575*alog10(Ha_raw/(Hb_raw*2.85))

;compute ratio of NII/Ha
logNIIHa=alog10(NII6584_raw/Ha_raw)     ;without extinction correction!
logNIIHax=alog10(NII6584_raw/Ha_raw)+EB_V/0.77*(fNII-fHa) ;with red_corr!
logOIIIHb=alog10(OIII5007_raw/Hb_raw)
logOIIIHbx=alog10(OIII5007_raw/Hb_raw)+EB_V/0.77*(fOIII-fHb)

;######### BEGIN:  MM 2010 Dec 15 Update (taken from Abundance_err_max_mm.pro): 
;#### Denicolo [NII]/Ha diagnostic Denicolo, Terlevich & Terlevich
;2002,  MNRAS, 330, 69

N2=logNIIHa
N2x=logNIIHax

D02_Z=9.12+0.73*N2

;### Pettini & Pagel diagnostics - Pettini & Pagel 2004, MNRAS, 348, L59

PP04_N2_Z=9.37 + 2.03* N2 + 1.26* N2^2 + 0.32* N2^3
PP04_N2_Zx=9.37 + 2.03* N2x + 1.26* N2x^2 + 0.32* N2x^3
;PP04_N2_Z(where(logNIIHa eq 0.0))=0.0
;from error stuff: O3N2=min_logOIIIHb-max_logNIIHa

O3N2 = alog10 (  10^(logOIIIHb)/10^(logNIIHa))
O3N2x = alog10 (  10^(logOIIIHbx)/10^(logNIIHax))
PP04_O3N2_Z=8.73 - 0.32*O3N2
PP04_O3N2_Zx=8.73 - 0.32*O3N2x
;PP04_O3N2_Z(where(logOIIIHb eq 0.0 or logNIIHa eq 0.0))=0.0

outfile = filename
  if strpos(filename,'.data') gt 0 then begin  ;if the infile has the dat extension
  L = strpos(outfile,'.data')                ;get length of file name
  outfile = strmid(outfile,0,L)             ;get file name w/o .dat extension
  endif
outfile = outfile+'.tbl'                   ;add the .data extension
openw,u, outfile,/get_lun

print,'ID     D02          PP04_N2      PP04_N2x     PP04_O3N2    PP04_O3N2x'
printf,u,'ID     D02          PP04_N2      PP04_N2x     PP04_O3N2    PP04_O3N2x'

for i=0,num-1 do begin
print,strtrim(name(i),1),D02_Z(i),PP04_N2_Z(i),PP04_N2_Zx(i),PP04_O3N2_Z(i),PP04_O3N2_Zx(i)
printf,u,strtrim(name(i),1),D02_Z(i),PP04_N2_Z(i),PP04_N2_Zx(i),PP04_O3N2_Z(i),PP04_O3N2_Zx(i)
end

free_lun,u
end
