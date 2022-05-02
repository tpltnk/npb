/*
Prenesite PB GlasbenaZbirka.fdb. Relacijski model PB:
	Avtor(AvtorID, Ime, Priimek)
	Posnetek (PID, Naslov, Genre, Trajanje, AvtorIDàAvtor)
	CD(CDID,NaslovCD, Cena,Opombeo)
	Vsebina(CDIDàCD,PIDàPosnetek)
Ustvarite tabelo seznam(ZapSt,Naslov,Trajanje)
Napišite shranjeno proceduro, ki naslove in trajanje posnetkov določenega avtorja prepiše v tabelo Seznam. 
Vhodni parameter je Priimek avtorja. 
Delovanje procedure naj bo neodvisno od oblike črk vhodnega parametra (enako mora delovati, če je klicana s parametrom 'mahler', 'MAHLER' ali 'mAHLER'). 
Vrednost podatka ZapSt naj se povečuje od 1 naprej. Obravnavajte morebitne napake pri vnosu. Primer vsebine tabele Seznam:
1	Naziv posnetka 1 TrajanjePosnetka1
2  Naziv posnetka 2 TrajanjePosnetka2
3  ……
Po izvedbi procedure se vrne obvestilo 'Dodanih nnnn zapisov'.
*/

CREATE TABLE Seznam (
  ZapSt INT NOT NULL,
  Naslov CHAR(20) NOT NULL,
  Trajanje TIME NOT NULL,
  PRIMARY KEY (ZapSt)
);

CREATE PROCEDURE PrepisiVSeznam (Priimek CHAR(30))
RETURNS (Dodanih CHAR(30))
AS
  DECLARE VARIABLE ZapSt INT DEFAULT 1;
  DECLARE VARIABLE Trajanje TIME;
  DECLARE VARIABLE Naslov CHAR(20);
  DECLARE VARIABLE DodanihZapisov;
BEGIN
  FOR SELECT p.Trajanje, p.Naslov FROM Avtor a
      INNER JOIN Posnetek p ON a.AvtorID = p.AvtorID
      WHERE LOWER(a.Priimek) = LOWER(:Priimek)
      INTO :Trajanje, :Naslov
      DO
  BEGIN
    INSERT INTO Seznam (ZapSt, Naslov, Trajanje) VALUES (:ZapSt, :Naslov, :Trajanje);
    WHEN ANY DO
    BEGIN
      DodanihZapisov = 0;
      EXCEPTION;
    END
    ZapSt = ZapSt + 1;
  END
  Dodanih = 'Dodanih ' || CAST(DodanihZapisov AS CHAR(4)) || ' zapisov.'; 
END

