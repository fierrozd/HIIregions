FUNCTION is_nonneg_int,data
	temp = WHERE((byte(data) GT 57),count)
	IF count NE 0 THEN BEGIN
		return,0
	ENDIF ELSE BEGIN
		temp = WHERE((byte(data) LT 48),count)
		IF count NE 0 THEN return,0 ELSE return,1
	ENDELSE
END