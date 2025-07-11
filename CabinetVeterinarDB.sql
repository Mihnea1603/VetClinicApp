CREATE DATABASE CabinetVeterinar;

CREATE TABLE Utilizatori(
	Username varchar(50) NOT NULL,
	Parola varchar(255) NOT NULL,
	CONSTRAINT PK_Utilizatori PRIMARY KEY(Username)
);
CREATE TABLE Stapani(
	StapanID int identity(1,1) NOT NULL,
	Nume nvarchar(50) NOT NULL,
	Prenume nvarchar(50) NOT NULL,
	Telefon varchar(15) NOT NULL,
	Email varchar(50) NOT NULL,
	Adresa nvarchar(50),
	Username varchar(50) NOT NULL,
	CONSTRAINT PK_Stapani PRIMARY KEY(StapanID),
	CONSTRAINT FK_Stapani_Utilizatori FOREIGN KEY(Username) REFERENCES Utilizatori(Username),
	CONSTRAINT UNQ_Stapani_Username UNIQUE(Username)
);
CREATE TABLE Medici(
	MedicID smallint identity(1,1) NOT NULL,
	Nume nvarchar(50) NOT NULL,
	Prenume nvarchar(50) NOT NULL,
	Specializare varchar(50) NOT NULL,
	Email varchar(50) NOT NULL,
	Username varchar(50) NOT NULL,
	CONSTRAINT PK_Medici PRIMARY KEY(MedicID),
	CONSTRAINT FK_Medici_Utilizatori FOREIGN KEY(Username) REFERENCES Utilizatori(Username),
	CONSTRAINT UNQ_Medici_Username UNIQUE(Username)
);
CREATE TABLE Animale(
	AnimalID int identity(1,1) NOT NULL,
	Nume nvarchar(50) NOT NULL,
	Specie varchar(50) NOT NULL,
	Rasa varchar(50) NOT NULL,
	DataNasterii smalldatetime,
	Sex char(1) NOT NULL,
	Greutate decimal(5,2) NOT NULL,
	StapanID int NOT NULL,
	CONSTRAINT PK_Animale PRIMARY KEY(AnimalID),
	CONSTRAINT FK_Animale_Stapani FOREIGN KEY(StapanID) REFERENCES Stapani(StapanID),
	CONSTRAINT CHK_Animale_Sex CHECK(Sex='M' OR Sex='F')
);
CREATE TABLE Vaccinuri(
	VaccinID smallint identity(1,1) NOT NULL,
	Nume varchar(50) NOT NULL,
	TipAdministrare varchar(50) NOT NULL,
	Doza varchar(25) NOT NULL,
	CONSTRAINT PK_Vaccinuri PRIMARY KEY(VaccinID)
);
CREATE TABLE AnimaleVaccinuri(
	AnimalID int NOT NULL,
	VaccinID smallint NOT NULL,
	DataVaccinarii smalldatetime NOT NULL,
	MedicID smallint NOT NULL,
	CONSTRAINT PK_AnimaleVaccinuri PRIMARY KEY(AnimalID,VaccinID),
	CONSTRAINT FK_AnimaleVaccinuri_Animale FOREIGN KEY(AnimalID) REFERENCES Animale(AnimalID),
	CONSTRAINT FK_AnimaleVaccinuri_Vaccinuri FOREIGN KEY(VaccinID) REFERENCES Vaccinuri(VaccinID),
	CONSTRAINT FK_AnimaleVaccinuri_Medici FOREIGN KEY(MedicID) REFERENCES Medici(MedicID)
);
CREATE TABLE Consultatii(
	ConsultatieID int identity(1,1) NOT NULL,
	DataConsultatiei smalldatetime NOT NULL,
	Diagnostic varchar(255) NOT NULL,
	Observatii varchar(255),
	AnimalID int NOT NULL,
	MedicID smallint NOT NULL,
	CONSTRAINT PK_Consultatii PRIMARY KEY(ConsultatieID),
	CONSTRAINT FK_Consultatii_Animale FOREIGN KEY(AnimalID) REFERENCES Animale(AnimalID),
	CONSTRAINT FK_Consultatii_Medici FOREIGN KEY(MedicID) REFERENCES Medici(MedicID)
);
CREATE TABLE Tratamente(
	TratamentID int identity(1,1) NOT NULL,
	TipTratament varchar(50) NOT NULL,
	Cost decimal(8,2) NOT NULL,
	Durata varchar(25) NOT NULL,
	Stare bit NOT NULL,
	ConsultatieID int NOT NULL,
	CONSTRAINT PK_Tratamente PRIMARY KEY(TratamentID),
	CONSTRAINT FK_Tratamente_Consultatii FOREIGN KEY(ConsultatieID) REFERENCES Consultatii(ConsultatieID)
);
CREATE TABLE Medicamente(
	MedicamentID int identity(1,1) NOT NULL,
	Nume varchar(50) NOT NULL,
	Descriere varchar(255) NOT NULL,
	Contraindicatii varchar(255) NOT NULL,
	Doza varchar(25) NOT NULL,
	Forma varchar(25) NOT NULL,
	CONSTRAINT PK_Medicamente PRIMARY KEY(MedicamentID)
);
CREATE TABLE TratamenteMedicamente(
	TratamentID int NOT NULL,
	MedicamentID int NOT NULL,
	CONSTRAINT PK_TratamenteMedicamente PRIMARY KEY(TratamentID,MedicamentID),
	CONSTRAINT FK_TratamenteMedicamente_Tratamente FOREIGN KEY(TratamentID) REFERENCES Tratamente(TratamentID),
	CONSTRAINT FK_TratamenteMedicamente_Medicamente FOREIGN KEY(MedicamentID) REFERENCES Medicamente(MedicamentID)
);
ALTER TABLE Animale
ADD CONSTRAINT CHK_Animale_Greutate CHECK(Greutate>0);

