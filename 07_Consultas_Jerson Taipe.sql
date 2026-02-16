USE FleetControl;
GO

-- Consulta 13
DECLARE @FechaConsulta DATE = '2026-02-16'; -- Fecha actual o de cierre
DECLARE @ID_Empresa INT = 1;

SELECT 
    V.placa,
    V.modelo,
    COUNT(Vi.cod_viaje) AS Total_Viajes_Dia,
    SUM(Vi.km_recorridos) AS Km_Totales_Dia
FROM VEHICULO V
JOIN VIAJE Vi ON V.cod_vehiculo = Vi.cod_vehiculo
WHERE V.cod_empresa = @ID_Empresa 
  AND CAST(Vi.fec_salida AS DATE) = @FechaConsulta
GROUP BY V.placa, V.modelo;
GO

-- Consulta 14
DECLARE @ID_Empresa INT = 1;

WITH UltimoCombustible AS (
    SELECT 
        D.cod_vehiculo, T.nivel_combustible,
        ROW_NUMBER() OVER (PARTITION BY D.cod_vehiculo ORDER BY T.fecha_hora_exacta DESC) as rn
    FROM TELEMETRIA T
    JOIN DISP_IOT D ON T.cod_dispositivo = D.cod_dispositivo
)
SELECT 
    V.placa,
    V.modelo,
    UC.nivel_combustible AS Porcentaje_Actual
FROM VEHICULO V
JOIN UltimoCombustible UC ON V.cod_vehiculo = UC.cod_vehiculo
WHERE V.cod_empresa = @ID_Empresa 
  AND UC.rn = 1 
  AND UC.nivel_combustible < 15.00 -- Umbral de alerta (15%)
ORDER BY UC.nivel_combustible ASC;
GO

-- Consulta 15
DECLARE @ID_Empresa INT = 1;

SELECT 
    V.placa,
    V.modelo,
    SUM(Vi.km_recorridos) AS Total_Km,
    SUM(CC.galones) AS Total_Galones,
    ROUND(SUM(Vi.km_recorridos) / NULLIF(SUM(CC.galones), 0), 2) AS Rendimiento_Km_Galon
FROM VEHICULO V
JOIN VIAJE Vi ON V.cod_vehiculo = Vi.cod_vehiculo
JOIN CARGA_COMBUSTIBLE CC ON Vi.cod_viaje = CC.cod_viaje
WHERE V.cod_empresa = @ID_Empresa
GROUP BY V.placa, V.modelo
ORDER BY Rendimiento_Km_Galon DESC;
GO
