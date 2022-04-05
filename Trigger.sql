-- Trigger vincolo integrità generico sull'inserimento di un documento scaduto

DROP TRIGGER IF EXISTS ValiditaDocumento;
DELIMITER $$
CREATE TRIGGER ValiditaDocumento
BEFORE INSERT ON DocumentoIdentita
FOR EACH ROW
BEGIN
	IF NEW.Scadenza < NOW() THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Il documento inserito è scaduto';
	END IF;
END $$
DELIMITER ;

-- Trigger vincolo integrità sulle impostazioni delle luci
DROP TRIGGER IF EXISTS vincoloregistroluci;
DELIMITER $$
CREATE TRIGGER vincoloregistroluci
BEFORE INSERT ON registroluci
FOR EACH ROW
BEGIN
     DECLARE RegolaLuce TINYINT;
     
     SELECT Regolabile INTO RegolaLuce
     FROM elementiilluminazione EI
     WHERE EI.IDEI=NEW.IDEI;
     
     IF(RegolaLuce=0 AND (NEW.TemperaturaColore<>-1 OR NEW.Intensità<>-1))
     THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Questo elemento di illuminazione non è regolabile';
	 ELSEIF (RegolaLuce=1 AND (NEW.Intensità<0 OR NEW.Intensità>5 OR NEW.TemperaturaColore<0))
      THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Intensità della luce può variare solo da 1 a 5 e la temperatura deve essere positiva';
	 END IF;
END $$
DELIMITER ;


-- Trigger Vincolo integrità generico sugli orari di inizio e fine

DROP TRIGGER IF EXISTS orarioregistroclima;
DELIMITER $$
CREATE TRIGGER orarioregistroclima
BEFORE INSERT ON registroclima
FOR EACH ROW
BEGIN
	IF (OraFine > OraInizio)
    THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT= 'I dati inseriti non sono corretti!';
	END IF;
END $$
DELIMITER ;
