USE FleetControl;
GO

-- Consulta 1

SELECT
    s.cod_sede,
    s.nombre AS nombre_sede,
    v.cod_vehiculo,
    v.marca,
    v.modelo,
    COUNT(vj.cod_viaje) AS total_viajes,
    SUM(vj.km_recorridos) AS total_km_recorridos,
    AVG(DATEDIFF(HOUR, vj.fec_salida, vj.fec_llegada)) AS promedio_horas_uso,
    RANK() OVER
    (
        PARTITION BY s.cod_sede
        ORDER BY SUM(vj.km_recorridos) DESC
    ) AS ranking_vehiculo_sede
FROM SEDE s
INNER JOIN VEHICULO v
    ON s.cod_sede = v.cod_sede
LEFT JOIN VIAJE vj
    ON v.cod_vehiculo = vj.cod_vehiculo
GROUP BY
    s.cod_sede,
    s.nombre,
    v.cod_vehiculo,
    v.marca,
    v.modelo;

-- Consulta 2

WITH CostoMantenimiento AS (
    SELECT 
        v.cod_empresa, 
        SUM(m.costo) AS total_mant
    FROM VEHICULO v
    JOIN MANTENIMIENTO m ON v.cod_vehiculo = m.cod_vehiculo
    GROUP BY v.cod_empresa
),
CostoCombustible AS (
    SELECT 
        v.cod_empresa, 
        SUM(cc.costo) AS total_comb
    FROM VEHICULO v
    JOIN VIAJE vj ON v.cod_vehiculo = vj.cod_vehiculo
    JOIN CARGA_COMBUSTIBLE cc ON vj.cod_viaje = cc.cod_viaje
    GROUP BY v.cod_empresa
)
SELECT 
    e.cod_empresa,
    e.razon_social,
    ISNULL(cm.total_mant, 0) AS total_mantenimiento,
    ISNULL(cc.total_comb, 0) AS total_combustible,
    (ISNULL(cm.total_mant, 0) + ISNULL(cc.total_comb, 0)) AS gasto_total,
    RANK() OVER (
        ORDER BY (ISNULL(cm.total_mant, 0) + ISNULL(cc.total_comb, 0)) DESC
    ) AS ranking_gasto_empresa
FROM EMPRESA_CLIENTE e
LEFT JOIN CostoMantenimiento cm ON e.cod_empresa = cm.cod_empresa
LEFT JOIN CostoCombustible cc ON e.cod_empresa = cc.cod_empresa;

-- Consulta 3

SELECT
    v.cod_vehiculo,
    v.marca,
    v.modelo,
    COUNT(vj.cod_viaje) AS total_viajes,
    COUNT(vj.cod_viaje) * 100.0 / SUM(COUNT(vj.cod_viaje)) OVER () AS porcentaje_uso,
    DENSE_RANK() OVER
    (
        ORDER BY COUNT(vj.cod_viaje) DESC
    ) AS ranking_utilizacion
FROM VEHICULO v
LEFT JOIN VIAJE vj
    ON v.cod_vehiculo = vj.cod_vehiculo
GROUP BY
    v.cod_vehiculo,
    v.marca,
    v.modelo;
