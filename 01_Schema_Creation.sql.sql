--CREATE DATABASE FleetControl_DB;
--GO

USE FleetControl_DB;
GO

CREATE TABLE EMPRESA_CLIENTE (
    cod_empresa INT IDENTITY(1,1) PRIMARY KEY,
    ruc CHAR(11) NOT NULL UNIQUE,
    razon_social VARCHAR(150) NOT NULL,
    nombre_comercial VARCHAR(100),
    direccion_fiscal VARCHAR(200),
    estado_suscripcion VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT CK_Empresa_Estado CHECK (estado_suscripcion IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO'))
);

CREATE TABLE ROL (
    cod_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE USUARIO (
    cod_usuario INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    estado CHAR(1) NOT NULL DEFAULT 'A',
    cod_empresa INT NOT NULL,
    cod_rol INT NOT NULL,
    CONSTRAINT FK_Usuario_Empresa FOREIGN KEY (cod_empresa) REFERENCES EMPRESA_CLIENTE(cod_empresa),
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (cod_rol) REFERENCES ROL(cod_rol),
    CONSTRAINT CK_Usuario_Estado CHECK (estado IN ('A', 'I'))
);

CREATE TABLE SEDE (
    cod_sede INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    cod_empresa INT NOT NULL,
    CONSTRAINT FK_Sede_Empresa FOREIGN KEY (cod_empresa) REFERENCES EMPRESA_CLIENTE(cod_empresa)
);

CREATE TABLE CONDUCTOR (
    cod_conductor INT IDENTITY(1,1) PRIMARY KEY,
    dni CHAR(8) NOT NULL UNIQUE,
    licencia VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    estado CHAR(1) DEFAULT 'A',
    cod_empresa INT NOT NULL,
    CONSTRAINT FK_Conductor_Empresa FOREIGN KEY (cod_empresa) REFERENCES EMPRESA_CLIENTE(cod_empresa)
);

CREATE TABLE ELEM_INSPECCION (
    cod_elemento INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cod_empresa INT NOT NULL,
    CONSTRAINT FK_ElemInspeccion_Empresa FOREIGN KEY (cod_empresa) REFERENCES EMPRESA_CLIENTE(cod_empresa)
);

CREATE TABLE TIPO_MANTENIMIENTO (
    cod_tipo_mant INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE VEHICULO (
    cod_vehiculo INT IDENTITY(1,1) PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio_fabricacion INT,
    tipo_combustible VARCHAR(20) NOT NULL,
    cod_empresa INT NOT NULL,
    cod_sede INT NOT NULL,
    CONSTRAINT FK_Vehiculo_Empresa FOREIGN KEY (cod_empresa) REFERENCES EMPRESA_CLIENTE(cod_empresa),
    CONSTRAINT FK_Vehiculo_Sede FOREIGN KEY (cod_sede) REFERENCES SEDE(cod_sede),
    CONSTRAINT CK_Vehiculo_Combustible CHECK (tipo_combustible IN ('GASOLINA', 'DIESEL', 'GLP', 'GNV', 'ELECTRICO'))
);

CREATE TABLE MANTENIMIENTO (
    cod_mant INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    taller VARCHAR(150),
    descripcion VARCHAR(255),
    cod_vehiculo INT NOT NULL,
    cod_tipo_mant INT NOT NULL,
    CONSTRAINT FK_Mantenimiento_Vehiculo FOREIGN KEY (cod_vehiculo) REFERENCES VEHICULO(cod_vehiculo),
    CONSTRAINT FK_Mantenimiento_Tipo FOREIGN KEY (cod_tipo_mant) REFERENCES TIPO_MANTENIMIENTO(cod_tipo_mant),
    CONSTRAINT CK_Mantenimiento_Costo CHECK (costo >= 0)
);

CREATE TABLE DOC_VEHICULAR (
    cod_doc INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    imagen VARCHAR(255),
    cod_vehiculo INT NOT NULL,
    -- Columna calculada para vigencia según la fecha actual [cite: 1134]
    estado_vigencia AS (CASE WHEN fecha_vencimiento < GETDATE() THEN 'VENCIDO' ELSE 'VIGENTE' END),
    CONSTRAINT FK_Doc_Vehiculo FOREIGN KEY (cod_vehiculo) REFERENCES VEHICULO(cod_vehiculo)
);

CREATE TABLE DISP_IOT (
    cod_dispositivo INT IDENTITY(1,1) PRIMARY KEY,
    imei VARCHAR(20) NOT NULL UNIQUE,
    serial VARCHAR(50) NOT NULL,
    modelo VARCHAR(50),
    sim_card_numero VARCHAR(15),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    cod_vehiculo INT UNIQUE, -- Relación 1:1 con Vehículo [cite: 1146]
    CONSTRAINT FK_Dispositivo_Vehiculo FOREIGN KEY (cod_vehiculo) REFERENCES VEHICULO(cod_vehiculo)
);

CREATE TABLE TELEMETRIA (
    cod_telemetria BIGINT IDENTITY(1,1) PRIMARY KEY,
    fecha_hora_exacta DATETIME NOT NULL,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    velocidad_actual DECIMAL(5,2),
    rpm_motor INT,
    nivel_combustible DECIMAL(5,2),
    estado_ignicion BIT,
    cod_dispositivo INT NOT NULL,
    CONSTRAINT FK_Telemetria_Dispositivo FOREIGN KEY (cod_dispositivo) REFERENCES DISP_IOT(cod_dispositivo)
);

CREATE TABLE ALERTA_TELEMETRIA (
    cod_alerta INT IDENTITY(1,1) PRIMARY KEY,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
    tipo_evento VARCHAR(50) NOT NULL,
    valor_registrado VARCHAR(50),
    cod_vehiculo INT NOT NULL,
    CONSTRAINT FK_Alerta_Vehiculo FOREIGN KEY (cod_vehiculo) REFERENCES VEHICULO(cod_vehiculo)
);

CREATE TABLE VIAJE (
    cod_viaje INT IDENTITY(1,1) PRIMARY KEY,
    fec_salida DATETIME NOT NULL,
    fec_llegada DATETIME,
    km_recorridos DECIMAL(10,2) DEFAULT 0,
    estado_viaje VARCHAR(20) DEFAULT 'EN_RUTA',
    cod_vehiculo INT NOT NULL,
    cod_conductor INT NOT NULL,
    CONSTRAINT FK_Viaje_Vehiculo FOREIGN KEY (cod_vehiculo) REFERENCES VEHICULO(cod_vehiculo),
    CONSTRAINT FK_Viaje_Conductor FOREIGN KEY (cod_conductor) REFERENCES CONDUCTOR(cod_conductor),
    CONSTRAINT CK_Viaje_Fechas CHECK (fec_llegada >= fec_salida)
);

CREATE TABLE CARGA_COMBUSTIBLE (
    cod_carga INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    galones DECIMAL(10,2) NOT NULL,
    costo DECIMAL(10,2) NOT NULL,
    foto_voucher VARCHAR(255),
    cod_viaje INT NOT NULL,
    CONSTRAINT FK_Carga_Viaje FOREIGN KEY (cod_viaje) REFERENCES VIAJE(cod_viaje),
    CONSTRAINT CK_Carga_Positiva CHECK (galones > 0 AND costo > 0)
);

CREATE TABLE INCIDENCIA (
    cod_incidencia INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    tipo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(500),
    cod_viaje INT NOT NULL,
    CONSTRAINT FK_Incidencia_Viaje FOREIGN KEY (cod_viaje) REFERENCES VIAJE(cod_viaje)
);

CREATE TABLE INSPECCION_DIARIA (
    cod_inspeccion INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    resultado_global VARCHAR(20),
    cod_viaje INT NOT NULL,
    CONSTRAINT FK_Inspeccion_Viaje FOREIGN KEY (cod_viaje) REFERENCES VIAJE(cod_viaje)
);

CREATE TABLE DETALLE_INSPECCION (
    cod_detalle INT IDENTITY(1,1) PRIMARY KEY,
    estado VARCHAR(20) NOT NULL,
    observacion VARCHAR(200),
    cod_inspeccion INT NOT NULL,
    cod_elemento INT NOT NULL,
    CONSTRAINT FK_Detalle_Inspeccion FOREIGN KEY (cod_inspeccion) REFERENCES INSPECCION_DIARIA(cod_inspeccion),
    CONSTRAINT FK_Detalle_Elemento FOREIGN KEY (cod_elemento) REFERENCES ELEM_INSPECCION(cod_elemento)
);
GO