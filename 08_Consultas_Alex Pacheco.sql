USE FleetControl;
GO

-- Consulta 7
  
SELECT
    YEAR(i.fecha) AS anio,
    MONTH(i.fecha) AS mes,
    v.cod_vehiculo,
    v.placa,
    v.marca,
    v.modelo,
    COUNT(DISTINCT i.cod_inspeccion) AS total_inspecciones,
    COUNT(DISTINCT vj.cod_viaje) AS total_viajes,
    SUM(CASE 
            WHEN i.resultado_global = 'APROBADO' 
            THEN 1 ELSE 0 
        END) AS inspecciones_aprobadas,
    SUM(CASE 
            WHEN i.resultado_global <> 'APROBADO' 
            THEN 1 ELSE 0 
        END) AS inspecciones_observadas,
    RANK() OVER
    (
        PARTITION BY YEAR(i.fecha), MONTH(i.fecha)
        ORDER BY COUNT(DISTINCT i.cod_inspeccion) DESC
    ) AS ranking_inspecciones_mes
FROM INSPECCION_DIARIA i
INNER JOIN VIAJE vj
    ON i.cod_viaje = vj.cod_viaje
INNER JOIN VEHICULO v
    ON vj.cod_vehiculo = v.cod_vehiculo
GROUP BY
    YEAR(i.fecha),
    MONTH(i.fecha),
    v.cod_vehiculo,
    v.placa,
    v.marca,
    v.modelo
ORDER BY
    anio DESC,
    mes DESC,
    total_inspecciones DESC;


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
