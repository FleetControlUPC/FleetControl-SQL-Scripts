USE FleetControl_DB;
GO

-- GENERACION DE DOCUMENTACION

-- SOAT para TODOS (Vigentes)
INSERT INTO DOC_VEHICULAR (tipo, fecha_vencimiento, imagen, cod_vehiculo)
SELECT 'SOAT', DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365), GETDATE()), 'img_soat.jpg', cod_vehiculo
FROM VEHICULO;

-- Revisión Técnica (Mezcla Vigentes y Vencidos aleatorios)
INSERT INTO DOC_VEHICULAR (tipo, fecha_vencimiento, imagen, cod_vehiculo)
SELECT 
    'REVISION TECNICA', 
    CASE 
        WHEN cod_vehiculo % 7 = 0 THEN DATEADD(MONTH, -2, GETDATE()) -- 1 de cada 7 vencido
        ELSE DATEADD(MONTH, 8, GETDATE()) 
    END, 
    'img_rev.jpg', cod_vehiculo
FROM VEHICULO;
GO

-- GENERACION DE MANTENIMIENTOS
-- Generamos 150 mantenimientos aleatorios distribuidos en el último año
DECLARE @m INT = 1;
WHILE @m <= 150
BEGIN
    INSERT INTO MANTENIMIENTO (fecha, costo, taller, descripcion, cod_vehiculo, cod_tipo_mant)
    SELECT TOP 1
        DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()), -- Fecha aleatoria último año
        ABS(CHECKSUM(NEWID()) % 2000) + 150.00, -- Costo entre 150 y 2150
        CASE (ABS(CHECKSUM(NEWID()) % 3)) 
            WHEN 0 THEN 'Taller Central' 
            WHEN 1 THEN 'Mecánica Express' 
            ELSE 'Volvo Service' 
        END,
        'Mantenimiento programado generado autom.',
        (SELECT TOP 1 cod_vehiculo FROM VEHICULO ORDER BY NEWID()),
        (SELECT TOP 1 cod_tipo_mant FROM TIPO_MANTENIMIENTO ORDER BY NEWID())
    
    SET @m = @m + 1;
END
GO

-- GENERACION DE VIAJES

DECLARE @i INT = 1;
DECLARE @total_viajes INT = 300;

WHILE @i <= @total_viajes
BEGIN
    -- Seleccionar un vehículo aleatorio
    DECLARE @vehiculo INT = (SELECT TOP 1 cod_vehiculo FROM VEHICULO ORDER BY NEWID());
    
    -- Seleccionar un conductor DE LA MISMA EMPRESA que el vehículo
    DECLARE @empresa INT = (SELECT cod_empresa FROM VEHICULO WHERE cod_vehiculo = @vehiculo);
    DECLARE @conductor INT = (SELECT TOP 1 cod_conductor FROM CONDUCTOR WHERE cod_empresa = @empresa ORDER BY NEWID());

    -- Si no hay conductor para esa empresa, saltamos
    IF @conductor IS NOT NULL
    BEGIN
        -- Generar fechas (Salida hace 0-60 días, duración 2-10 horas)
        DECLARE @fec_salida DATETIME = DATEADD(HOUR, -ABS(CHECKSUM(NEWID()) % 1400), GETDATE()); -- Últimos 2 meses
        DECLARE @duracion INT = ABS(CHECKSUM(NEWID()) % 10) + 2;
        DECLARE @fec_llegada DATETIME = DATEADD(HOUR, @duracion, @fec_salida);
        
        -- Decidir si el viaje está EN_RUTA (si la fecha llegada sería futuro) o FINALIZADO
        DECLARE @estado VARCHAR(20) = 'FINALIZADO';
        IF @fec_llegada > GETDATE() 
        BEGIN 
            SET @estado = 'EN_RUTA'; 
            SET @fec_llegada = NULL;
        END

        INSERT INTO VIAJE (fec_salida, fec_llegada, km_recorridos, estado_viaje, cod_vehiculo, cod_conductor)
        VALUES (
            @fec_salida, 
            @fec_llegada, 
            CASE WHEN @estado = 'FINALIZADO' THEN @duracion * (40 + (ABS(CHECKSUM(NEWID()) % 40))) ELSE 0 END, -- KM estimados
            @estado, 
            @vehiculo, 
            @conductor
        );

        -- Generar Carga de Combustible para el 40% de los viajes finalizados
        IF @estado = 'FINALIZADO' AND (@i % 10 < 4) 
        BEGIN
             INSERT INTO CARGA_COMBUSTIBLE (fecha, galones, costo, cod_viaje, foto_voucher)
             VALUES (@fec_salida, 15.0, 250.00, @@IDENTITY, 'voucher_gen.jpg');
        END
    END

    SET @i = @i + 1;
END
GO

-- GENERACION DE TELEMETRIA

-- Puntos de Salida (Para TODOS los viajes)
INSERT INTO TELEMETRIA (fecha_hora_exacta, latitud, longitud, velocidad_actual, rpm_motor, nivel_combustible, estado_ignicion, cod_dispositivo)
SELECT 
    V.fec_salida,
    -12.0400 + (V.cod_vehiculo * 0.002) + (CHECKSUM(NEWID()) % 100 * 0.0001), -- Variación latitud
    -77.0400 - (V.cod_vehiculo * 0.002) + (CHECKSUM(NEWID()) % 100 * 0.0001), -- Variación longitud
    0, -- Velocidad 0 al inicio
    800, 
    95.0, 1, D.cod_dispositivo
