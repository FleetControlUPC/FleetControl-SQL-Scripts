USE FleetControl_DB;
GO

INSERT INTO ROL (nombre_rol) VALUES 
('Administrador'),
('Supervisor'),
('Gerente'),
('Conductor'),
('Técnico IoT');
GO

INSERT INTO EMPRESA_CLIENTE (ruc, razon_social, nombre_comercial, direccion_fiscal, estado_suscripcion) VALUES 
('20123456789', 'Logística Avanzada Lima S.A.C.', 'LogiLima', 'Av. Argentina 1234, Callao', 'ACTIVO'),
('20987654321', 'Transportes Transandino S.A.', 'Transandino', 'Av. Nicolas de Piérola 450, Lima', 'ACTIVO'),
('20556677889', 'Distribuidora de Alimentos Express', 'Aliexpress', 'Jr. Los Cedros 123, Surco', 'ACTIVO'),
('20443322110', 'Servicios Técnicos Globales', 'STG Perú', 'Av. Javier Prado Este 2500, San Borja', 'ACTIVO'),
('20889900112', 'Inversiones Guarda Todo S.A.', 'Guarda Todo', 'Calle Begonias 450, San Isidro', 'ACTIVO'),
('20776655443', 'Courier Rápido Miraflores', 'Miraflores Courier', 'Av. Larco 780, Miraflores', 'ACTIVO'),
('20334455667', 'Constructora Horizonte Azul', 'Horizonte', 'Av. El Sol 900, Chorrillos', 'ACTIVO'),
('20221199887', 'Telecomunicaciones del Perú S.A.', 'TelePerú', 'Av. República de Panamá 3055, San Isidro', 'SUSPENDIDO'),
('20665544332', 'Transporte de Carga Pesada Pacheco', 'Incotes', 'Asoc. Vivienda El Olivar, San Martín de Porres', 'ACTIVO'),
('20112233445', 'Mantenimiento y Climas S.A.C.', 'Climas Perú', 'Av. Aviación 1500, San Luis', 'ACTIVO');
GO

-- Sedes Empresa 1
INSERT INTO SEDE (nombre, direccion, cod_empresa) VALUES
('Sede Callao', 'Av. Faucett 1200, Callao', 1),
('Sede Lima Centro', 'Av. Wilson 450, Lima', 1);

-- Sedes Empresa 2
INSERT INTO SEDE VALUES
('Sede Lima Norte', 'Av. Túpac Amaru 3000, Comas', 2),
('Sede Arequipa', 'Av. Ejército 800, Arequipa', 2);

-- Sedes Empresa 3
INSERT INTO SEDE VALUES
('Sede Surco', 'Av. Primavera 1500, Surco', 3),
('Sede Ate', 'Carretera Central Km 8, Ate', 3);

-- Sedes Empresa 4
INSERT INTO SEDE VALUES
('Sede San Borja', 'Av. San Luis 2400, San Borja', 4),
('Sede La Molina', 'Av. Raúl Ferrero 500, La Molina', 4);

-- Sedes Empresa 5
INSERT INTO SEDE VALUES
('Sede San Isidro', 'Av. Canaval y Moreyra 200, San Isidro', 5);

-- Sedes Empresa 6
INSERT INTO SEDE VALUES
('Sede Miraflores', 'Av. Benavides 600, Miraflores', 6),
('Sede Barranco', 'Av. Grau 350, Barranco', 6);

-- Sedes Empresa 7
INSERT INTO SEDE VALUES
('Sede Chorrillos', 'Av. Huaylas 1200, Chorrillos', 7);

-- Sedes Empresa 8 (SUSPENDIDA)
INSERT INTO SEDE VALUES
('Sede San Isidro Central', 'Av. Camino Real 1000, San Isidro', 8);

-- Sedes Empresa 9
INSERT INTO SEDE VALUES
('Sede SMP', 'Av. Perú 2500, SMP', 9),
('Sede Puente Piedra', 'Panamericana Norte Km 28', 9);

