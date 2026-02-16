USE FleetControl_DB;
GO

DECLARE @ID_Empresa_C4 INT = 1; 

WITH Costos_Mant AS (
    SELECT M.cod_vehiculo, SUM(M.costo) AS Total_Mant
    FROM MANTENIMIENTO M
    JOIN VEHICULO V ON M.cod_vehiculo = V.cod_vehiculo
    WHERE V.cod_empresa = @ID_Empresa_C4
    GROUP BY M.cod_vehiculo
),
Costos_Comb AS (
    SELECT V.cod_vehiculo, SUM(C.costo) AS Total_Comb
    FROM VIAJE V
    JOIN CARGA_COMBUSTIBLE C ON V.cod_viaje = C.cod_viaje
    JOIN VEHICULO Veh ON V.cod_vehiculo = Veh.cod_vehiculo
    WHERE Veh.cod_empresa = @ID_Empresa_C4
    GROUP BY V.cod_vehiculo
)
SELECT TOP 10
    V.placa, 
    V.modelo,
    ISNULL(CM.Total_Mant, 0) AS Mantenimiento_Sol,
    ISNULL(CC.Total_Comb, 0) AS Combustible_Sol,
    (ISNULL(CM.Total_Mant, 0) + ISNULL(CC.Total_Comb, 0)) AS Costo_Total_Operativo
FROM VEHICULO V
LEFT JOIN Costos_Mant CM ON V.cod_vehiculo = CM.cod_vehiculo
LEFT JOIN Costos_Comb CC ON V.cod_vehiculo = CC.cod_vehiculo
WHERE V.cod_empresa = @ID_Empresa_C4
ORDER BY Costo_Total_Operativo DESC;
GO


DECLARE @ID_Empresa_C5 INT = 2;

SELECT TOP 5
    C.nombre AS Conductor,
    C.licencia,
    COUNT(A.cod_alerta) AS Total_Infracciones,
    SUM(CASE WHEN A.tipo_evento = 'EXCESO_VELOCIDAD' THEN 1 ELSE 0 END) AS Vel_Excesiva,
    SUM(CASE WHEN A.tipo_evento = 'FRENADO_BRUSCO' THEN 1 ELSE 0 END) AS Frenados,
    MAX(A.fecha_hora) AS Ultima_Infraccion
FROM ALERTA_TELEMETRIA A
JOIN VIAJE V ON A.cod_vehiculo = V.cod_vehiculo 
    AND A.fecha_hora BETWEEN V.fec_salida AND ISNULL(V.fec_llegada, GETDATE())
JOIN CONDUCTOR C ON V.cod_conductor = C.cod_conductor
WHERE C.cod_empresa = @ID_Empresa_C5 -- Filtro de seguridad: Solo mis conductores
GROUP BY C.nombre, C.licencia
HAVING COUNT(A.cod_alerta) > 0
ORDER BY Total_Infracciones DESC;
GO


DECLARE @ID_Empresa_C6 INT = 2;

WITH UltimaPosicion AS (
    SELECT 
        D.cod_vehiculo, T.latitud, T.longitud, T.velocidad_actual, T.fecha_hora_exacta,
        ROW_NUMBER() OVER (PARTITION BY D.cod_vehiculo ORDER BY T.fecha_hora_exacta DESC) as rn
    FROM TELEMETRIA T
    INNER JOIN DISP_IOT D ON T.cod_dispositivo = D.cod_dispositivo
    INNER JOIN VEHICULO V ON D.cod_vehiculo = V.cod_vehiculo
    WHERE V.cod_empresa = @ID_Empresa_C6 -- Optimización: Filtramos antes
)
SELECT 
    V.placa, 
    V.modelo,
    UP.latitud, 
    UP.longitud,
    UP.velocidad_actual AS Vel_Actual,
    UP.fecha_hora_exacta AS Ultimo_Reporte,
    CASE 
        WHEN UP.velocidad_actual > 90 THEN 'ALERTA' 
        WHEN UP.velocidad_actual = 0 THEN 'DETENIDO'
        ELSE 'EN MOVIMIENTO' 
    END AS Estado
FROM VIAJE Vi
JOIN VEHICULO V ON Vi.cod_vehiculo = V.cod_vehiculo
JOIN UltimaPosicion UP ON V.cod_vehiculo = UP.cod_vehiculo
WHERE Vi.estado_viaje = 'EN_RUTA' 
AND V.cod_empresa = @ID_Empresa_C6
AND UP.rn = 1;
GO