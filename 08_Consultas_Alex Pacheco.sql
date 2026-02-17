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

WITH ResumenViajes AS (
    SELECT cod_conductor, COUNT(cod_viaje) AS total_viajes
    FROM VIAJE
    GROUP BY cod_conductor
),
GastoCombustible AS (
    SELECT 
        vj.cod_conductor, 
        SUM(cc.costo) AS total_comb
    FROM VIAJE vj
    JOIN CARGA_COMBUSTIBLE cc ON vj.cod_viaje = cc.cod_viaje
    GROUP BY vj.cod_conductor
),
GastoMantenimiento AS (
    SELECT 
        vj.cod_conductor, 
        SUM(m.costo) AS total_mant
    FROM VIAJE vj
    JOIN VEHICULO v ON vj.cod_vehiculo = v.cod_vehiculo
    JOIN MANTENIMIENTO m ON v.cod_vehiculo = m.cod_vehiculo
    GROUP BY vj.cod_conductor
)
SELECT
    c.cod_conductor,
    c.nombre AS nombre_conductor,
    ISNULL(rv.total_viajes, 0) AS total_viajes,
    ISNULL(gc.total_comb, 0) AS gasto_combustible,
    ISNULL(gm.total_mant, 0) AS gasto_mantenimiento,
    (ISNULL(gc.total_comb, 0) + ISNULL(gm.total_mant, 0)) AS gasto_total_generado,
    RANK() OVER (
        ORDER BY (ISNULL(gc.total_comb, 0) + ISNULL(gm.total_mant, 0)) DESC
    ) AS ranking_gasto_conductor
FROM CONDUCTOR c
LEFT JOIN ResumenViajes rv ON c.cod_conductor = rv.cod_conductor
LEFT JOIN GastoCombustible gc ON c.cod_conductor = gc.cod_conductor
LEFT JOIN GastoMantenimiento gm ON c.cod_conductor = gm.cod_conductor;

-- Consulta 9

WITH GastoCombustible AS (
    SELECT 
        vj.cod_conductor, 
        SUM(cc.costo) AS total_comb
    FROM VIAJE vj
    JOIN CARGA_COMBUSTIBLE cc ON vj.cod_viaje = cc.cod_viaje
    GROUP BY vj.cod_conductor
),
GastoMantenimiento AS (
    SELECT 
        vj.cod_conductor, 
        SUM(m.costo) AS total_mant
    FROM VIAJE vj
    JOIN VEHICULO v ON vj.cod_vehiculo = v.cod_vehiculo
    JOIN MANTENIMIENTO m ON v.cod_vehiculo = m.cod_vehiculo
    GROUP BY vj.cod_conductor
),
ResumenFinal AS (
    SELECT
        c.cod_conductor,
        c.nombre,
        (SELECT COUNT(*) FROM VIAJE WHERE cod_conductor = c.cod_conductor) AS total_viajes,
        (ISNULL(gc.total_comb, 0) + ISNULL(gm.total_mant, 0)) AS gasto_total
    FROM CONDUCTOR c
    LEFT JOIN GastoCombustible gc ON c.cod_conductor = gc.cod_conductor
    LEFT JOIN GastoMantenimiento gm ON c.cod_conductor = gm.cod_conductor
)
SELECT
    cod_conductor,
    nombre,
    total_viajes,
    gasto_total,
    CASE
        WHEN gasto_total >= 5000 THEN 'Conductor Alto Impacto'
        WHEN gasto_total >= 2000 THEN 'Conductor Impacto Medio'
        ELSE 'Conductor Impacto Bajo'
    END AS categoria_conductor
FROM ResumenFinal;
