BEGIN;
DROP DATABASE IF EXISTS mySmartHome;
CREATE DATABASE mySmartHome;
COMMIT;


USE mySmartHome;
--
-- Table structure for table `utente`
--

CREATE TABLE utente (
  CodFiscale char(16) not NULL,
  Nome varchar(45) NOT NULL,
  Cognome varchar(45) NOT NULL,
  DataNascita date NOT NULL,
  NumeroTelefono double NOT NULL,
  PRIMARY KEY (CodFiscale)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `utente`
--

INSERT INTO utente VALUES ('1','Giacomo','Piacentini','1997-09-21','3311468606'),('2','Marco','Lami','1996-10-1','3311468607'),('3','Diego','Ferrari','1996-10-4','3311468608'),('4','Lorenzo','Rioli','1996-02-03','3311468609'),('5','Luca','Lami','1998-09-23','3311468610');


--
-- Table structure for table `domandasicurezza`
--



create table DomandaSicurezza ( 
    IDDomanda int auto_increment, 
    Domande varchar(50) not null, 
    primary key (IDDomanda)
)engine = InnoDB auto_increment = 4 default charset = latin1; 



INSERT INTO  DomandaSicurezza VALUES (1,'Nome di tua madre'),(2,'Nome di tuo padre'),(3,'Animale preferito');

--
-- Table structure for table `account`
--



CREATE TABLE Account ( 
    Username varchar (50) not null ,  
    Passwd varchar (50) not null, 
    Domanda int not null,  
    Risposta varchar(50) not null,
    PRIMARY KEY (Username),
	FOREIGN KEY (Domanda) REFERENCES DomandaSicurezza (IDDomanda)
)engine = InnoDB default charset = latin1; 


--
-- Dumping data for table `account`
--



INSERT INTO Account VALUES ('giamipiacc','Gp123456878','1','Maria'),('gaiaagu','Ga88776655','2','Franco'),('bob245','Bo12345687890','3','cane'),('lorerio','Lr1111','1','luciana'),('diegoilpestifero','Dp123456878','2','Michele');



--
-- Table structure for table `Documentoidentità`
--



CREATE TABLE DocumentoIdentita ( 
	Tipologia VARCHAR(50), 
	Numero	int, 
    EnteRilascio VARCHAR(50) NOT NULL, 
    Scadenza DATE NOT NULL,  
	Account varchar(50) not null, 
    CodFiscale varchar(16) not null, 
    primary key(Tipologia, Numero), 
    foreign key (Account) references Account(Username), 
    foreign key (CodFiscale) references utente(CodFiscale) 
)ENGINE = InnoDB DEFAULT CHARSET = latin1; 

INSERT INTO DocumentoIdentita (Tipologia, Numero, EnteRilascio, Scadenza, Account, CodFiscale)
VALUES ('Patente',1234,'Motorizzazione','2030-01-5','giamipiacc','1'),
	   ('CartaIdentita',5678,'Comune','2022-04-5','gaiaagu','2'),
	   ('CartaIdentita',2345,'Comune','2025-04-9','bob245','3');

--
-- Table structure for table `Stanza`
--

create table Stanza ( 
    IDStanza int not null, 
    Nome varchar(50) not null, 
    Lunghezza double not null, 
    Larghezza double not null, 
    Altezza double not null, 
    Piano int not null,
    Temperatura float default null,
    PRIMARY KEY (IDStanza)
)engine = InnoDB default charset = latin1; 

INSERT INTO Stanza (IDStanza, Nome, Lunghezza, Larghezza, Altezza, Piano, Temperatura)
VALUES  (1,'Camera1',125.6,200.9,225,1,20.0),
        (2,'Camera2',177,198.66,195.5,2,19.5),
        (3,'Bagno1',195.6,250.9,225,1,19.0),
        (4,'Bagno2',175.6,200.9,225,2,18.5),
        (5,'Cucina',125.6,200.9,225,0,20.0),
        (6,'Sala',125.6,266.9,275,0,21.0),
        (7,'Corridoio',300.6,204.9,225,0,17.5);

--
-- Table structure for table `Porta`
--


create table Porta ( 
    IDPorta int auto_increment primary key, 
    Porta1 int not null, 
    Porta2 int, 
    Orientamento varchar(2)  check (Orientamento in ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')),  
    foreign key (Porta1) references Stanza(IDStanza), 
    foreign key (Porta2) references Stanza(IDStanza) 
)engine = InnoDB default charset = latin1; 

INSERT INTO Porta (Porta1, Porta2, Orientamento)
values(1,4,'NE'),
	  (1,4,null),
      (1,3,null),
      (2,4,'S'),
      (5,6,null),
      (5,7,null),
      (7,null,'W'),
      (6,null,'NE');

--
-- Table structure for table `Finestra`
--


create table Finestra ( 
    IDFinestra int auto_increment primary key, 
    Stanza int not null, 
    PuntoCardinale varchar(2) check (PuntoCardinale in ('N', 'NE', 'NW', 'S', 'SE', 'SW', 'E', 'W')), 
    foreign key (Stanza) references Stanza(IDStanza) 
)engine = InnoDB default charset = latin1; 

INSERT INTO Finestra(PuntoCardinale, Stanza)
VALUES ('N',1),
	   ('NW',1),
       ('S',2),
       ('W',3),
       ('SW',4),
       ('SW',5),
       ('N',5),
       ('NW',6),
       ('SW',6);

--
-- Table structure for table `condizionatori`
--

CREATE TABLE condizionatori (
  IDC int NOT NULL,
  Marca varchar(45) NOT NULL,
  Modello varchar(45) NOT NULL,
  IDStanza int NOT NULL,
  PRIMARY KEY (IDC),
  FOREIGN KEY (IDStanza) REFERENCES Stanza(IDStanza) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Dumping data for table `condizionatori`
--



INSERT INTO condizionatori VALUES (1,'philips','aaaaa',1),(2,'philips','bbbbb',2),(3,'philips','ccccc',3),(4,'philips','ddddd',4),(5,'philips','eeeee',5),(6,'philips','fffff',6),(7,'philips','ggggg',7);
--
-- Table structure for table `smartplug`
--

CREATE TABLE smartplug (
  CodSmartPlug int auto_increment,
  Stato tinyint NOT NULL,
  PRIMARY KEY (CodSmartPlug)
) ENGINE=InnoDB auto_increment = 26 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `smartplug`
--

INSERT INTO smartplug VALUES (1,1),(2,1),(3,1),(4,1),(5,0),(6,1),(7,1),(8,0),(9,1),(10,1),(11,0),(12,1),(13,0),(14,0),(15,1),(16,0),(17,1),(18,0),(19,0),(20,0),(21,0),(22,0),(23,1),(24,1),(25,0);




--
-- Table structure for table `dispositiviconsumovariabile`
--



CREATE TABLE dispositiviconsumovariabile (
  IDCV int auto_increment,
  Tipo char(45) NOT NULL,
  CodSmartPlug int NOT NULL,
  IDStanza int NOT NULL,
  PRIMARY KEY (IDCV),
  FOREIGN KEY (IDStanza) REFERENCES stanza(IDStanza),
  FOREIGN KEY (CodSmartPlug) REFERENCES smartplug(CodSmartPlug) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `dispositiviconsumovariabile`
--

INSERT INTO dispositiviconsumovariabile VALUES (1,'phon',6,4),(2,'microonde',7,2),(3,'forno',9,2);
--
-- Table structure for table `consumi`
--

CREATE TABLE consumi (
  IDCV int NOT NULL,
  Potenza int NOT NULL,
  Consumo float NOT NULL,
  PRIMARY KEY (IDCV,Potenza),
  FOREIGN KEY (IDCV) REFERENCES dispositiviconsumovariabile(IDCV) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Dumping data for table `consumi`
--

INSERT INTO consumi VALUES (1,1,10.40),(1,2,11.00),(1,3,11.70),(1,4,12.10),(1,5,12.80),(2,1,9.80),(2,2,10.30),(2,3,10.80),(2,4,11.20),(2,5,11.50),(3,1,10.00),(3,2,11.50),(3,3,13.10),(3,4,14.50),(3,5,17.80);


--
-- Table structure for table `consumicondizionatori`
--



CREATE TABLE consumicond (
  IDC int NOT NULL,
  Modalita int NOT NULL,
  Consumo float NOT NULL,
  PRIMARY KEY (IDC,Modalita),
  FOREIGN KEY (IDC) REFERENCES condizionatori(IDC) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Dumping data for table `consumicondizionatori`
--



INSERT INTO consumicond VALUES (1,1,10.00),(1,2,20.00),(1,3,30.00),(3,1,10.00),(3,2,20.00),(3,3,30.00),(4,1,10.00),(4,2,20.00),(4,3,30.00),(5,1,15.00),(5,2,20.00),(5,3,25.00),(6,1,13.00),(6,2,26.00),(6,3,39.00),(7,1,30.00),(7,2,40.00),(7,3,48.00);



--
-- Table structure for table `dispositivicicli`
--



CREATE TABLE dispositivicicli (
  IDCiclici int AUTO_INCREMENT,
  Tipo char(45) NOT NULL,
  CodSmartPlug int NOT NULL,
  IDStanza int DEFAULT NULL,
  PRIMARY KEY (IDCiclici),
  FOREIGN KEY (CodSmartPlug) REFERENCES smartplug (CodSmartPlug) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (IDStanza) REFERENCES stanza (IDStanza)
) ENGINE=InnoDB AUTO_INCREMENT = 7 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `dispositivicicli`
--


INSERT INTO dispositivicicli VALUES (4,'lavatrice',2,'4'),(5,'lavastoviglie',3,'2'),(6,'asciugatrice',4,'6');



--
-- Table structure for table `dispositiviconsumofisso`
--



CREATE TABLE dispositiviconsumofisso (
  IDCF int auto_increment,
  Tipo char(45) NOT NULL,
  Consumo float NOT NULL,
  CodSmartPlug int NOT NULL,
  IDStanza int NOT NULL,
  PRIMARY KEY (IDCF),
  FOREIGN KEY (CodSmartPlug) REFERENCES smartplug(CodSmartPlug) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (IDStanza) REFERENCES stanza(IDStanza) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT = 8 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `dispositiviconsumofisso`
--



INSERT INTO dispositiviconsumofisso VALUES (1,'frigorifero',28.10 ,12,1),(2,'alexa',21.70,1,5),(3,'televisione',29.80,10,5),
(5,'computer',28.0,8,1),(6,'monitor',19.5,19,1),(7,'altoparlante',15.6,20,1);


--
-- Table structure for table `programmi`
--

CREATE TABLE programmi (
  CodProgramma int AUTO_INCREMENT,
  IDCiclici int NOT NULL,
  Durata int,
  Consumo float,
  PRIMARY KEY (CodProgramma),
  FOREIGN KEY (IDCiclici) REFERENCES dispositivicicli(IDCiclici)
) ENGINE=InnoDB AUTO_INCREMENT= 8 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `programmi`
--

INSERT INTO programmi VALUES (1,4,5,8.50),(2,4,10,17.60),(3,4,15,21.50),(4,5,6,5.00),(5,5,12,13.00),(6,5,18,19.00),(7,6,7,4.00);


--
-- Table structure for table `interazioneciclica`
--

CREATE TABLE interazioneciclica (
  IDIC int AUTO_INCREMENT,
  oraInizio datetime NOT NULL,
  oraFine datetime DEFAULT NULL,
  CodSmartPlug int NOT NULL,
  CodFiscale char(12) NOT NULL,
  CodProgramma int NOT NULL,
  PRIMARY KEY (IDIC),
  FOREIGN KEY (CodSmartPlug) REFERENCES smartplug (CodSmartPlug) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (CodFiscale) REFERENCES utente(CodFiscale),
  FOREIGN KEY (CodProgramma) REFERENCES programmi(CodProgramma)
) ENGINE=InnoDB  AUTO_INCREMENT = 4 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `interazioneciclica`
--


INSERT INTO interazioneciclica VALUES (1,'2021-12-19 12:00:00','2021-12-19 12:25:00',11,'1',2),(2,'2021-12-19 12:00:00','2021-12-19 12:15:00',13,'3',3),(3,'2021-12-19 12:00:00','2021-12-19 12:06:00',14,'4',4);


--
-- Table structure for table `registroclima`
--



CREATE TABLE registroclima (
  IDRC int NOT NULL AUTO_INCREMENT,
  OraInizio datetime NOT NULL,
  OraFine datetime NOT NULL,
  umidita float NOT NULL,
  temperatura float NOT NULL,
  IDC int NOT NULL,
  codFiscale char(16) NOT NULL,
  modalita int NOT NULL,
  Ricorsiva tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (IDRC),
  FOREIGN KEY (CodFiscale) REFERENCES utente(CodFiscale) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `registroclima`
--

INSERT INTO registroclima VALUES (1,'2022-01-16 14:15:00','2022-01-16 15:38:00',8.00,24.90,1,'4',1,0),(2,'2022-01-16 00:00:11','2022-01-16 12:00:00',30.00,23.45,4,'5',2,0),(3,'2022-01-16 17:00:00','2022-01-17 02:00:00',28.70,18.90,3,'2',3,0);

--
-- Table structure for table `interazionifissivariabili`
--




CREATE TABLE interazionifissivariabili (
  IDFV int NOT NULL AUTO_INCREMENT,
  OraInizio datetime NOT NULL,
  OraFine datetime NOT NULL,
  LivelloPotenza int NOT NULL,
  CodSmartPlug int NOT NULL,
  CodFiscale char(16) NOT NULL,
  PRIMARY KEY (IDFV),
  FOREIGN KEY (CodFiscale) REFERENCES utente(CodFiscale) ON UPDATE CASCADE,
  FOREIGN KEY (CodSmartPlug) REFERENCES smartplug(CodSmartPlug) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `interazionifissivariabili`
--


INSERT INTO interazionifissivariabili VALUES (1,'2021-8-13 11:00:00','2021-8-13 11:40:00',-1,15,'1'),(2,'2021-8-13 17:15:00','2021-8-13 17:40:00',-1,16,'1'),(3,'2021-8-13 16:16:00','2021-8-13 16:40:00',-1,17,'1'),(4,'2021-8-13 17:28:00','2021-8-13 17:40:00',2,18,'1'),(5,'2021-8-13 17:28:00','2021-8-13 17:40:00',3,5,'3'),
(6,'2022-2-11 10:35:00','2022-2-11 10:37:00',-1,8,'1'),(7,'2022-2-11 10:35:00','2022-2-11 10:37:00',-1,19,'1'),(8,'2022-2-11 10:35:00','2022-2-11 10:37:00',-1,20,'1'),
(9,'2022-2-13 9:30:00','2022-2-13 9:37:00',-1,8,'1'),(10,'2022-2-13 9:30:00','2022-2-13 9:37:00',-1,19,'1'),(11,'2022-2-13 9:30:00','2022-2-13 9:37:00',-1,20,'1'),
(12,'2022-2-15 10:35:00','2022-2-15 10:37:00',-1,8,'1'),(13,'2022-2-15 10:35:00','2022-2-15 10:37:00',-1,19,'1'),(14,'2022-2-15 10:35:00','2022-2-15 10:37:00',-1,20,'1');
--
-- Table structure for table `elementiilluminazione`
--



CREATE TABLE elementiilluminazione (
  IDEI int NOT NULL AUTO_INCREMENT,
  Regolabile tinyint NOT NULL,
  IDStanza int NOT NULL,
  PRIMARY KEY (IDEI),
  FOREIGN KEY (IDStanza) REFERENCES stanza(IDStanza) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `elementiilluminazione`
--

INSERT INTO elementiilluminazione VALUES (1,1,'1'),(2,0,'2'),(3,1,'3'),(4,0,'4'),(5,1,'5'),(6,0,'6'),(7,0,'7'),(8,1,'1'),(9,0,'5');


--
-- Table structure for table `registroluci`
--



CREATE TABLE registroluci (
  IDRL int NOT NULL AUTO_INCREMENT,
  OraInizio time NOT NULL,
  OraFine time NOT NULL,
  Intensità int NOT NULL,
  TemperaturaColore int NOT NULL,
  IDEI int NOT NULL,
  CodFiscale char(16) NOT NULL,
  PRIMARY KEY (IDRL),
  FOREIGN KEY (CodFiscale) REFERENCES utente(CodFiscale) ON UPDATE CASCADE,
  FOREIGN KEY (IDEI) REFERENCES elementiilluminazione(IDEI)
) ENGINE=InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `registroluci`
--

INSERT INTO registroluci VALUES (1,'11:00:00','11:45:00',3,4,1,'3'),(2,'14:00:00','14:40:00',-1,-1,2,'4');


--
-- Table structure for table `impostazionipredefinite`
--



CREATE TABLE impostazionipredefinite (
  IDIP int NOT NULL AUTO_INCREMENT,
  OraInizio time NOT NULL,
  OraFine time NOT NULL,
  Intensità int NOT NULL,
  TemperaturaColore int NOT NULL,
  IDEI int NOT NULL,
  PRIMARY KEY (IDIP),
  FOREIGN KEY (IDEI) REFERENCES elementiilluminazione(IDEI) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;


--
-- Dumping data for table `impostazionipredefinite`
--


INSERT INTO impostazionipredefinite VALUES (1,'14:00:00','15:00:00',1,80,1),(2,'15:00:00','15:30:00',-1,-1,2);

