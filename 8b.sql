/*
Prenesite PB Trgovina.fdb.
Napišite shranjeno proceduro ki bo izpisala ime_izdelka, ceno izdelka in ceno izdelka z DDV. Izpis naj bo urejen glede na stopnjo DDV. Zahtevana oblika izpisa:
Izpis
===================
Stopnja DDV 8%
=============
ime_izdelka1 Cena1 Cena1_z_DDV
ime_izdelka2 Cena2 Cena2_z_DDV
….
Stopnja DDV 20%
=============
ime_izdelkan Cenan Cenan_z_DDV
…
Napišite klic shranjene procedure.
 */

CREATE PROCEDURE IzpisIzdelkovPoDDV
RETURNS (Izpis VARCHAR(1000))
AS
  
BEGIN

END

EXECUTE PROCEDURE IzpisIzdelkovPoDDV RETURNING_VALUES

