/*
Ustvarite PB Liki.fdb. V baz ustvarite tabelo Tocka2D(x:n, y:n, barva:char(10)). 
Podatka x in y predstavljata koordinati točke v ravnini, barva je barva točke. 
V prvi inačici, naj bo tabela brez primarnega ključa.
	Napišite proceduro, ki v tabelo doda novo točko. Koordinati točke sta naključni celi števili iz intervala [1..100], barva je naključna barva iz množice: {bela, modra, rdeca, zelena, rumena}.
	Napišite proceduro, ki v tabelo doda n novih točk. Podatek n je parameter procedure.
	Napišite proceduro, ki izpiše vsebino tabele Tocke2D po kvadrantih. Oblika izpisa:
Tocke v ravnini
====
Prvi kvadrant
 T(3,5,bela)
 T(18,6,modra)
 ...
Skupaj: n točk
Drugi kvadrant
 T(3,-6,bela)
 T(1,-20,zelena)
 ...
Skupaj: k točk
Tretji kvadrant
...
	Naredite novo tabelo Tocka2D_v1, pri kateri bosta primarni ključ tabele sestavljali koordinati x in y. 
Prilagodite proceduro za vnos podatkov v tabelo novi strukturi – procedura naj vrne izpis, koliko točk je bilo dejansko dodanih v tabelo.
*/

CREATE DATABASE Liki;

CREATE TABLE Tocka2D (
  x INT NOT NULL,
  y INT NOT NULL,
  barva CHAR(10)
);

SET TERM !! ;

CREATE PROCEDURE NovaTocka
AS
  DECLARE VARIABLE barva_kljuc INT = SRAND() * 4;
  DECLARE VARIABLE barva CHAR(10);
BEGIN
  CASE barva_kljuc
    WHEN 0 THEN barva = 'bela'
    WHEN 1 THEN barva = 'modra'
    WHEN 2 THEN barva = 'rdeca'
    WHEN 3 THEN barva = 'zelena'
    WHEN 4 THEN barva = 'rumena'
  END
  /*  
  IF (barva_kljuc == 0) THEN BEGIN barva = 'bela'; END
  IF (barva_kljuc == 1) THEN BEGIN barva = 'modra'; END
  IF (barva_kljuc == 2) THEN BEGIN barva = 'rdeca'; END
  IF (barva_kljuc == 3) THEN BEGIN barva = 'zelena'; END
  IF (barva_kljuc == 4) THEN BEGIN barva = 'rumena'; END
  */
  --                                             [1, 100]
  --                                        ------------------
  INSERT INTO Tocka2D (x, y, barva) VALUES ((SRAND() * 99) + 1, (SRAND() * 99) + 1, :barva);
END !!

SET TERM ; !!

EXECUTE PROCEDURE NovaTocka;

CREATE EXCEPTION NeveljavnoSteviloTock 'Neveljavno stevilo tock'; 

SET TERM !! ;

CREATE PROCEDURE NoveTocke (n INT)
AS
  DECLARE VARIABLE cnt INT DEFAULT 0;
BEGIN
  IF (n < 0) THEN 
  BEGIN 
    EXCEPTION NeveljavnoSteviloTock;
    EXIT;
  END
  WHILE (cnt < n) DO
  BEGIN
    EXECUTE PROCEDURE NovaTocka;
    cnt = cnt + 1;
  END
END !!

SET TERM ; !!

EXECUTE PROCEDURE NoveTocke(SRAND() * 42);

SET TERMM !! ;

CREATE PROCEDURE TockePoKvadrantih 
RETURNS (izpis varchar(10000))
AS
  DECLARE VARIABLE x INT;
  DECLARE VARIABLE y INT;
  DECLARE VARIABLE barva CHAR(10);
  DECLARE VARIABLE n INT = 0;
