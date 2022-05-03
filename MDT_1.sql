/*
Pri brisanju tekmovalca, naj se samodejno v tabelo ‘Izbrisani’ vpišejo naslednji podatki: TID, Ime, Priimek, ime uporabnika, ki je opravil brisanje, datum in čas brisanja.
*/

CREATE TABLE Izbrisani (
  TID INT NOT NULL,
  Ime VARCHAR(20) NOT NULL,
  Priimek VARCHAR(30) NOT NULL,
  ImeUporabnika VARCHAR(30) NOT NULL
  DatumCasBrisanja DATETIME NOT NULL,
  PRIMARY KEY (TID)
);

SET TERM !! ;

CREATE TRIGGER OnDeleteTekmovalec
FOR Tekmovalec
ACTIVE AFTER DELETE
AS
BEGIN
  INSERT INTO Izbrisani (TID, Ime, Priimek, ImeUporabnika, DatumCasBrisanja)
         VALUES (OLD.TID, OLD.Ime, OLD.Priimek, CURRENT_USER, CURRENT_DATETIME);
END !!

SET TERM ; !!

