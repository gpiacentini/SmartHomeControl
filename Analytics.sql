DROP PROCEDURE IF EXISTS ricorrenze;
DELIMITER $$
CREATE PROCEDURE ricorrenze( IN ValoreMinimo FLOAT, OUT Risultato BOOLEAN)
BEGIN
	
    DECLARE Supporto FLOAT DEFAULT 0;
	DECLARE Confidenza FLOAT DEFAULT 0;
    DECLARE Utente INT DEFAULT 0;
    DECLARE UtenteComodo CHAR(16) DEFAULT 'abitantetest';
    DECLARE DispositivoUtilizzato varchar(50);
	DECLARE DispositivoProssimo varchar(50);
	DECLARE finito INT;
    DECLARE PhonUtil INT DEFAULT 0;
    DECLARE MonitorUtil INT DEFAULT 0;
    DECLARE AltoparlanteUtil INT DEFAULT 0;
    DECLARE LavatriceUtil INT DEFAULT 0;
    DECLARE AsciugatriceUtil INT DEFAULT 0;
    DECLARE ComputerUtil INT DEFAULT 0;
    DECLARE DispositivoUtilizzato1 VARCHAR(50);
    DECLARE Totale INT DEFAULT 0;
    DECLARE Totale1 INT DEFAULT 0;
    DECLARE Totale2 INT DEFAULT 0;
    
	
    
    DECLARE cursoreRicorrenze CURSOR FOR 
		WITH 
		Utenti AS(
					SELECT CodFiscale
					FROM utente),
                    
		InterazioniTarget AS 
			(SELECT CodFiscale,CodSmartPlug, OraInizio, LEAD(OraInizio,1) OVER (PARTITION BY CodFiscale ORDER BY OraInizio) AS InterazioneDopo,
						   LEAD(CodSmartPlug,1) OVER (PARTITION BY CodFiscale ORDER BY OraInizio) AS ProssimoDispositivo
					FROM interazionifissivariabili
			UNION 
            SELECT CodFiscale,CodSmartPlug, oraInizio, LEAD(oraInizio,1) OVER (PARTITION BY CodFiscale ORDER BY oraInizio) AS InterazioneDopo,
						   LEAD(CodSmartPlug,1) OVER (PARTITION BY CodFiscale ORDER BY oraInizio) AS ProssimoDispositivo
					FROM interazioneciclica
		),
        
		InterazioneT2 AS (
		SELECT CodFiscale, CodSmartPlug, ProssimoDispositivo,
	                DATEDIFF(InterazioneDopo, OraInizio) as Giorni,
	                TIMESTAMPDIFF (HOUR, OraInizio, InterazioneDopo) as Ore,
	                TIMESTAMPDIFF (MINUTE, OraInizio, InterazioneDopo) as Minuti
					FROM InterazioniTarget
		),
        
		InterazioneT3 AS(
		SELECT *
			   FROM InterazioneT2
			   WHERE Days=0 AND Hours=0 AND Minutes<=10
		),
      
        tuttiDispositivi AS(
			SELECT CodSmartPlug,Stato AS NomeDispositivo,'ConsumoFisso' AS tipoDispositivo
			FROM smartplug
			NATURAL JOIN dispositiviconsumofisso
			UNION 
			SELECT CodSmartPlug,Stato,'ConsumoVariabile' AS tipoDispositivo
			FROM smartplug
			NATURAL JOIN dispositiviconsumovariabile
			UNION 
			SELECT CodSmartPlug,Stato,'Ciclici' AS tipoDispositivo
			FROM smartplug
			NATURAL JOIN dispositivicicli
		),
        
        dispositivi1 AS
		(SELECT *
		FROM InterazioneT3
		NATURAL JOIN tuttiDispositivi),
        
		dispositivi2 AS(
		SELECT DU.CodFiscale,DU.CodSmartPlug AS SmartPlug1,DU.NomeDispositivo AS NomeDispositivo1,TU.CodSmartPlug AS SmartPlug2,TU.NomeDispositivo AS NomeDispositivo2
		FROM dispositivi1 DU 
		INNER JOIN tuttiDispositivi TU ON TU.CodSmartPlug = DU.ProssimoDispositivo )
		
        SELECT CodFiscale,NomeDispositivo1,NomeDispositivo2  
        FROM dispositivi2;    
    
    
	DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET finito=1;
    
	DROP TABLE IF EXISTS RicorrenzeUtenti;
	CREATE TEMPORARY TABLE RicorrenzeUtenti(
		IdAzione INT NOT NULL AUTO_INCREMENT,
        Phon INT DEFAULT 0,
        Monitor INT DEFAULT 0,
        Altoparlante INT DEFAULT 0,
        Lavatrice INT DEFAULT 0,
        Asciugatrice INT DEFAULT 0,
        Computer INT DEFAULT 0,
        PRIMARY KEY(IdAzione)
	)ENGINE=InnoDB AUTO_INCREMENT = 1 DEFAULT CHARSET=latin1;
    
    OPEN cursoreRicorrenze;
    preleva: LOOP
		FETCH cursoreRicorrenze INTO Utente, DispositivoUtilizzato, DispositivoProssimo;
        IF finito=1 THEN
			LEAVE preleva;
		END IF;
        preleva2: LOOP
			IF (Utente<>UtenteComodo) THEN
				LEAVE preleva2;
			END IF;
			IF(DispositivoUtilizzato1=DispositivoUtilizzato) THEN
				IF(DispositivoProssimo="phon") THEN
					SET PhonUtil=1;
				END IF;
				IF(DispositivoProssimo="monitor") THEN
					SET MonitorUtil=1;
				END IF;
				IF(DispositivoProssimo="altoparlante") THEN
					SET AltoparlanteUtil=1;
				END IF;
				IF(DispositivoProssimo="asciugatrice") THEN
					SET AsciugatriceUtil=1;
				END IF;
				IF(DispositivoProssimo="lavatrice") THEN
					SET LavatriceUtil=1;
				END IF;
				IF(DispositivoProssimo="computer") THEN
					SET ComputerUtil=1;
				END IF;
				SET DispositivoUtilizzato1=DispositivoProssimo;
				SET UtenteComodo=Utente;
			END IF;
        END LOOP preleva2;
        INSERT INTO RicorrenzeUtenti
        VALUES(PhonUtil, MonitorUtil, AltoparlanteUtil, LavatriceUtil,
			AsciugatriceUtil, ComputerUtil);
		SET PhonUtil=0;
        SET MonitorUtil=0;
        SET AltoparlanteUtil=0;
        SET LavatriceUtil=0;
        SET AsciugatriceUtil=0;
        SET ComputerUtil=0;
    END LOOP preleva;
    CLOSE cursoreRicorrenze;

    SELECT COUNT(*) INTO Totale
    FROM RicorrenzeUtenti RU;
    
    SELECT COUNT(*) INTO Totale1
    FROM RicorrenzeUtenti RU
    WHERE RU.Monitor=1
		AND RU.Computer=1;
        
	SELECT COUNT(*) INTO Totale2
    FROM RicorrenzeUtenti RU
    WHERE RU.Monitor=1
		AND RU.Computer=1
        AND RU.Altoparlante=1;
        
	SET Supporto=IF((Totale/Totale2)*100 IS NULL, 0,(Totale/Totale2)*100) ;
    SET Confidenza=IF((Supporto/Totale1) IS NULL,0,(Supporto/Totale1));
    
    IF(Confidenza>=ValoreMinimo) THEN
		SET Risultato=TRUE;
    ELSE
		SET Risultato=FALSE;
    END IF;
END $$
DELIMITER ;