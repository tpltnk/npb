/*
Za 2., 3. In 4. nalogo prenesite PB Trgovina.fdb.
2.	naloga

a)	Napišite shranjeno proceduro VnosIzdelka, ki omogoča vnos izdelkov. 
Parametri procedure so podatki o izdelku. 
Z uporabniško definiranimi izjemami obravnavajte naslednje napake: podvajanje primarnega ključa, manjkajoč ključ v tabeli Kategorija in manjkajoč ključ v tabeli Dobavitelj.
Vsaka izjema naj sporoči ustrezno napako ('Izdelek že obstaja', 'Ne obstaja ustrezna kategorija' oz. 'Ne obstaja ustrezni dobavitelj'). 
V primeri katerekoli druge napake vrnite obvestilo ' Napaka pri dodajanju'. 
b)	Proceduro testirajte 4x (enkrat z veljavnimi podatki, 
enkrat poskusite podvajanje ključa, enkrat vpišite neveljavno kategorijo in enkrat vpišite neveljavnega dobavitelja).

3.	naloga
a)	Napišite shranjeno proceduro za brisanje naključnega izdelka. 
Za generiranje ID izdelka, ki ga boste brisali, uporabite funkcijo srand(). 
Funkcija srand() vrne naključno realno število iz intervala [0..1]. 
Če izbranega izdelka ni, vrnite obvestilo 'Izdelka s šifro ID ni'. 
Če je brisanje uspešno, vrnite obvestilo 'Izbrisan je izdelek s šifro ID'. 
V primeru katerekoli druge napake vrnite obvestilo 'Brisanje izdelka ni uspelo'. 
b)	Proceduro testirajte večkrat, tako da vsaj enkrat dobite obvestilo, da je izdelek izbrisan.

4.	naloga
a)	Naredite tabelo TopDobavitelji(Zaporedna_stevilka, Datum, DID:Nà, ImeDobavitelja:A20, Naslov:A20, Telefon:A15, PST:N). 
Napišite shranjeno proceduro, ki iz tabele Dobavitelji prepiše podatke o dobaviteljih, ki dobavljajo največ izdelkov. 
V podatek Zaporedna_stevilka vpišete zaporedno številko zapisa, ki ga dodajate, v podatek Datum prenesete sistemski datum.
b)	Napišite klic procedure in izpišite vsebino tabele TopDobavitelji.
Le ideja: premislite, kako bi vsebino tabele TopDobavitelji prepisali v tekstovno datoteko TopDobavitelji.txt. O: JE NEBI.
*/

CREATE EXCEPTION IzdelekObstaja 'Izdelek ze obstaja';
CREATE EXCEPTION KategorijaNeObstaja 'Ne obstaja ustrezna kategorija';
CREATE EXCEPTION DobaviteljNeObstaja 'Ne obstaja ustrezni dobavitelj';
CREATE EXCEPTION DrugaNapaka 'Napaka pri dodanju';

SET TERM !! ;

CREATE PROCEDURE VnosIzdelka (IzdelekID INT, ime_izdelka CHAR(20), cena FLOAT, ddv FLOAT, KategorijaID INT, DobaviteljID INT)
AS
BEGIN
  INSERT INTO Izdelek VALUES (:IzdelekID, :ime_izdelka, :cena, :ddv, :KategorijaID, :DobaviteljID);
  WHEN SQLCODE -803 DO
  BEGIN
    EXCEPTION IzdelekObstaja;
  END
  WHEN SQLCODE -503 DO
  BEGIN
    -- TODO: requires research
    EXCEPTION KategorijaNeObstaja;
    EXCEPTION DobaviteljNeObstaja;
  END
  WHEN ANY DO
  BEGIN
    EXCEPTION DrugaNapaka;
  END
END !!

SET TERM ; !!

EXECUTE PROCEDURE VnosIzdelka (0, 'Copati1', 5.99, 22.0, 1, 1);
EXECUTE PROCEDURE VnosIzdelka (0, 'Copati1', 5.99, 22.0, 1, 1);
EXECUTE PROCEDURE VnosIzdelka (1, 'Copati2', 4.20, 69.0, -30, 1);
EXECUTE PROCEDURE VnosIzdelka (1, 'Copati3', 3.33, 33.3, 1, -40);

SET TERM !! ;

CREATE PROCEDURE BrisanjeNakljucnegaIzdelka
RETURNS (Obvestilo CHAR(40))
AS
  DECLARE VARIABLE ID INT;
BEGIN
  ID = CAST(SRAND() * (SELECT COUNT(*) FROM Izdelek) AS INT);
  IF ((SELECT COUNT(*) FROM Izdelek WHERE IzdelekID = :ID) = 0) THEN
  BEGIN
    Obvestilo = 'Izdelka s šifro ' || CAST(ID AS CHAR(10)) || ' ni.'
    EXIT;
  END
  DELETE FROM Izdelek WHERE IzdelekID = :ID;
  WHEN ANY DO
  BEGIN
    Obvestilo = 'Brisanje izdelka ni uspelo';
    EXIT;
  END
  Obvestilo = 'Izbrisan izdelek s šifro ' || CAST(ID AS CHAR(10)) || '.';
END !!

EXECUTE BLOCK
  AS
    DECLARE VARIABLE Status DEFAULT '';
  BEGIN
    WHILE (Status LIKE 'Izbrisan%') DO
    BEGIN
      EXECUTE PROCEDURE BrisanjeNakljucnegaIzdelka RETURNING_VALUES :Status;
    END
  END !!

SET TERM ; !!

-- TopDobavitelji(Zaporedna_stevilka, Datum, DID:Nà, ImeDobavitelja:A20, Naslov:A20, Telefon:A15, PST:N)
CREATE TABLE TopDobavitelji (
  Zaporedna_stevilka INT NOT NULL,
  Datum DATE NOT NULL,
  DID INT NOT NULL,
  ImeDobavitelja VARCHAR(20) NOT NULL,
  Naslov VARCHAR(20) NOT NULL,
  Telefon VARCHAR(15) NOT NULL,
  PST INT NOT NULL,
  PRIMARY KEY (Zaporedna_stevilka),
  FOREIGN KEY (DID) REFERENCES Dobavitelji (DID),
);

SET TERM !! ;

CREATE PROCEDURE UpdateTopDobavitelji (n INT)
AS
  DECLARE VARIABLE DID INT;
  DECLARE VARIABLE ImeDobavitelja VARCHAR(20);
  DECLARE VARIABLE Naslov VARCHAR(20);
  DECLARE VARIABLE Telefon VARCHAR(15);
  DECLARE VARIABLE PST INT;
  DECLARE VARIABLE ZapSt INT DEFAULT 1;
BEGIN
  FOR SELECT FIRST :n d.DID, d.ImeDobavitelja, d.Naslov, d.Telefon, d.PST, COUNT(*) AS SteviloIzdelkov
      FROM Dobavitelji d
      INNER JOIN Izdelek i ON i.DobaviteljID = d.DID
      GROUP BY d.DID
      ORDER BY SteviloIzdelkov DESC
      INTO :DID, :ImeDobavitelja, :Naslov, :Telefon, :PST DO
  BEGIN
    --                                             CURRENT_DATE
    --                                         -------------------
    INSERT INTO TopDobavitelji VALUES (:ZapSt, CAST('NOW' AS DATE), :DID, :ImeDobavitelja, :Naslov, :Telefon, :PST);
    ZapSt = ZapSt + 1;
  END
END !!

SET TERM ; !!

EXECUTE PROCEDURE UpdateTopDobavitelji;
SELECT * FROM TopDobavitelji;
