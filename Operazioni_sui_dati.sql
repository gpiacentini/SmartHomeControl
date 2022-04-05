-- Operazione 1: Inserimenro di un nuovo account 

DROP PROCEDURE IF EXISTS InserisciAccount; 
delimiter $$
CREATE PROCEDURE InserisciAccount 	(
									in codfiscale char(16), --
									in nome varchar(45), --
                                    in cognome varchar(45), --
                                    in datanascita date, --
									in numerotelefono double, --
                                    in username varchar(50), 
                                    in passwd varchar(50), 
                                    in domanda int, 
                                    in risposta varchar(50), 
									in tipologiaDocumento varchar(50), 
                                    in scadenzaDocumento date, 
                                    in enteRilascioDocumento varchar(50), 
                                    in numeroDocumento int -- 
									)
BEGIN 
    
    if (datediff(scadenzaDocumento, current_date) > 0 && length(passwd) > 5)  then 
		begin 
			insert into utente values (codfiscale, nome, cognome, datanascita, numerotelefono);
            insert into account values (username, passwd, domanda, risposta); 
            insert into DocumentoIdentita values (tipologiaDocumento, numeroDocumento, enteRilascioDocumento, scadenzaDocumento, username, codfiscale); 
        end ; 
	else 
    signal sqlstate '45000'
    set message_text='ERROR : Inserisci un documento in corso di validità o una password più lunga di 5 caratteri';
	end if;

END $$
delimiter ; 

#call InserisciAccount ('16','Mario','Rossi','1987-12-12','3311468654','mariorossi','1234890',1,'Maria','Passaporto',
#'2025-12-12','Questura',1456);

-- Operazione 2: Lettura dell'orario di fine di un programma ciclico (Con Trigger che aggiorna l'attributo ridondante)

DROP PROCEDURE IF EXISTS orariofine;
DELIMITER $$
CREATE PROCEDURE orariofine (IN IDProgramma INT)
BEGIN
	SELECT oraFine
    FROM interazioneciclica
    WHERE IDIC=IDProgramma;
END $$
DELIMITER ;

#call orarioFine (2);

#Trigger che aggiorna 'OraFine'

DROP TRIGGER IF EXISTS updateorafine;
DELIMITER $$
CREATE TRIGGER updateorafine
BEFORE INSERT ON interazioneciclica FOR EACH ROW
BEGIN
    DECLARE DurataProgramma INT;
    DECLARE OraFineT TIME;
    
    SELECT Durata INTO DurataProgramma
    FROM programmi P
    WHERE P.CodProgramma=NEW.CodProgramma;
    
    SET OraFineT=NEW.oraInizio + INTERVAL DurataProgramma MINUTE;
    SET NEW.oraFine=OraFineT;
END $$
DELIMITER ;

