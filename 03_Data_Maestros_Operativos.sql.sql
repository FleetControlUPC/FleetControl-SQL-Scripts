USE FleetControl_DB;
GO

-- Conductores Empresa 1
INSERT INTO CONDUCTOR (dni, licencia, nombre, telefono, estado, cod_empresa) VALUES
('70000001','A1-000001','Carlos Mendoza','987111111','A',1),
('70000002','A1-000002','Luis Paredes','987111112','A',1),
('70000003','A1-000003','Jorge Salas','987111113','A',1);

-- Conductores Empresa 2
INSERT INTO CONDUCTOR VALUES
('70000004','A2-000004','Miguel Torres','987111114','A',2),
('70000005','A2-000005','Pedro Rojas','987111115','A',2);

-- Conductores Empresa 3
INSERT INTO CONDUCTOR VALUES
('70000006','A3-000006','Renzo Castro','987111116','A',3),
('70000007','A3-000007','Mario León','987111117','A',3);

-- Conductores Empresa 4
INSERT INTO CONDUCTOR VALUES
('70000008','A4-000008','Alberto Ruiz','987111118','A',4),
('70000009','A4-000009','Daniel Soto','987111119','A',4);

-- Conductores Empresa 5
INSERT INTO CONDUCTOR VALUES
('70000010','A5-000010','Fernando Gil','987111120','A',5),
('70000011','A5-000011','Iván Núñez','987111121','A',5);

-- Conductores Empresa 6
INSERT INTO CONDUCTOR VALUES
('70000012','A6-000012','Raúl Medina','987111122','A',6),
('70000013','A6-000013','Hugo Vargas','987111123','A',6);

-- Conductores Empresa 7
INSERT INTO CONDUCTOR VALUES
('70000014','A7-000014','Cristian Vega','987111124','A',7),
('70000015','A7-000015','Sergio Campos','987111125','A',7);

-- Conductores Empresa 8 (SUSPENDIDA)
INSERT INTO CONDUCTOR VALUES
('70000016','A8-000016','Marco Flores','987111126','I',8),
('70000017','A8-000017','Ricardo Peña','987111127','I',8);

-- Conductores Empresa 9
INSERT INTO CONDUCTOR VALUES
('70000018','A9-000018','Edgar Quispe','987111128','A',9),
('70000019','A9-000019','Kevin Huamán','987111129','A',9);

-- Conductores Empresa 10
INSERT INTO CONDUCTOR VALUES
('70000020','A10-000020','Diego Cabrera','987111130','A',10);
GO

-- TIPO MANTENIMIENTO
INSERT INTO TIPO_MANTENIMIENTO (nombre) VALUES
('Preventivo'),
('Correctivo'),
('Cambio de Aceite'),
('Revisión Técnica'),
('Cambio de Neumáticos'),
('Emergencia');
GO

-- ELEM INSPECCION
-- Empresa 1
INSERT INTO ELEM_INSPECCION (nombre, cod_empresa) VALUES
('Luces',1),
('Frenos',1),
('Neumáticos',1),
('Nivel Aceite',1),
('Botiquín',1),
('Extintor',1);

-- Empresa 2
INSERT INTO ELEM_INSPECCION VALUES
('Luces',2),('Frenos',2),('Neumáticos',2),
('Nivel Aceite',2),('Botiquín',2),('Extintor',2);

-- Empresa 3
INSERT INTO ELEM_INSPECCION VALUES
('Luces',3),('Frenos',3),('Neumáticos',3),
('Nivel Aceite',3),('Botiquín',3),('Extintor',3);

-- Empresa 4
INSERT INTO ELEM_INSPECCION VALUES
('Luces',4),('Frenos',4),('Neumáticos',4),
('Nivel Aceite',4),('Botiquín',4),('Extintor',4);

-- Empresa 5
INSERT INTO ELEM_INSPECCION VALUES
('Luces',5),('Frenos',5),('Neumáticos',5),
('Nivel Aceite',5),('Botiquín',5),('Extintor',5);

-- Empresa 6
INSERT INTO ELEM_INSPECCION VALUES
('Luces',6),('Frenos',6),('Neumáticos',6),
('Nivel Aceite',6),('Botiquín',6),('Extintor',6);

-- Empresa 7
INSERT INTO ELEM_INSPECCION VALUES
('Luces',7),('Frenos',7),('Neumáticos',7),
('Nivel Aceite',7),('Botiquín',7),('Extintor',7);

-- Empresa 8 (SUSPENDIDA)
INSERT INTO ELEM_INSPECCION VALUES
('Luces',8),('Frenos',8),('Neumáticos',8),
('Nivel Aceite',8),('Botiquín',8),('Extintor',8);

-- Empresa 9
INSERT INTO ELEM_INSPECCION VALUES
('Luces',9),('Frenos',9),('Neumáticos',9),
('Nivel Aceite',9),('Botiquín',9),('Extintor',9);

-- Empresa 10
INSERT INTO ELEM_INSPECCION VALUES
('Luces',10),('Frenos',10),('Neumáticos',10),
('Nivel Aceite',10),('Botiquín',10),('Extintor',10);
GO

-- DISP IOT

INSERT INTO DISP_IOT (imei, serial, modelo, sim_card_numero, estado, cod_vehiculo)
SELECT 
    CONCAT('IMEI000', cod_vehiculo),
    CONCAT('SERIAL-', cod_vehiculo),
    'Tracker-X1',
    CONCAT('999000', cod_vehiculo),
    'ACTIVO',
    cod_vehiculo
FROM VEHICULO
WHERE cod_empresa <> 8;
GO