INSERT INTO Utilizatori(Username,Parola)
VALUES ('AndreiPopescu','scrypt:32768:8:1$4jEeIBD3F0gUBOzN$da8e556271db2db1ed21c88853af1c8460ffc7628f633f50d6cace92b0e96bf17ad2cf6d3b854912ba89acd2ea3e592639cb97b6cbbdf7e75efdc1ce879a91b6'),
('MariaIonescu','scrypt:32768:8:1$CSxRoGV3y5ZfqEEB$d9a4061fa8ecf38dd1402f469d0c9e177ae9ed1f418524f6e3aec8912b73ed231393c1320222efba3e2e5aa6a3d6400059995fe75de24b1906629c2883624cff'),
('IonVasile','scrypt:32768:8:1$aSuPtrkAgJSD6rNE$9bd0aa1c2cc6d0e5565d6ad78ecf0c56c687ca80d3cca688cd2858932d7c6af10a53174bd341fe0bb1b863bdacccaaa90eb0c1b9c971c175b39d53606e6c23b0'),
('ElenaGeorgescu','scrypt:32768:8:1$Q1crFpkUFB79PrWu$74b972103a19776653a80d97a5ca80ca9176ae6ec18c3fb00c10c72a918d65865ab0502187111362f1894cb56c985e73eb8cf02651e3c0bd48ce77a450be3a0e'),
('MihaiDumitru','scrypt:32768:8:1$NjUzbHBJ9ZruyHqg$baf29abba2dd7713030d5ed6588c9660cd8a8313aefc9b34246ab7252cd21c69f1cdf43502b5140d29b4c6311d49ac7e09903e54d362b9b9a9c980381df46c9e'),
('AnaConstantin','scrypt:32768:8:1$p1qPJ7wYbe402BJh$86753d95d3a335b363d634febe1fafd99b465c6f4587ac149e8b470332f9fe84eb06d5ba499f7862d45433dd93193403273d7c942b635ba9b837ac10b3df9600'),
('GabrielMarin','scrypt:32768:8:1$jqg3lPaw8kxa3Kgs$a60cb602900d67486ed0bd31d8d24e46b5b14073ce941e7ab92a6f15219a2c8af7b7826a2ede0772b8eb106a378d2b021315c5dce850f6653397afcc964c0c2c'),
('IoanaBucur','scrypt:32768:8:1$7Ozj7V6NpIUAuC0P$e00a3d7b2d073debab41f01f5483b4380d8ef2958d1af592e6a8e56a386f4f6c21b2f7153f6341ea1d6ac803b2199e879b84f3d124b2dd22092be0df76f2684a'),
('StefanPreda','scrypt:32768:8:1$EdLOMuVsEoEYlihj$60318cf75bdf338245dada93342474c5ce8dd3d3cc9ac1d88273379bd86b841a1cdaa1fd4911aa56160f04638e713408cbbab356e834e6e05cab282edffde10e'),
('GeorgianaRadu','scrypt:32768:8:1$sPzNbNXUYrXIcAFf$1818c39ded4c3aa863d1dcc5410b5aa3bbc4fd7879201444d73c322e99c6853e9dfe3487eb28cfcd82c3901b902ff519ce97b8359862c632f49d81382690aad8'),
('CristianPopa','scrypt:32768:8:1$D0RZj1A1t7bFZX7D$c2126676a23b10e4884542e9d3891a440c26099f402cac3bdd03c81c9b492b8136eea0079d33828615d256b09c3afe3299748895d7a1a79add23e1eb0846a678'),
('CameliaIlie','scrypt:32768:8:1$IQ0JbJLLerl2ZVQr$bd045b8222e3da3a25ce09a12114e05829d3ee2742aa6262152fd3a52dd9ef6bfa00a88e1ce48873d52ba183824531c21d3ddf0dbcbd81c2d3674768e591bdc9');