FROM VIAJE V INNER JOIN DISP_IOT D ON V.cod_vehiculo = D.cod_vehiculo;

-- Puntos En Ruta (1 hora después - Tráfico)
INSERT INTO TELEMETRIA (fecha_hora_exacta, latitud, longitud, velocidad_actual, rpm_motor, nivel_combustible, estado_ignicion, cod_dispositivo)
SELECT 
    DATEADD(MINUTE, 30, V.fec_salida),
    -12.0600 + (V.cod_vehiculo * 0.003),
    -77.0600 - (V.cod_vehiculo * 0.003),
    35 + (ABS(CHECKSUM(NEWID()) % 30)), -- Velocidad 35-65 km/h
    1800 + (ABS(CHECKSUM(NEWID()) % 500)), 
    90.0, 1, D.cod_dispositivo
FROM VIAJE V INNER JOIN DISP_IOT D ON V.cod_vehiculo = D.cod_vehiculo
WHERE DATEADD(MINUTE, 30, V.fec_salida) < ISNULL(V.fec_llegada, GETDATE());

-- Puntos Velocidad (2 horas después - Autopista)
INSERT INTO TELEMETRIA (fecha_hora_exacta, latitud, longitud, velocidad_actual, rpm_motor, nivel_combustible, estado_ignicion, cod_dispositivo)
SELECT 
    DATEADD(HOUR, 2, V.fec_salida),
    -12.1500 + (V.cod_vehiculo * 0.005),
    -77.1500 - (V.cod_vehiculo * 0.005),
    70 + (ABS(CHECKSUM(NEWID()) % 40)), -- Velocidad 70-110 km/h (Algunos generarán alerta)
    2500 + (ABS(CHECKSUM(NEWID()) % 1000)), 
    75.0, 1, D.cod_dispositivo
FROM VIAJE V INNER JOIN DISP_IOT D ON V.cod_vehiculo = D.cod_vehiculo
WHERE DATEADD(HOUR, 2, V.fec_salida) < ISNULL(V.fec_llegada, GETDATE());

-- Puntos Final (Solo viajes finalizados)
INSERT INTO TELEMETRIA (fecha_hora_exacta, latitud, longitud, velocidad_actual, rpm_motor, nivel_combustible, estado_ignicion, cod_dispositivo)
SELECT 
    V.fec_llegada,
    -12.2500 + (V.cod_vehiculo * 0.002),
    -77.2500 - (V.cod_vehiculo * 0.002),
    0, 0, 50.0, 0, D.cod_dispositivo
FROM VIAJE V INNER JOIN DISP_IOT D ON V.cod_vehiculo = D.cod_vehiculo
WHERE V.estado_viaje = 'FINALIZADO';
GO

-- GENERACION DE ALERTAS E INCIDENCIAS

-- Alerta automática: Si en telemetría hay > 90km/h, crear alerta
INSERT INTO ALERTA_TELEMETRIA (fecha_hora, tipo_evento, valor_registrado, cod_vehiculo)
SELECT 
    T.fecha_hora_exacta,
    'EXCESO_VELOCIDAD',
    CAST(T.velocidad_actual AS VARCHAR) + ' km/h',
    D.cod_vehiculo
FROM TELEMETRIA T
INNER JOIN DISP_IOT D ON T.cod_dispositivo = D.cod_dispositivo
WHERE T.velocidad_actual > 90;

-- Incidencias aleatorias (para el 10% de los viajes)
INSERT INTO INCIDENCIA (fecha, tipo, descripcion, cod_viaje)
SELECT 
    DATEADD(HOUR, 1, fec_salida),
    'MECANICA',
    'Ruido extraño en motor reportado por conductor',
    cod_viaje
FROM VIAJE
WHERE cod_viaje % 10 = 0; -- 1 de cada 10 viajes tiene incidencia

PRINT 'Carga masiva completada exitosamente.'
GO

-- GENERACION DE INSPECCIONES

INSERT INTO INSPECCION_DIARIA (fecha, resultado_global, cod_viaje)
SELECT 
    DATEADD(MINUTE, -30, fec_salida), -- 30 min antes de salir
    CASE WHEN cod_viaje % 20 = 0 THEN 'OBSERVADO' ELSE 'APROBADO' END, -- 5% observados
    cod_viaje
FROM VIAJE;

-- Detalle de inspección (Simulado)
INSERT INTO DETALLE_INSPECCION (estado, observacion, cod_inspeccion, cod_elemento)
SELECT 
    CASE WHEN I.resultado_global = 'OBSERVADO' AND E.cod_elemento % 3 = 0 THEN 'FALLA' ELSE 'OK' END,
    CASE WHEN I.resultado_global = 'OBSERVADO' AND E.cod_elemento % 3 = 0 THEN 'Desgaste visible' ELSE 'Sin novedad' END,
    I.cod_inspeccion,
    E.cod_elemento
FROM INSPECCION_DIARIA I
CROSS JOIN ELEM_INSPECCION E -- Cruzamos con todos los elementos de inspección
WHERE E.cod_empresa = (SELECT V.cod_empresa FROM VIAJE Vi JOIN VEHICULO V ON Vi.cod_vehiculo = V.cod_vehiculo WHERE Vi.cod_viaje = I.cod_viaje) -- Asegura que sean elementos de SU empresa
AND I.cod_inspeccion % 10 = 0; -- Solo generamos detalle para algunas para no explotar la BD
GO