-- Sedes Empresa 10
INSERT INTO SEDE VALUES
('Sede San Luis', 'Av. Canadá 1800, San Luis', 10);
GO

--USUARIOS

-- Usuarios Empresa 1
INSERT INTO USUARIO (email,password,nombre,cod_empresa,cod_rol) VALUES
('admin1@logilima.com','123456','Admin LogiLima',1,1),
('super1@logilima.com','123456','Supervisor LogiLima',1,2),
('gerente1@logilima.com','123456','Gerente LogiLima',1,3),
('cond1@logilima.com','123456','Conductor LogiLima',1,4);

-- Usuarios Empresa 2
INSERT INTO USUARIO VALUES
('admin2@transandino.com','123456','Admin Transandino','A',2,1),
('super2@transandino.com','123456','Supervisor Transandino','A',2,2),
('cond2@transandino.com','123456','Conductor Transandino','A',2,4);

-- Usuarios Empresa 3
INSERT INTO USUARIO VALUES
('admin3@aliexpress.com','123456','Admin Aliexpress','A',3,1),
('gerente3@aliexpress.com','123456','Gerente Aliexpress','A',3,3),
('cond3@aliexpress.com','123456','Conductor Aliexpress','A',3,4);

-- Usuarios Empresa 4
INSERT INTO USUARIO VALUES
('admin4@stg.com','123456','Admin STG','A',4,1),
('tec4@stg.com','123456','Tecnico IoT STG','A',4,5),
('cond4@stg.com','123456','Conductor STG','A',4,4);

-- Usuarios Empresa 5
INSERT INTO USUARIO VALUES
('admin5@guardatodo.com','123456','Admin GuardaTodo','A',5,1),
('super5@guardatodo.com','123456','Supervisor GuardaTodo','A',5,2),
('cond5@guardatodo.com','123456','Conductor GuardaTodo','A',5,4);

-- Usuarios Empresa 6
INSERT INTO USUARIO VALUES
('admin6@miraflores.com','123456','Admin Courier','A',6,1),
('cond6@miraflores.com','123456','Conductor Courier','A',6,4);

-- Usuarios Empresa 7
INSERT INTO USUARIO VALUES
('admin7@horizonte.com','123456','Admin Horizonte','A',7,1),
('gerente7@horizonte.com','123456','Gerente Horizonte','A',7,3),
('cond7@horizonte.com','123456','Conductor Horizonte','A',7,4);

-- Usuarios Empresa 8 (SUSPENDIDA - usuarios inactivos)
INSERT INTO USUARIO VALUES
('admin8@teleperu.com','123456','Admin TelePeru','I',8,1),
('gerente8@teleperu.com','123456','Gerente TelePeru','I',8,3);

-- Usuarios Empresa 9
INSERT INTO USUARIO VALUES
('admin9@incotes.com','123456','Admin Incotes','A',9,1),
('cond9@incotes.com','123456','Conductor Incotes','A',9,4);

-- Usuarios Empresa 10
INSERT INTO USUARIO VALUES
('admin10@climas.com','123456','Admin Climas','A',10,1),
('tec10@climas.com','123456','Tecnico Climas','A',10,5),
('cond10@climas.com','123456','Conductor Climas','A',10,4);
GO

-- VEHICULOS

-- Vehiculos Empresa 1
INSERT INTO VEHICULO (placa,marca,modelo,anio_fabricacion,tipo_combustible,cod_empresa,cod_sede) VALUES
('ABC-101','Toyota','Hilux',2020,'DIESEL',1,1),
('ABC-102','Hyundai','H100',2019,'DIESEL',1,1),
('ABC-103','Kia','Frontier',2021,'DIESEL',1,2),
('ABC-104','Nissan','Navara',2022,'DIESEL',1,2),
('ABC-105','Suzuki','Carry',2018,'GNV',1,1);