INSERT INTO Stapani(Nume,Prenume,Telefon,Email,Adresa,Username)
VALUES ('Popescu','Andrei','0712345678','andrei.popescu@example.com','Str. Mihai Viteazu 12','AndreiPopescu'),
('Ionescu','Maria','0723456789','maria.ionescu@example.com','Str. Lunga 14','MariaIonescu'),
('Vasile','Ion','0734567890','ion.vasile@example.com','Str. Dorobantilor 10','IonVasile'),
('Georgescu','Elena','0745678901','elena.georgescu@example.com','Str. Calea Victoriei 20','ElenaGeorgescu'),
('Dumitru','Mihai','0756789012','mihai.dumitru@example.com','Str. Stefan cel Mare 8','MihaiDumitru'),
('Constantin','Ana','0767890123','ana.constantin@example.com','Str. Tineretului 7','AnaConstantin');

INSERT INTO Medici(Nume,Prenume,Specializare,Email,Username)
VALUES ('Marin','Gabriel','Cardiologie','gabriel.marin@example.com','GabrielMarin'),
('Bucur','Ioana','Chirurgie','ioana.bucur@example.com','IoanaBucur'),
('Preda','Stefan','Dermatologie','stefan.preda@example.com','StefanPreda'),
('Radu','Georgiana','Neurologie','georgiana.radu@example.com','GeorgianaRadu'),
('Popa','Cristian','Oftalmologie','cristian.popa@example.com','CristianPopa'),
('Ilie','Camelia','Pediatrie','camelia.ilie@example.com','CameliaIlie');

INSERT INTO Animale(Nume,Specie,Rasa,DataNasterii,Sex,Greutate,StapanID)
VALUES ('Max','Caine','Labrador','2015-06-20','M',30.5,1),
('Mia','Pisica','Maine Coon','2017-04-15','F',8.2,2),
('Rocky','Caine','Ciobanesc German','2018-11-03','M',40,3),
('Luna','Pisica','Persana','2019-08-30','F',5.3,4),
('Toby','Caine','Beagle','2020-03-12','M',15,5),
('Sasha','Pisica','Siamese','2016-05-24','F',6.5,6),
('Charlie','Caine','Bulldog','2017-09-17','M',25,1),
('Bella','Pisica','Birmanez','2018-01-28','F',7.2,2),
('Zorro','Caine','Rottweiler','2019-11-02','M',35.5,3),
('Kitty','Pisica','British Shorthair','2020-02-22','F',5,4);

INSERT INTO Vaccinuri(Nume,TipAdministrare,Doza)
VALUES ('Rabies','Intramuscular','1 ml'),
('Parvoviroza','Intravenos','0.5 ml'),
('Leptospiroza','Intramuscular','1 ml'),
('Distemper','Intravenos','0.8 ml'),
('Hepatita Canina','Intramuscular','1.2 ml'),
('Pneumonie','Intramuscular','1 ml'),
('Tuse Canina','Intranasal','0.5 ml'),
('Giardia','Oral','1 ml'),
('Coronavirus','Intramuscular','0.7 ml'),
('Fiv/Felv','Subcutanat','0.3 ml');

