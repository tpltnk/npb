/*
 1.	naloga
a)	Napišite sprožilec, ki bo zagotavljal, da v posamezni kategoriji imamo največ 4 izdelke. 
V primeru kršitve tega pravila, naj se sproži izjema prevec_izdelkov s sporočilom 'V tej kategoriji je kvota izdelkov zapolnjena.'
b)	Trigger testirajte 2x:
	V tabelo Izdelek vpišite izdelek 8,'Makaroni',1.80,100,3. Ali se je sprožila izjema prevec_izdelkov?
	V tabelo Izdelek vpišite izdelek 9,'Jušni reznaci',2.30,100,3. Ali se je sprožila izjema prevec_izdelkov?
*/

CREATE EXCEPTION prevec_izdelkov 'V tej kategoriji je kvota izdelkov zapolnjena';

SET TERM !! ;

CREATE TRIGGER Najvec4Izdelke FOR Izdelek
ACTIVE BEFORE INSERT
POSITION 8
AS
  DECLARE katID INT;
BEGIN
  katID = SELECT KategorijaID FROM Izdelek WHERE IzdelekID = NEW.IzdelekID;
  IF ((SELECT COUNT(*)
       FROM Kategorija k
       INNER JOIN Izdelek i ON i.KategorijaID = k.ID
       WHERE k.ID = :katID) = 4) THEN
  BEGIN
    EXCEPTION prevec_izdelkov;
  END
END !!

SET TERM ; !!

INSERT INTO Izdelek VALUES (8,'Makaroni',1.80,100,3);
INSERT INTO Izdelek VALUES (9,'Jušni reznaci',2.30,100,3);  

/*
2.	naloga

a)	Denimo, da so cene vseh izdelkov, ki sodijo v kategorijo z DDV 8% zamrznjene. 
To pomeni, da se ti izdelki ne smejo podražiti, lahko pa se pocenijo. 
Napišite sprožilec, ki bo realiziral to poslovno pravilo. 
V primeru kršitve pravila, naj se sproži izjema zamrznjena_cena z besedilom 'Cena izdelka je zamrznjena.'
b)	Sprožilec testirajte 3x:
	Izdelku Union Grand povečajte ceno za 0.5. Ali se je sprožila izjema zamrznjena_cena?
	Izdelku Malinov sirup povečajte ceno za 0.8. Ali se je sprožila izjema zamrznjena_cena?
	Izdelku Domači rezanci zmanjšajte ceno za 0.20. Ali se je sprožila izjema zamrznjena_cena?
 */

CREATE EXCEPTION zamrznjena_cena 'Cena izdelka je zamrznjena.';

SET TERM !! ;

CREATE TRIGGER ZamrznjeneCene FOR Izdelek
ACTIVE BEFORE UPDATE
POSITION 9
AS
BEGIN
  IF ((SELECT ddv FROM Kategorija k WHERE k.KategorijaID = NEW.KategorijaID) = 8) THEN
  BEGIN
    IF (NEW.Cena > OLD.Cena) THEN
    BEGIN
      EXCEPTION zamrznjena_cena;
    END
  END
END !!

SET TERM ; !!

-- Test (lazy but TODO)

/*
3.	naloga
a)	Naredite tabelo LogIzdelkov(Uporabnik:A10,Datum:D,Cas:T, IID:N).
Napišite sprožilec, ki bo ob dodajanju novih izdelkov v tabelo Izdelek, samodejno v tabeli LogIzdelkov beležil kdo je dodal izdelek, kdaj (datum in čas) in IID izdelka, 
ki je bil dodan. 
// Uporabniško ime dobite iz sistemske spremenljivke current_user, 
datum dobite iz sistemske spremenljivke current_date in čas dobite iz sistemske spremenljivke current_time. 
b)	Sprožilec testirajte 2x in potem izpišite vsebino tabele LogIzdelkov. 
V tabelo izdelek dodajte zapisa:
	V tabelo Izdelek vpišite izdelek 9,'Cocta',1.80,300,1.
	V tabelo Izdelek vpišite izdelek 10,'Srebrna Radgonska Penina',8.40,300,2.
c)	Naredite novega uporabnika. Uporabniško ime=Piki, geslo=Piki, ime in priimek sta poljubna. Uporabniku Piki dovolite vnos podatkov v tabelo Izdelek.
d)	Povežite se s PB Trgovina kot uporabnik Piki in dodajte zapis: 11,'Traminec',7.80,300,2.
e)	Povežite se s PB Trgovina kot uporabnik SYSDBA in izpišite vsebino tabel Izdelek in LogIzdelkov.
*/

CREATE TABLE LogIzdelkov (
  Uporabnik VARCHAR(10) NOT NULL,
  Datum DATE NOT NULL,
  Cas TIME NOT NULL,
  IID INT NOT NULL
);

SET TERM !! ;

CREATE TRIGGER NovIzdelek FOR Izdelek
ACTIVE AFTER INSERT
POSITION 10
AS
BEGIN
  INSERT INTO LogIzdelkov VALUES (CURRENT_USER, CURRENT_DATE, CURRENT_TIME, OLD.IzdelekID);
END !!

SET TERM ; !!

INSERT INTO Izdelek VALUES (9,'Cocta',1.80,300,1);
INSERT INTO Izdelek VALUES (10,'Srebrna Radgonska Penina',8.40,300,2);

CREATE USER Piki PASSWORD 'Piki';
GRANT INSERT ON Trgovina.NovIzdelek TO Piki;
GRANT INSERT ON Trgovina.LogIzdelkov TO Piki;

-- isql -u Piki -p Piki
CONNECT 'Trgovina.fdb';
INSERT INTO Izdelek VALUES (11,'Traminec',7.80,300,2);

-- isql -u sysdba -p masterkey
SELECT * FROM Izdelek;
SELECT * FROM LogIzdelkov;

/*
4.	naloga
a)	Napišite sprožilec, ki prepreči brisanje izdelkov dobaviteljev iz Ljubljane. 
Ob poskusu nedovoljenega brisanja naj se sproži izjema prepovedano_brisanje z besedilom 'Brisanje izdelkov dobaviteljev iz Ljubljane ni dovoljeno.' 
b)	Sprožilec testirajte 2x:
	Izbrišite izdelek 'Srebrna Radgonska Penina'. Ali se je sprožila izjema prepovedano_brisanje?
	Izbrišite izdelek 'Domači rezanci'. Ali se je sprožila izjema prepovedano_brisanje?
c)	Izpišite seznam vseh sprožilcev v PB.
*/

CREATE EXCEPTION prepovedano_brisanje 'Brisanje izdelkov dobaviteljev iz Ljubljane ni dovoljeno.';

SET TERM !! ;

CREATE TRIGGER NeIzLj FOR Izdelek
ACTIVE BEFORE DELETE
POSITION 11
AS
  DECLARE dobID INT;
BEGIN
  dobID = SELECT DobaviteljID FROM Izdelek WHERE IzdelekID = OLD.IzdelekID;
  IF ((SELECT FIRST 1 lokacija FROM Dobavitelj WHERE DobaviteljID = :dobID) LIKE '%Ljubljana%') THEN
  BEGIN
    EXCEPTION prepovedano_brisanje;
  END
END !!

SET TERM ; !!

DELETE FROM Izdelek WHERE naslov = 'Srebrna Radgonska Penina'; -- ne
DELETE FROM Izdelek WHERE naslov = 'Domači rezanci';           -- ja (untested)