BEGIN
  Izpis = 'Tocke v ravnini\n====\n'; 
  Izpis = Izpis || 'Prvi kvadrant\n';
  FOR SELECT x, y, barva FROM Tocke2D WHERE x >= 0 AND y >= 0 INTO :x, :y, :barva DO
  BEGIN
    Izpis = Izpis || 'T(' || CAST(x AS CHAR(10)) || ',' || CAST(y AS CHAR(10)) || ',' || barva || ')\n';
    n = n + 1;
  END
  Izpis = Izpis || 'Skupaj: ' || CAST(n AS CHAR(10)) || ' tock\n';
  n = 0;
  Izpis = Izpis || 'Drugi kvadrant\n';
  FOR SELECT x, y, barva FROM Tocke2D WHERE x > 0 AND y < 0 INTO :x, :y, :barva DO
  BEGIN
    Izpis = Izpis || 'T(' || CAST(x AS CHAR(10)) || ',' || CAST(y AS CHAR(10)) || ',' || barva || ')\n';
    n = n + 1;
  END
  Izpis = Izpis || 'Skupaj: ' || CAST(n AS CHAR(10)) || ' tock\n';
  n = 0;
  Izpis = Izpis || 'Tretji kvadrant\n';
  FOR SELECT x, y, barva FROM Tocke2D WHERE x < 0 AND y < 0 INTO :x, :y, :barva DO
  BEGIN
    Izpis = Izpis || 'T(' || CAST(x AS CHAR(10)) || ',' || CAST(y AS CHAR(10)) || ',' || barva || ')\n';
    n = n + 1;
  END
  Izpis = Izpis || 'Skupaj: ' || CAST(n AS CHAR(10)) || ' tock\n';
  n = 0;
  Izpis = Izpis || 'Cetrti kvadrant\n';
  FOR SELECT x, y, barva FROM Tocke2D WHERE x < 0 AND y > 0 INTO :x, :y, :barva DO
  BEGIN
    Izpis = Izpis || 'T(' || CAST(x AS CHAR(10)) || ',' || CAST(y AS CHAR(10)) || ',' || barva || ')\n';
    n = n + 1;
  END
  Izpis = Izpis || 'Skupaj: ' || CAST(n AS CHAR(10)) || ' tock\n';
END !!

SET TERM ; !!

EXECUTE PROCEDURE TockePoKvadrantih;

CREATE TABLE Tocke2D_v1 (
  x INT NOT NULL,
  y INT NOT NULL,
  barva CHAR(10) NOT NULL,
  PRIMARY KEY (x, y),
);

SET TERM !! ;

CREATE PROCEDURE NovaTocka_v1
RETURNS (SteviloVpisanih INT)
AS
  DECLARE VARIABLE barva_kljuc INT = RAND() * 4;
  DECLARE VARIABLE barva CHAR(10);
BEGIN
  CASE barva_kljuc
    WHEN 0 THEN barva = 'bela'
    WHEN 1 THEN barva = 'modra'
    WHEN 2 THEN barva = 'rdeca'
    WHEN 3 THEN barva = 'zelena'
    WHEN 4 THEN barva = 'rumena'
  END
  /*  
  IF (barva_kljuc == 0) THEN BEGIN barva = 'bela'; END
  IF (barva_kljuc == 1) THEN BEGIN barva = 'modra'; END
  IF (barva_kljuc == 2) THEN BEGIN barva = 'rdeca'; END
  IF (barva_kljuc == 3) THEN BEGIN barva = 'zelena'; END
  IF (barva_kljuc == 4) THEN BEGIN barva = 'rumena'; END
  */
  INSERT INTO Tocka2D_v1 (x, y, barva) VALUES ((RAND() * 99) + 1, (RAND() * 99) + 1, :barva);
  -- Ce smo insertirali duplikat
  WHEN SQLCODE -803 DO
  BEGIN
    SteviloVpisanih = 0;
    EXIT;
  END
  SteviloVpisanih = 1;
END !!

CREATE PROCEDURE NoveTocke_v1 (n INT)
RETURNS (SteviloVpisanih INT)
AS
  DECLARE VARIABLE cnt INT DEFAULT 0;
  DECLARE VARIABLE vpisanih INT DEFAULT 0;
BEGIN
  IF (n < 0) THEN 
  BEGIN 
    EXCEPTION NeveljavnoSteviloTock;
    EXIT;
  END
  WHILE (cnt < n) DO
  BEGIN
    EXECUTE PROCEDURE NovaTocka RETURNING_VALUES :vpisanih;
    cnt = cnt + 1;
    SteviloVpisanih = SteviloVpisanih + vpisanih;
  END
END !!

SET TERM ; !!

 
