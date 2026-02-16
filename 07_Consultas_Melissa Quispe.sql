USE FleetControl_DB;
GO

-- Consulta 10
DECLARE @ID_Empresa INT = 1;

SELECT
    V.placa,
    V.modelo,
    MAX(M.fecha) AS Ultimo_Mantenimiento,
    DATEDIFF(DAY, MAX(M.fecha), GETDATE()) AS Dias_Desde_Ultimo_Mant,
    SUM(M.costo) AS Gasto_Mantenimiento
FROM VEHICULO V
LEFT JOIN MANTENIMIENTO M
    ON M.cod_vehiculo = V.cod_vehiculo
WHERE V.cod_empresa = @ID_Empresa
GROUP BY V.placa, V.modelo
ORDER BY Dias_Desde_Ultimo_Mant DESC;
GO


-- Consulta 11
DECLARE @ID_Empresa INT = 1;
DECLARE @MinCostoPorKm DECIMAL(10,2) = 2.50;

SELECT
    V.placa,
    Vi.cod_viaje,
    Vi.fec_salida,
    Vi.km_recorridos,
    SUM(CC.costo) AS Costo_Combustible,
    ROUND(SUM(CC.costo) / NULLIF(Vi.km_recorridos, 0), 2) AS Costo_Por_Km
FROM VIAJE Vi
JOIN VEHICULO V ON V.cod_vehiculo = Vi.cod_vehiculo
JOIN CARGA_COMBUSTIBLE CC ON CC.cod_viaje = Vi.cod_viaje
WHERE V.cod_empresa = @ID_Empresa
GROUP BY V.placa, Vi.cod_viaje, Vi.fec_salida, Vi.km_recorridos
HAVING (SUM(CC.costo) / NULLIF(Vi.km_recorridos, 0)) >= @MinCostoPorKm
ORDER BY Costo_Por_Km DESC;
GO


-- Consulta 12
DECLARE @ID_Empresa INT = 1;
DECLARE @UltimosDias INT = 30;

SELECT TOP 10
    V.placa,
    C.nombre AS Conductor,
    I.tipo AS Tipo_Incidencia,
    I.fecha AS Fecha_Incidencia,
    I.descripcion
FROM INCIDENCIA I
JOIN VIAJE Vi ON Vi.cod_viaje = I.cod_viaje
JOIN VEHICULO V ON V.cod_vehiculo = Vi.cod_vehiculo
JOIN CONDUCTOR C ON C.cod_conductor = Vi.cod_conductor
WHERE V.cod_empresa = @ID_Empresa
  AND I.fecha >= DATEADD(DAY, -@UltimosDias, GETDATE())
ORDER BY I.fecha DESC;
GO