INSERT INTO AnimaleVaccinuri(AnimalID,VaccinID,DataVaccinarii,MedicID)
VALUES (1,1,'2023-01-15',1),
(2,2,'2023-02-20',2),
(3,3,'2023-03-10',3),
(4,4,'2023-04-12',4),
(5,5,'2023-05-18',5),
(6,6,'2023-06-22',6),
(7,7,'2023-07-14',1),
(8,8,'2023-08-21',2),
(9,9,'2023-09-03',3),
(10,10,'2023-10-25',4);

INSERT INTO Consultatii(DataConsultatiei,Diagnostic,Observatii,AnimalID,MedicID)
VALUES ('2023-01-18','Probleme cu piciorul','Ar trebui sa se faca o radiografie',1,1),
('2023-02-25','Rash pe piele','Este o reactie alergica',2,2),
('2023-03-14','Probleme respiratorii','Necesar tratament cu antibiotice',3,3),
('2023-04-16','Infectie la ureche','Tratament cu picaturi auriculare',4,4),
('2023-05-20','Dureri abdominale','Posibil cainele sa aiba o infectie bacteriana',5,5),
('2023-06-24','Febra','Este necesar tratament intravenos',6,6),
('2023-07-18','Tuse cronica','Recomand tratament cu siropuri',7,1),
('2023-08-25','Probleme oculare','Ofera tratament ocular',8,2),
('2023-09-06','Hernie','Se va recomanda o operatie',9,3),
('2023-10-28','Probleme digestive','Este necesar un tratament de detoxifiere',10,4);

INSERT INTO Tratamente(TipTratament,Cost,Durata,Stare,ConsultatieID)
VALUES ('Radiografie',150,'1 ora',1,1),
('Tratament alergie',80,'1 zi',1,2),
('Antibiotice',100,'7 zile',1,3),
('Tratament ureche',50,'2 ore',1,4),
('Tratament abdominal',200,'3 zile',1,5),
('Tratament febra',120,'2 zile',1,6),
('Sirop',30,'1 zi',1,7),
('Tratament ocular',40,'2 zile',1,8),
('Operatie hernie',500,'7 zile',1,9),
('Detoxifiere',150,'3 zile',1,10);

INSERT INTO Medicamente(Nume,Descriere,Contraindicatii,Doza,Forma)
VALUES ('Paracetamol','Antiinflamator','Alergii la acetaminofen','500 mg','Tablete'),
('Ibuprofen','Anti-durere','Iritatii gastrice','200 mg','Tablete'),
('Amoxicilina','Antibiotic','Reactii alergice','250 mg','Capsule'),
('Diazepam','Sedativ','Interactiuni cu alcoolul','5 mg','Tablete'),
('Insulina','Antidiabetic','Hipoglicemie','10 UI','Injectabil'),
('Prednison','Corticosteroid','Hiperpresiune','20 mg','Tablete'),
('Cetirizina','Antialergic','Somnolenta','10 mg','Tablete'),
('Aspirina','Antiinflamator','Probleme stomacale','100 mg','Tablete'),
('Omeprazol','Inhibitor de pompa de protoni','Interactiuni cu medicamentele anticoagulante','20 mg','Capsule'),
('Loperamida','Antidiaric','Constipatie','2 mg','Tablete');

INSERT INTO TratamenteMedicamente(TratamentID,MedicamentID)
VALUES (1,4),
(2,7),
(3,3),
(4,7),
(5,1),
(6,9),
(7,2),
(8,6),
(9,3),
(10,5);

SELECT * FROM Utilizatori;
SELECT * FROM Stapani;
SELECT * FROM Medici;
SELECT * FROM Animale;
SELECT * FROM Vaccinuri;
SELECT * FROM AnimaleVaccinuri;
SELECT * FROM Consultatii;
SELECT * FROM Tratamente;
SELECT * FROM Medicamente;
SELECT * FROM TratamenteMedicamente;

/*DELETE FROM Stapani
WHERE Username='Mihnea';
DELETE FROM Medici
WHERE Username='Mihnea';
DELETE FROM Utilizatori
WHERE Username='Mihnea';*/