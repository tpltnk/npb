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

CREATE PROCEDURE IzpisIzdelkov (DDV INT)
RETURNS (Izpis VARCHAR(1000))
AS
  DECLARE VARIABLE ime_izdelka VARCHAR(30);
  DECLARE VARIABLE cena FLOAT;
BEGIN
  Izpis = '';
  FOR SELECT ime_izdelka, cena FROM Izdelek WHERE DDV = :DDV INTO :ime_izdelka, :cena DO
  BEGIN
    Izpis = Izpis || ime_izdelka || ' ' || cena || ' ' || cena * DDV || '\n';
    SUSPEND;
  END
END

CREATE PROCEDURE IzpisIzdelkovPoDDV
RETURNS (Izpis VARCHAR(10000))
AS
  DECLARE VARIABLE DDV INT;
  DECLARE VARIABLE PosamezniIzpis VARCHAR(1000);
BEGIN
  Izpis = 'Izpis';
  Izpis = Izpis || '\n==================\n';
  FOR SELECT ddv FROM Izdelek GROUP BY DDV INTO :DDV DO
  BEGIN
    Izpis = Izpis || 'Stopnja DDV ' || DDV || '%';
    Izpis = Izpis || '\n================\n';
    FOR SELECT Izpis FROM IzpisIzdelkov(DDV) INTO :PosamezniIzpis DO
    BEGIN
      Izpis = Izpis || PosamezniIzpis || '\n';
    END
  END
END

EXECUTE PROCEDURE IzpisIzdelkovPoDDV; 
