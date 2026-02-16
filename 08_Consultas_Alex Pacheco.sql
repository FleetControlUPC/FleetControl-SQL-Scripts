USE FleetControl;
GO

-- Consulta 7
  
SELECT
YEAR(vj.fec_salida) AS anio,
MONTH(vj.fec_salida) AS mes,
COUNT(DISTINCT vj.cod_viaje) AS total_viajes,
SUM(ISNULL(cc.costo,0)) AS total_combustible,
SUM(ISNULL(m.costo,0)) AS total_mantenimiento,
SUM(ISNULL(cc.costo,0)) + SUM(ISNULL(m.costo,0)) 
AS gasto_total_mensual,
RANK() OVER
(
    ORDER BY 
    SUM(ISNULL(cc.costo,0)) + SUM(ISNULL(m.costo,0)) DESC
) AS ranking_mes_gasto
FROM VIAJE vj
LEFT JOIN CARGA_COMBUSTIBLE cc
ON vj.cod_viaje = cc.cod_viaje
LEFT JOIN VEHICULO v
ON vj.cod_vehiculo = v.cod_vehiculo
LEFT JOIN MANTENIMIENTO m
ON v.cod_vehiculo = m.cod_vehiculo
AND YEAR(m.fecha) = YEAR(vj.fec_salida)
AND MONTH(m.fecha) = MONTH(vj.fec_salida)
GROUP BY
YEAR(vj.fec_salida),
MONTH(vj.fec_salida);

-- Consulta 8

SELECT
c.cod_conductor,
c.nombre AS nombre_conductor,
COUNT(DISTINCT vj.cod_viaje) AS total_viajes,
SUM(ISNULL(cc.costo,0)) AS gasto_combustible,
SUM(ISNULL(m.costo,0)) AS gasto_mantenimiento,
SUM(ISNULL(cc.costo,0)) + SUM(ISNULL(m.costo,0))
AS gasto_total_generado,
RANK() OVER
(
    ORDER BY 
    SUM(ISNULL(cc.costo,0)) + SUM(ISNULL(m.costo,0)) DESC
) AS ranking_gasto_conductor
FROM CONDUCTOR c
LEFT JOIN VIAJE vj
ON c.cod_conductor = vj.cod_conductor
LEFT JOIN CARGA_COMBUSTIBLE cc
ON vj.cod_viaje = cc.cod_viaje
LEFT JOIN VEHICULO v
ON vj.cod_vehiculo = v.cod_vehiculo
LEFT JOIN MANTENIMIENTO m
ON v.cod_vehiculo = m.cod_vehiculo
GROUP BY
c.cod_conductor,
c.nombre;

-- Consulta 9

SELECT
c.cod_conductor,
c.nombre,
COUNT(DISTINCT vj.cod_viaje) AS total_viajes,
SUM(ISNULL(cc.costo,0)) + 
SUM(ISNULL(m.costo,0)) AS gasto_total,
CASE
    WHEN SUM(ISNULL(cc.costo,0)) + SUM(ISNULL(m.costo,0)) >= 5000 
        THEN 'Conductor Alto Impacto'
    WHEN SUM(ISNULL(cc.costo,0)) + SUM(ISNULL(m.costo,0)) >= 2000 
        THEN 'Conductor Impacto Medio'
    ELSE 'Conductor Impacto Bajo'
END AS categoria_conductor
FROM CONDUCTOR c
LEFT JOIN VIAJE vj
ON c.cod_conductor = vj.cod_conductor
LEFT JOIN CARGA_COMBUSTIBLE cc
ON vj.cod_viaje = cc.cod_viaje
LEFT JOIN VEHICULO v
ON vj.cod_vehiculo = v.cod_vehiculo
LEFT JOIN MANTENIMIENTO m
ON v.cod_vehiculo = m.cod_vehiculo
GROUP BY
c.cod_conductor,
c.nombre;
