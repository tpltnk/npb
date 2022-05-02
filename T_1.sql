/*
S sprožilcem realizirajte poslovno pravilo, ki pravi, da se starost tekmovalca lahko le poveča, vendar največ za 1. 
Pri kršitvi tega poslovnega pravila, naj se sproži izjema prepovedan_updateTekmovalca z besedilom ‘Starost tekmovalca lahko le povečate za 1’. 
 */

CREATE EXCEPTION prepovedan_updateTekmovalca 'Starost tekmovalca lahko le povečate za 1';

CREATE TRIGGER updateTekmovalca
FOR Tekmovalec
ACTIVE BEFORE UPDATE
AS
  DECLARE VARIABLE starostna_razlika INT DEFAULT ABS(OLD.starost - NEW.starost)
BEGIN
  IF (starostna_razlika > 1) THEN
  BEGIN
    EXCEPTION prepovedan_updateTekmovalca;
  END
END
