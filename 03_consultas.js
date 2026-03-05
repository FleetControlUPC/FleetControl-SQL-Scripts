// ==========================================
// CONSULTA 1: Promedio de velocidad por empresa
// ==========================================
db.Telemetria_IoT.aggregate([
  {
    $group: {
      _id: "$cod_empresa",
      velocidad_promedio: { $avg: "$datos_motor.velocidad_actual" }
    }
  },
  {
    $sort: { velocidad_promedio: -1 }
  }
]);

// ==========================================
// CONSULTA 2: Vehículos con más alertas de fuga de combustible
// ==========================================
db.Alertas_Operativas.aggregate([
  {
    $match: {
      tipo_alerta: "FUGA COMBUSTIBLE"
    }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      total_fugas: { $sum: 1 }
    }
  },
  {
    $sort: { total_fugas: -1 }
  }
]);

// ==========================================
// CONSULTA 3: Control de desgaste de motor y ralentí innecesario
// ==========================================
let idEmpresaRalenti = NumberInt(1);

db.Telemetria_IoT.aggregate([
  {
    $match: {
      cod_empresa: idEmpresaRalenti,
      "datos_motor.velocidad_actual": 0,
      "datos_motor.estado_ignicion": true
    }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      minutos_estimados_ralenti: { $sum: 1 },
      promedio_rpm_desperdiciado: { $avg: "$datos_motor.rpm_motor" },
      combustible_promedio_retenido: { $avg: "$datos_motor.nivel_combustible" }
    }
  },
  {
    $sort: { minutos_estimados_ralenti: -1 }
  },
  {
    $limit: 5
  }
]);

// ==========================================
// CONSULTA 4: Perfil de conducción temeraria mediante telemetría
// ==========================================
let idEmpresaTemeraria = NumberInt(2);
let limiteVelocidad = 80.0;

db.Telemetria_IoT.aggregate([
  {
    $match: {
      cod_empresa: idEmpresaTemeraria,
      "datos_motor.velocidad_actual": { $gt: limiteVelocidad }
    }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      lecturas_exceso_velocidad: { $sum: 1 },
      velocidad_pico_registrada: { $max: "$datos_motor.velocidad_actual" },
      rpm_promedio_en_exceso: { $avg: "$datos_motor.rpm_motor" }
    }
  },
  {
    $sort: { velocidad_pico_registrada: -1 }
  }
]);

// ==========================================
// CONSULTA 5: Nivel promedio y mínimo de combustible por vehículo
// ==========================================
db.Telemetria_IoT.aggregate([
  {
    $group: {
      _id: "$cod_vehiculo",
      combustible_promedio: { $avg: "$datos_motor.nivel_combustible" },
      minimo_combustible: { $min: "$datos_motor.nivel_combustible" }
    }
  },
  {
    $sort: { combustible_promedio: 1 }
  }
]);

// ==========================================
// CONSULTA 6: Última alerta registrada por vehículo
// ==========================================
db.Alertas_Operativas.aggregate([
  {
    $sort: { cod_vehiculo: 1, fecha_hora: -1 }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      ultima_fecha_alerta: { $first: "$fecha_hora" },
      tipo_alerta: { $first: "$tipo_alerta" },
      nivel_gravedad: { $first: "$nivel_gravedad" }
    }
  },
  {
    $sort: { ultima_fecha_alerta: -1 }
  }
]);

// ==========================================
// CONSULTA 7: Última lectura de telemetría por vehículo para el mapa del cliente
// ==========================================
let idEmpresaMapa = NumberInt(1);

db.Telemetria_IoT.aggregate([
  {
    $match: { cod_empresa: idEmpresaMapa }
  },
  {
    $sort: { cod_vehiculo: 1, fecha_hora: -1 }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      ultima_fecha: { $first: "$fecha_hora" },
      ultima_latitud: { $first: "$ubicacion.latitud" },
      ultima_longitud: { $first: "$ubicacion.longitud" },
      velocidad_actual: { $first: "$datos_motor.velocidad_actual" },
      nivel_combustible: { $first: "$datos_motor.nivel_combustible" }
    }
  },
  {
    $project: {
      _id: 0,
      cod_vehiculo: "$_id",
      ultima_fecha: 1,
      ultima_latitud: 1,
      ultima_longitud: 1,
      velocidad_actual: 1,
      nivel_combustible: 1
    }
  },
  {
    $sort: { ultima_fecha: -1 }
  }
]);

// ==========================================
// CONSULTA 8: Ranking por tipo de alerta y gravedad en los últimos 7 días
// ==========================================
let fechaInicio = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

db.Alertas_Operativas.aggregate([
  {
    $match: {
      fecha_hora: { $gte: fechaInicio }
    }
  },
  {
    $group: {
      _id: { tipo: "$tipo_alerta", gravedad: "$nivel_gravedad" },
      total: { $sum: 1 },
      ultima_alerta: { $max: "$fecha_hora" }
    }
  },
  {
    $sort: { total: -1 }
  }
]);

// ==========================================
// CONSULTA 9: Identificación de vehículos con mayor incidencia de frenados bruscos críticos
// ==========================================
db.Alertas_Operativas.aggregate([
  {
    $match: {
      tipo_alerta: "FRENADO BRUSCO",
      nivel_gravedad: { $in: ["ALTA", "CRITICA"] }
    }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      total_incidentes_graves: { $sum: 1 },
      fecha_ultimo_evento: { $max: "$fecha_hora" }
    }
  },
  {
    $sort: { total_incidentes_graves: -1 }
  },
  {
    $limit: 10
  }
]);

// ==========================================
// CONSULTA 10: Análisis de estrés mecánico por altas revoluciones y baja velocidad
// ==========================================
let idEmpresaEstres = NumberInt(1);
let rpmUmbral = 3500;
let velocidadBaja = 20.0;

db.Telemetria_IoT.aggregate([
  {
    $match: {
      cod_empresa: idEmpresaEstres,
      "datos_motor.rpm_motor": { $gt: rpmUmbral },
      "datos_motor.velocidad_actual": { $lt: velocidadBaja },
      "datos_motor.estado_ignicion": true
    }
  },
  {
    $group: {
      _id: "$cod_vehiculo",
      eventos_estres_mecanico: { $sum: 1 },
      max_rpm_registrado: { $max: "$datos_motor.rpm_motor" },
      nivel_promedio_combustible: { $avg: "$datos_motor.nivel_combustible" }
    }
  },
  {
    $sort: { eventos_estres_mecanico: -1 }
  }
]);