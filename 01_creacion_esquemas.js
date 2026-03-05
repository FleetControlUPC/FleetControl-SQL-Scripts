// ==========================================
// 01_creacion_esquemas.js
// Creación de colecciones con validación BSON Schema
// ==========================================

// 1. Creación de la colección Telemetria_IoT
db.createCollection("Telemetria_IoT", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["cod_vehiculo", "cod_empresa", "fecha_hora", "ubicacion"],
      properties: {
        cod_vehiculo: {
          bsonType: "int",
          description: "Referencia al vehículo en BD Relacional - Obligatorio"
        },
        cod_empresa: {
          bsonType: "int",
          description: "Referencia a la empresa cliente - Obligatorio"
        },
        fecha_hora: {
          bsonType: "date",
          description: "Fecha y hora exacta de la lectura"
        },
        ubicacion: {
          bsonType: "object",
          required: ["latitud", "longitud"],
          properties: {
            latitud: { bsonType: "double" },
            longitud: { bsonType: "double" }
          }
        },
        datos_motor: {
          bsonType: "object",
          properties: {
            velocidad_actual: { bsonType: "double", minimum: 0 },
            rpm_motor: { bsonType: "int", minimum: 0 },
            nivel_combustible: { bsonType: "double", minimum: 0, maximum: 100 },
            estado_ignicion: { bsonType: "bool" }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 2. Creación de la colección Alertas_Operativas
db.createCollection("Alertas_Operativas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["cod_vehiculo", "fecha_hora", "tipo_alerta", "nivel_gravedad"],
      properties: {
        cod_vehiculo: { bsonType: "int" },
        fecha_hora: { bsonType: "date" },
        tipo_alerta: {
          bsonType: "string",
          enum: ["EXCESO VELOCIDAD", "FRENADO BRUSCO", "RALENTI PROLONGADO", "FUGA COMBUSTIBLE"]
        },
        nivel_gravedad: {
          bsonType: "string",
          enum: ["BAJA", "MEDIA", "ALTA", "CRITICA"]
        },
        valor_detectado: { bsonType: ["double", "int", "string"] }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});