-- Operazione 3: Visualizzazione della temperatura di una stanza (Con Trigger che aggiorna l'attributo ridondante) QUI!

DROP PROCEDURE IF EXISTS leggiTemperatura;
DELIMITER $$
CREATE PROCEDURE leggiTemperatura (IN StanzaT INT)
BEGIN

    IF (StanzaT = NULL or StanzaT = 0)
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Inserisci un codice stanza valido';
	END IF;
    
    SELECT Temperatura
    FROM Stanza
    WHERE IDStanza=StanzaT;
END $$
DELIMITER ;

#call leggiTemperatura(6);

#Trigger che aggiorna 'Temperatura' 

DROP TRIGGER IF EXISTS updateTemperatura;
DELIMITER $$
CREATE TRIGGER updateTemperatura
AFTER INSERT ON registroclima FOR EACH ROW
BEGIN
    DECLARE StanzaT INT;
    
    SELECT IDStanza INTO StanzaT
    FROM condizionatori C
    WHERE C.IDC=NEW.IDC;
    
    UPDATE stanza S
    SET S.Temperatura=NEW.temperatura
    WHERE IDStanza=StanzaT;
END $$
DELIMITER ;

-- Operazione 4: Inserimento di un dispositivo a consumo fisso

DROP PROCEDURE IF EXISTS aggiuntadispositivoconsumofisso;
DELIMITER $$
CREATE PROCEDURE aggiuntadispositivoconsumofisso (IN TipoN CHAR(45), IN ConsumoN FLOAT, IN SmartPlugN INT, IN StanzaN INT)
BEGIN
     DECLARE SmartPlugS TINYINT;
     DECLARE IDInteressato INT;
     
     IF ( ConsumoN < 0)
     THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Il consumo deve essere per forza maggiore o uguale a zero';
	 END IF;
     
     SELECT stato INTO SmartPlugS
     FROM smartplug
     WHERE CodSmartPlug=SmartPlugN;
     
     IF( SmartPlugS=1 ) 
     THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Non puoi utilizzare una smart plug già in uso';
	 END IF;
	
     INSERT INTO dispositiviconsumofisso(Tipo, Consumo, CodSmartPlug, IDStanza)
     VALUES(TipoN, ConsumoN, SmartPlugN, StanzaN);
     
     UPDATE smartplug
     SET Stato=1
     WHERE CodSmartPlug=SmartPlugN;
END $$
DELIMITER ;

#call aggiuntadispositivoconsumofisso ('Stereo',29.30,8,5);

-- Operazione 5: Eliminazione di un dispositivo a consumo fisso

DROP PROCEDURE IF EXISTS eliminadispositivoconsumofisso;
DELIMITER $$
CREATE PROCEDURE eliminadispositivoconsumofisso (IN DispositivoT INT)
BEGIN
    DECLARE SmartPlugT INT;

    SELECT CodSmartPlug INTO SmartPlugT
    FROM dispositiviconsumofisso
    WHERE IDCF=DispositivoT;
    
    DELETE
    FROM dispositiviconsumofisso
    WHERE IDCF=DispositivoT;
    
    UPDATE smartplug
    SET stato=0
    WHERE CodSmartPlug=SmartPlugT;
END $$
DELIMITER ;

#call eliminadispositivoconsumofisso (4);

-- Operazione 6: Salvataggio di un'interazione con un dispositivo d'illuminazione

DROP PROCEDURE IF EXISTS salvataggiointerazioneilluminazione;
DELIMITER $$
CREATE PROCEDURE salvataggiointerazioneilluminazione (IN OraInizio TIME, IN OraFine TIME,
IN IntensitaN INT, IN TemperaturaN INT, IN IDEI INT, IN utente CHAR(16))
BEGIN
     
     IF(OraInizio > OraFine or IntensitaN <-1 OR IntensitaN > 5 or TemperaturaN <-1)
     THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT='I dati inseriti non sono corretti';
	 END IF;
    
     
     INSERT INTO registroluci (OraInizio, OraFine, Intensità, TemperaturaColore, IDEI,codFiscale)
     VALUES(Orainizio, Orafine, IntensitaN, TemperaturaN, IDEI, utente);
END $$
DELIMITER ;

#call salvataggiointerazioneilluminazione ('18:30:00','18:35:10',3,4,8,1);

-- Operazione 7: Salvataggio di un'interazione con un dispositivo di climatizzazione

DROP PROCEDURE IF EXISTS salvataggiointerazioneclimatica;
DELIMITER $$
CREATE PROCEDURE salvataggiointerazioneclimatica (IN Inizio DATETIME, IN Fine DATETIME,
IN UmiditaN FLOAT, IN TemperaturaN FLOAT, IN IDC INT, IN utente CHAR(16), IN modalitaN INT)

BEGIN
     
     IF(Fine < Inizio)
     THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT='I dati inseriti per giorno e mese non sono validi';
	 END IF;
    
     
     INSERT INTO registroclima (OraInizio, OraFine, umidita, temperatura, IDC, codFiscale, modalita)
     VALUES(inizio, fine, UmiditaN, TemperaturaN, IDC, utente, modalitaN);
END $$
DELIMITER ;

#call salvataggiointerazioneclimatica ('2022-01-19 14:15:00', '2022-01-19 14:29:00',7.5, 24.5, 5,'1',1);

-- Operazione 8: Aggiunta di impostazioni predefinite per gli elementi di illuminazione

DROP PROCEDURE IF EXISTS inserimentopredilluminazione;
DELIMITER $$
CREATE PROCEDURE inserimentopredilluminazione (IN Inizio TIME, IN Fine TIME, 
IN Intensita INT, IN TemperaturaColore INT, IN IDEI INT)
BEGIN 
     
     IF (TemperaturaColore < -1 OR Intensita < -1 OR Intensita > 5 OR Fine < Inizio)
     THEN
        SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT='I dati forniti non sono validi';
	 END IF;
     
     INSERT INTO impostazionipredefinite (OraInizio, OraFine, Intensità, TemperaturaColore, IDEI)
     VALUES ( Inizio, Fine, Intensita, TemperaturaColore, IDEI);
END $$
DELIMITER ;

#call inserimentopredilluminazione ('16:00:00','16:45:00',3,2,5);
