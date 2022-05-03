/*
2.	naloga
Napišite shranjeno proceduro ki bo izpisala podatke o izdelkih po padajoči vrednosti cene izdelka. Vrstice izpisa morajo biti oštevilčene! Primer izpisa:
PODATKI
==================================
1. Jajčni liker        7.00
2. Malinov sirup       4.10
3. Domači rezanci      3.20
4. Špageti             2.80
5. Jajčni rezanci      2.80
6. Union Grand         2.10
7. Uni                 1.80 
Napišite klic shranjene procedure.
*/

CREATE PROCEDURE PadajocIzpis
RETURNS (Podatki CHAR(50))
AS
  DECLARE ime_izdelka CHAR(20);
  DECLARE cena FLOAT;
  DECLARE counter INT DEFAULT 0;
BEGIN
  FOR SELECT ime_izdelka, cena 
      FROM Izdelek 
      ORDER BY cena DESC 
      INTO :ime_izdelka, :cena 
      DO
  BEGIN
    Podatki = CAST(counter AS CHAR(1)) || '.' || ime_izdelka || CAST(cena AS CHAR(9));
    SUSPEND;
  END
END

/*
Napišite shranjeno proceduro, ki izpiše ime_izdelka in za koliko bi se nominalno povečala cena izdelka, če se stopnja DDV spremeni za n%. 
N in ime izdelka sta vhodna parametra procedure. Primer:
Jajčni liker ima ceno 7.00 in trenutna stopnja DDV je 0.20 (20%). 
To pomeni, da je za jajčni liker cena z DDV 8.40. Če je vhodni parameter n 0.02, bi nova cena z DDV za jajčni liker bila 8.54. 
Nominalna sprememba cene je v tem primeru 0.14. Zahtevana oblika izpisa:
Ime   Sprememba
=========================
Jajčni liker 0.14

Napišite klic shranjene procedure.
Spremenite proceduro tako, da sprejme le spremembe DDV za največ ±10%. 
V primeru prevelike spremembe stopnje DDV, naj procedura v podatku Ime izpiše 'To bo revolucija', v podatku Sprememba pa NULL.
Z ustreznimi klici procedure testirajte preverjanje dovoljene meje za spremembo DDV.
*/

SET TERM !! ;

CREATE FUNCTION CenaZDDV (cena FLOAT, ddv FLOAT)
RETURNS FLOAT
AS
BEGIN
  RETURN cena + cena * dvv;
END !!

CREATE PROCEDURE SpremembaCene (ime_izdelka CHAR(20), n FLOAT)
RETURNS (ime CHAR(20), sprememba FLOAT)
AS
  DECLARE cena FLOAT;
  DECLARE cena_z_ddv FLOAT;
BEGIN
  IF ((SELECT COUNT(*) FROM Izdelek WHERE ime_izdelka = :ime_izdelka) <> 0) THEN
  BEGIN
    ime = :ime_izdelka;
    cena = SELECT FIRST 1 cena FROM Izdelek WHERE ime_izdelka = :ime_izdelka;
    cena_z_ddv = SELECT CenaZDDV(:cena, 0.2) FROM RDB$DATABASE;
    sprememba = CAST(
      (SELECT CenaZDDV(:cena_z_ddv, :n) FROM RDB$DATABASE - :cena_z_ddv)
      AS CHAR(5)
    );
  END
END !!


/*
4.	naloga

Napišite shranjeno, ki izpiše razliko v ceni dveh izdelkov z upoštevanjem vrednosti DDV. Procedura vrne:
	Prvi izdelek je drazji za nn.nn.
	Drugi izdelek je drazji za nn.nn.
	Ceni sta enaki.
Primer izvedbe shranjene procedure, če sta vhodna parametra 3 in 1.
PODATKI
==================================
Drugi izdelek je drazji za 0.43
Napišite klic shranjene procedure.
*/

CREATE PROCEDURE RazlikaVCeni (I1 INT, I2 INT)
RETURNS (Podatki CHAR(50))
AS
  DECLARE C1 FLOAT;
  DECLARE C2 FLOAT;
BEGIN
  IF ((SELECT COUNT(*) FROM Izdelek WHERE IzdelekID = I1) <> 0 AND
      (SELECT COUNT(*) FROM Izdelek WHERE IzdelekID = I2) <> 0) THEN
  BEGIN
    C1 = SELECT FIRST 1 cena FROM Izdelek WHERE IzdelekID = I1;
    C2 = SELECT FIRST 1 cena FROM Izdelek WHERE IzdelekID = I2;
    C1 = CenaZDDV(C1, 0.2);
    C2 = CenaZDDV(C2, 0.2);
    IF (C1 > C2) THEN
    BEGIN
      Podatki = 'Prvi izdelek je drazji za ' || CAST((C1 - C2) AS CHAR(5)) || '.';
    END
    IF (C1 < C2) THEN
    BEGIN
      Podatki = 'Drugi izdelek je drazji za ' || CAST((C2 - C1) AS CHAR(5)) || '.';
    END
    IF (C1 = C2) THEN
    BEGIN
      Podatki = 'Ceni sta enaki';
    END
  END
END !! 

SET TERM ; !!
