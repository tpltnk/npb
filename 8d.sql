/*
1.	naloga
 V PB je tabela Avtor(AvtorID, Ime, Priimek). 
a)	S sprožilci zagotovite, da so vsi priimki avtorjev vpisani z velikimi črkami. 
Namig: potrebno je obravnavati dogodka insert in update. 
V primeru, da uporabnik vnese priimek avtorja le z veliko začetnico, sprožite izjemo, ki vrne sporočilo 'Priimek avtorja vpiši z velikimi črkami'.
Testirajte delovanje sprožilca. Rezultate testiranja zabeležite v poročilo vaje.
Dekativirajte sprožilec (ALTER)
b)	S sprožilci zagotovite, da so vsi priimki avtorjev vpisani z velikimi črkami. 
Namig: potrebno je obravnavati dogodka insert in update. 
V primeru, da uporabnik vnese priimek avtorja le z veliko začetnico, naj sprožilec samodejno ostale črke pretvori v velike.
 Testirajte delovanje sprožilca. Rezultate testiranja zabeležite v poročilo vaje.
*/

CREATE EXCEPTION SamoZVelikoZacetnico 'Priimek avtorja vpiši z velikimi črkami';

CREATE FUNCTION JeVelikaZacetnica (Zacetnica CHAR(1))
RETURNS BOOLEAN
AS
BEGIN
  RETURN (Zacetnica > 'A' AND Zacetnica < 'Z') OR Zacetnica = 'Š' OR Zacetnica = 'Č' OR Zacetnica = 'Ž';
END

CREATE TRIGGER PriimkiZVelikimiCrkami FOR Avtor
ACTIVE BEFORE INSERT OR UPDATE
POSITION 7
AS
  DECLARE VARIABLE Zacetnica CHAR(1);
BEGIN
  Zacetnica = SUBSTRING(NEW.Priimek FROM 1 FOR 1);
  -- non-ascii incompatible
  IF (EXECUTE FUNCTION JeVelikaZacetnica (Zacetnica)) THEN
  BEGIN
    EXCEPTION SamoZVelikoZacetnico;
  END
  NEW.Priimek = UPPER(NEW.Priimek);
END

INSERT INTO Avtor (AvtorID, Ime, Priimek) VALUES (1, 'Jožefff', 'kvadrat');
UPDATE Avtor SET Ime = 'Peppa' Priimek = 'Pig' WHERE AvtorID = 1;

ALTER TRIGGER PriimkiZVelikimiCrkami INACTIVE;

CREATE TRIGGER PriimkiZVelikimiCrkami_v2 FOR Avtor
ACTIVE BEFORE INSERT OR UPDATE
POSITION 6
AS
  DECLARE VARIABLE Zacetnica CHAR(1);
BEGIN
  -- follows trash code (because instructions)
  Zacetnica = SUBSTRING(NEW.Priimek FROM 1 FOR 1);
  IF (EXECUTE FUNCTION JeVelikaZacetnica (Zacetnica)) THEN
  BEGIN
    NEW.Priimek = Zacetnica || UPPER(SUBSTRING(NEW.Priimek FROM 2 FOR LENGTH(NEW.Priimek) - 1);
  END
  ELSE
  BEGIN
    NEW.Priimek = UPPER(NEW.Priimek);
  END
END

UPDATE Avtor SET Ime = '___' Priimek = 'neki' WHERE AvtorID = 1;
INSERT INTO Avtor VALUES (2, 'A', 'B');


/*
2.	naloga
V PB je tabela Vsebina(CDIDàCD,PIDàPosnetek). 
a)	S sprožilci zagotovite, da je na posameznem CD zapisanih največ 10 posnetkov.  
Namig: potrebno je obravnavati dogodka insert in update. 
V primeru, da uporabnik vnese 11. posnetek, sprožite izjemo, ki vrne sporočilo 'CD je poln (10 posnetkov) '.
Testirajte delovanje sprožilca. Rezultate testiranja zabeležite v poročilo vaje.
b)	S sprožilci zagotovite, da je skupna dolžina posnetkov na CD največ  60min. 
Namig: potrebno je obravnavati dogodka insert in update. Prioriteta sprožilca naj bo nižja od prioritete prejšnjega sprožilca. 
V primeru, da uporabnik vnese posnetek, s katerim bi skupna dolžina posnetkov bila > 60 min, sprožite izjemo, ki vrne sporočilo 'CD je poln (60 min) '. 
Predpostavimo, da med posnetki na CD ni presledkov.
 Testirajte delovanje sprožilca. Rezultate testiranja zabeležite v poročilo vaje.
 */

CREATE EXCEPTION CDPoln 'CD je poln (10 posnetkov) ';

CREATE TRIGGER Najvec10VCD FOR Vsebina
ACTIVE BEFORE INSERT OR UPDATE
POSITION 2
AS
BEGIN
  IF ((SELECT COUNT(*)
       FROM Vsebina v
       WHERE NEW.CDID = v.CDID) == 10) THEN
  BEGIN
    EXCEPTION CDPoln;
  END
END

-- Test
EXECUTE BLOCK
  AS
    DECLARE VARIABLE cnt = 0;
  BEGIN
    WHILE (cnt < 30) DO
    BEGIN
      INSERT INTO Vsebina VALUES (1, :cnt);
      cnt = cnt + 1;
    END
  END

CREATE EXCEPTION CDPolnT 'CD je poln (60 min)'

CREATE TRIGGER Najvec60min FOR Vsebina
ACTIVE BEFORE INSERT OR UPDATE
POSITION 1
AS
BEGIN
  IF ((SELECT SUM(p.dolzina)
       FROM Vsebina v
       WHERE NEW.CDID = v.CDID
       INNER JOIN Posnetek p ON v.PID = p.PID) > CAST(3600 AS TIME)) THEN
  BEGIN
    EXCEPTION CDPolnT;
  END
END

-- Test (lazy)

/*
3.	naloga
V PB je tabela CD(CDID,NaslovCD, Cena,Opombeo).

a)	S sprožilci zagotovite, da se vsebina atributa Opombe začne z besedo: AKCIJA (če je cena CD <8) ali UGODNO (če je cena CD >=8 in <=12). 
Če je cena CD >12, ne spreminjate vsebine opomb. Namig: potrebno je obravnavati dogodka insert in update. 
V primeru, da uporabnik vnese vebino opomb, naj bosta besedi AKCIJA /UGODNO dodani na začetek, če pa uporabnik pusti vsebino opomb prazno, bo nova vsebina le dodana beseda.
Testirajte delovanje sprožilca. Rezultate testiranja zabeležite v poročilo vaje.
*/

CREATE TRIGGER LabeledCDCena FOR CD
ACTIVE BEFORE INSERT OR UPDATE
POSITION 10
AS
BEGIN
  IF (NEW.Cena < 8) THEN
  BEGIN
    NEW.Opombe = 'AKCIJA: ' || NEW.Opombe;
  END
  IF (NEW.Cena >= 8 OR NEW.Cena <= 12) THEN
  BEGIN
    NEW.Opombe = 'UGODNO: ' || NEW.Opombe;
  END
END

-- Test (lazy)
