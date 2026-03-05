// ==========================================
// 02_carga_masiva.js
// Poblado de datos de prueba para las colecciones
// ==========================================

// 1. Poblado masivo de Telemetria_IoT (3000 registros simulados)
let bulkTelemetria = [];

for (let i = 1; i <= 3000; i++) {
  let v = Math.floor(Math.random() * 20) + 1;
  let e = Math.floor((v - 1) / 2) + 1;
  
  // Forzar el 20% de datos en ralentí (Velocidad 0 y Motor Encendido)
  let esRalenti = Math.random() < 0.20;
  let vel = esRalenti ? 0.0 : parseFloat((Math.random() * 120).toFixed(2));
  let ignicion = esRalenti ? true : Math.random() > 0.3;
  let rpm = esRalenti ? Math.floor(Math.random() * (1000 - 600) + 600) : Math.floor(Math.random() * 5000);
  
  let lat = parseFloat((-12.0464 + (Math.random() * 0.05)).toFixed(6));
  let lon = parseFloat((-77.0428 + (Math.random() * 0.05)).toFixed(6));
  let comb = parseFloat((Math.random() * 100).toFixed(2));

  bulkTelemetria.push({
    cod_vehiculo: NumberInt(v),
    cod_empresa: NumberInt(e),
    fecha_hora: new Date(Date.now() - Math.random() * 100000000),
    ubicacion: {
      latitud: Double(lat),
      longitud: Double(lon)
    },
    datos_motor: {
      velocidad_actual: Double(vel),
      rpm_motor: NumberInt(rpm),
      nivel_combustible: Double(comb),
      estado_ignicion: ignicion
    }
  });
}

db.Telemetria_IoT.insertMany(bulkTelemetria);

// 2. Poblado masivo de Alertas_Operativas (200 registros simulados)
let tipos = ["EXCESO VELOCIDAD", "FRENADO BRUSCO", "RALENTI PROLONGADO", "FUGA COMBUSTIBLE"];
let niveles = ["BAJA", "MEDIA", "ALTA", "CRITICA"];
let bulkAlertas = [];

for (let i = 1; i <= 200; i++) {
  let tipoRandom = tipos[Math.floor(Math.random() * tipos.length)];
  let nivelRandom = niveles[Math.floor(Math.random() * niveles.length)];
  let valor;

  if (tipoRandom === "EXCESO VELOCIDAD") {
    let num = parseFloat((80 + Math.random() * 40).toFixed(2));
    valor = Double(num);
  } else if (tipoRandom === "FUGA COMBUSTIBLE") {
    let num = parseFloat((5 + Math.random() * 20).toFixed(2));
    valor = Double(num);
  } else if (tipoRandom === "FRENADO BRUSCO") {
    let num = parseFloat((20 + Math.random() * 30).toFixed(2));
    valor = Double(num);
  } else {
    valor = "Evento detectado";
  }

  bulkAlertas.push({
    cod_vehiculo: NumberInt(Math.floor(Math.random() * 20) + 1),
    fecha_hora: new Date(Date.now() - Math.random() * 100000000),
    tipo_alerta: tipoRandom,
    nivel_gravedad: nivelRandom,
    valor_detectado: valor
  });
}

db.Alertas_Operativas.insertMany(bulkAlertas);