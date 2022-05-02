CREATE EXCEPTION TrajanjeException 'Napaka v trajanju posnetka';
CREATE PROCEDURE NovoTrajanje (PID INT, NovoTrajanje TIME)
RETURNS (status CHAR(30))
AS
BEGIN
  IF (NovoTrajanje <= 0) THEN 
  BEGIN 
    EXCEPTION TrajanjeException;
  END
  UPDATE Posnetek SET Trajanje = :NovoTrajanje WHERE PID = :PID;
  WHEN EXCEPTION TrajanjeException DO
  BEGIN
    status = 'Napaka v trajanju posnetka';
    EXIT;
  END
  WHEN SQLCODE -803 DO
  BEGIN
    status = 'Napaka pri trajanju';
    EXIT;
  END
  WHEN ANY DO
  BEGIN
    status = 'Druga vrsta napake';
    EXIT;
  END
  status = 'Ni napak'; -- TODO: is paraphrased
  EXIT;
END

EXECUTE PROCEDURE NovoTrajanje(1, '10:20:30');