-- Vehiculos Empresa 2
INSERT INTO VEHICULO VALUES
('BCD-201','Volvo','FH',2020,'DIESEL',2,3),
('BCD-202','Scania','R450',2021,'DIESEL',2,3),
('BCD-203','Freightliner','Cascadia',2019,'DIESEL',2,4),
('BCD-204','Isuzu','FTR',2018,'DIESEL',2,4),
('BCD-205','Mercedes','Actros',2022,'DIESEL',2,3);

-- Vehiculos Empresa 3
INSERT INTO VEHICULO VALUES
('CDE-301','Hyundai','Porter',2019,'GASOLINA',3,5),
('CDE-302','Kia','Bongo',2020,'GLP',3,6),
('CDE-303','Chevrolet','N300',2021,'GNV',3,5),
('CDE-304','Toyota','Hiace',2022,'DIESEL',3,6),
('CDE-305','Nissan','Urvan',2018,'DIESEL',3,5);

-- Vehiculos Empresa 4
INSERT INTO VEHICULO VALUES
('DEF-401','Toyota','Corolla',2022,'GASOLINA',4,7),
('DEF-402','Hyundai','Elantra',2021,'GASOLINA',4,7),
('DEF-403','Kia','Rio',2020,'GNV',4,8),
('DEF-404','Nissan','Versa',2019,'GASOLINA',4,8),
('DEF-405','Chevrolet','Sail',2018,'GLP',4,7);

-- Vehiculos Empresa 5
INSERT INTO VEHICULO VALUES
('EFG-501','Toyota','Hilux',2021,'DIESEL',5,9),
('EFG-502','Nissan','Frontier',2020,'DIESEL',5,9),
('EFG-503','Mitsubishi','L200',2019,'DIESEL',5,9),
('EFG-504','Isuzu','D-Max',2022,'DIESEL',5,9),
('EFG-505','Ford','Ranger',2021,'DIESEL',5,9);

-- Vehiculos Empresa 6
INSERT INTO VEHICULO VALUES
('FGH-601','Suzuki','Carry',2020,'GNV',6,10),
('FGH-602','Kia','K2700',2019,'GLP',6,11),
('FGH-603','Hyundai','H100',2021,'DIESEL',6,10),
('FGH-604','Toyota','Hiace',2022,'DIESEL',6,11),
('FGH-605','Chevrolet','N300',2018,'GASOLINA',6,10);

-- Vehiculos Empresa 7
INSERT INTO VEHICULO VALUES
('GHI-701','Volvo','FMX',2020,'DIESEL',7,12),
('GHI-702','Scania','P360',2019,'DIESEL',7,12),
('GHI-703','Mercedes','Arocs',2021,'DIESEL',7,12),
('GHI-704','Freightliner','M2',2018,'DIESEL',7,12),
('GHI-705','Isuzu','NQR',2022,'DIESEL',7,12);

-- Vehiculos Empresa 8 (SUSPENDIDA)
INSERT INTO VEHICULO VALUES
('HIJ-801','Toyota','Corolla',2020,'GASOLINA',8,13),
('HIJ-802','Hyundai','Accent',2019,'GASOLINA',8,13);

-- Vehiculos Empresa 9
INSERT INTO VEHICULO VALUES
('IJK-901','Volvo','FH16',2022,'DIESEL',9,14),
('IJK-902','Scania','R500',2021,'DIESEL',9,15),
('IJK-903','Isuzu','FVR',2020,'DIESEL',9,14),
('IJK-904','Mercedes','Actros',2019,'DIESEL',9,15),
('IJK-905','Freightliner','Cascadia',2022,'DIESEL',9,14);

-- Vehiculos Empresa 10
INSERT INTO VEHICULO VALUES
('JKL-1001','Toyota','Hilux',2021,'DIESEL',10,16),
('JKL-1002','Nissan','Navara',2020,'DIESEL',10,16),
('JKL-1003','Hyundai','H1',2019,'DIESEL',10,16),
('JKL-1004','Kia','Frontier',2022,'DIESEL',10,16),
('JKL-1005','Chevrolet','Dmax',2021,'DIESEL',10,16);
GO