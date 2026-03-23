import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/textos.dart';

class ContactoModelo {
    int? id;
    String? nombreCompleto;
    double latitud;
    double longitud;
    String? domicilio;
    DateTime? fechaDomicilio;
    int? numero;
    DateTime? numeroFecha;
    int? otroNumero;
    DateTime? otroNumeroFecha;
    DateTime? agendar;
    int? tipo;
    DateTime? tipoFecha;
    int? estado;
    DateTime? estadoFecha;
    String? foto;
    DateTime? fotoFecha;
    String? fotoReferencia;
    DateTime? fotoReferenciaFecha;
    String? what3Words;
    String? nota;
    String? empleadoId;
    String? empleadoFoto;
    String? empleadoFotoReferencia;
    String? empleadoDomicilio;
    String? empleadoNumero;
    String? empleadoOtroNumero;
    String? empleadoTipo;
    String? empleadoEstado;
    int? status;
    int? pendiente;
    String? aceptadoEmpleado;
    DateTime? creado;
    DateTime? modificado;

    ContactoModelo(
        {this.id,
        required this.nombreCompleto,
        required this.latitud,
        required this.longitud,
        required this.domicilio,
        required this.fechaDomicilio,
        required this.numero,
        required this.numeroFecha,
        required this.otroNumero,
        required this.otroNumeroFecha,
        required this.agendar,
        required this.tipo,
        required this.tipoFecha,
        required this.estado,
        required this.estadoFecha,
        required this.foto,
        required this.fotoFecha,
        required this.fotoReferencia,
        required this.fotoReferenciaFecha,
        required this.what3Words,
        required this.nota,
        this.pendiente,
        this.aceptadoEmpleado,
        this.empleadoId,
        this.empleadoFoto,
        this.empleadoFotoReferencia,
        this.empleadoDomicilio,
        this.empleadoNumero,
        this.empleadoOtroNumero,
        this.empleadoTipo,
        this.empleadoEstado,
        this.status,
        this.creado,
        this.modificado});

    ContactoModelo copyWith(
    {int? id,
    String? nombreCompleto,
    double? latitud,
    double? longitud,
    String? domicilio,
    DateTime? fechaDomicilio,
    int? numero,
    DateTime? numeroFecha,
    int? otroNumero,
    DateTime? otroNumeroFecha,
    DateTime? agendar,
    int? tipo,
    DateTime? tipoFecha,
    int? estado,
    DateTime? estadoFecha,
    String? foto,
    DateTime? fotoFecha,
    String? fotoReferencia,
    DateTime? fotoReferenciaFecha,
    String? what3Words,
    String? nota,
    int? pendiente,
    String? aceptadoEmpleado,
    String? empleadoId,
    String? empleadoFoto,
    String? empleadoFotoReferencia,
    String? empleadoDomicilio,
    String? empleadoNumero,
    String? empleadoOtroNumero,
    String? empleadoTipo,
    String? empleadoEstado,
    int? status,
    DateTime? creado,
    DateTime? modificado}) =>
ContactoModelo(
    id: id ?? this.id,
    nombreCompleto: nombreCompleto ?? this.nombreCompleto,
    latitud: latitud ?? this.latitud,
    longitud: longitud ?? this.longitud,
    domicilio: domicilio ?? this.domicilio,
    fechaDomicilio: fechaDomicilio ?? this.fechaDomicilio,
    numero: numero ?? this.numero,
    numeroFecha: numeroFecha ?? this.numeroFecha,
    otroNumero: otroNumero ?? this.otroNumero,
    otroNumeroFecha: otroNumeroFecha ?? this.otroNumeroFecha,
    agendar: agendar,
    tipo: tipo ?? this.tipo,
    tipoFecha: tipoFecha ?? this.tipoFecha,
    estado: estado ?? this.estado,
    estadoFecha: estadoFecha ?? this.estadoFecha,
    foto: foto ?? this.foto,
    empleadoFoto: empleadoFoto ?? this.empleadoFoto,
    fotoFecha: fotoFecha ?? this.fotoFecha,
    empleadoFotoReferencia:
        empleadoFotoReferencia ?? this.empleadoFotoReferencia,
    empleadoDomicilio: empleadoDomicilio ?? this.empleadoDomicilio,
    empleadoNumero: empleadoNumero ?? this.empleadoNumero,
    empleadoOtroNumero: empleadoOtroNumero ?? this.empleadoOtroNumero,
    empleadoTipo: empleadoTipo ?? this.empleadoTipo,
    empleadoEstado: empleadoEstado ?? this.empleadoEstado,
    fotoReferencia: fotoReferencia ?? this.fotoReferencia,
    fotoReferenciaFecha: fotoReferenciaFecha ?? this.fotoReferenciaFecha,
    what3Words: what3Words ?? this.what3Words,
    nota: nota ?? this.nota,
    pendiente: pendiente ?? this.pendiente,
    aceptadoEmpleado: aceptadoEmpleado ?? this.aceptadoEmpleado,
    empleadoId: empleadoId ?? this.empleadoId,
    status: status ?? this.status,
    creado: creado ?? this.creado,
    modificado: modificado ?? this.modificado);

  factory ContactoModelo.fromJson(Map<String, dynamic> json) => ContactoModelo(
    id: json["id"],
    nombreCompleto: json["nombre_completo"],
    latitud: double.parse(
        double.parse(json["latitud"].toString()).toStringAsFixed(6)),
    longitud: double.parse(
        double.parse(json["longitud"].toString()).toStringAsFixed(6)),
    domicilio: json["domicilio"],
    fechaDomicilio: Textos.parseoDateFire(json["fecha_domicilio"]),
    numero: Parser.toInt(json["numero"]),
    numeroFecha: Textos.parseoDateFire(json["numero_fecha"]),
    otroNumero: Parser.toInt(json["otro_numero"]),
    otroNumeroFecha: Textos.parseoDateFire(json["otro_numero_fecha"]),
    agendar: Textos.parseoDateFire(json["agendar"]),
    tipo: json["tipo"],
    tipoFecha: Textos.parseoDateFire(json["tipo_fecha"]),
    estado: json["estado"],
    estadoFecha: Textos.parseoDateFire(json["estado_fecha"]),
    foto: json["foto"],
    empleadoFoto: json["empleado_foto"]?.toString(),
    fotoFecha: Textos.parseoDateFire(json["foto_fecha"]),
    fotoReferencia: json["foto_referencia"],
    empleadoFotoReferencia: json["empleado_foto_referencia"]?.toString(),
    fotoReferenciaFecha:
        Textos.parseoDateFire(json["foto_referencia_fecha"]),
    empleadoDomicilio: json["empleado_domicilio"]?.toString(),
    empleadoNumero: json["empleado_numero"]?.toString(),
    empleadoOtroNumero: json["empleado_otro_num"]?.toString(),
    empleadoTipo: json["empleado_tipo"]?.toString(),
    empleadoEstado: json["empleado_estado"]?.toString(),
    what3Words: json["what_3_words"],
    nota: json["nota"],
    pendiente: Parser.toInt(json["pendiente"]),
    aceptadoEmpleado: json["aceptado_empleado"]?.toString(),
    empleadoId: json["empleado_id"]?.toString(),
    status: Parser.toInt(json["status"]) ?? 1,
    creado: Textos.parseoDateFire(json["creado"]),
    modificado: Textos.parseoDateFire(json["modificado"] ?? DateTime.now()));

    Map<String, dynamic> toFirestore() => {
    "id": id,
    "nombre_completo": nombreCompleto,
    "latitud": latitud,
    "longitud": longitud,
    "domicilio": domicilio,
    "fecha_domicilio": fechaDomicilio == null
        ? null
        : Timestamp.fromDate(fechaDomicilio!),
    "numero": numero,
    "numero_fecha": numeroFecha == null
        ? null
        : Timestamp.fromDate(numeroFecha!),
    "otro_numero": otroNumero,
    "otro_numero_fecha": otroNumeroFecha == null
        ? null
        : Timestamp.fromDate(otroNumeroFecha!),
    "agendar": agendar == null ? null : Timestamp.fromDate(agendar!),
    "tipo": tipo,
    "tipo_fecha":
        tipoFecha == null ? null : Timestamp.fromDate(tipoFecha!),
    "estado": estado,
    "estado_fecha": estadoFecha == null
        ? null
        : Timestamp.fromDate(estadoFecha!),
    "foto": foto,
    "foto_fecha":
        fotoFecha == null ? null : Timestamp.fromDate(fotoFecha!),
    "foto_referencia": fotoReferencia,
    "foto_referencia_fecha": fotoReferenciaFecha == null
        ? null
        : Timestamp.fromDate(fotoReferenciaFecha!),
    "empleado_foto": empleadoFoto,
    "empleado_foto_referencia": empleadoFotoReferencia,
    "empleado_domicilio": empleadoDomicilio,
    "empleado_numero": empleadoNumero,
    "empleado_otro_num": empleadoOtroNumero,
    "empleado_tipo": empleadoTipo,
    "empleado_estado": empleadoEstado,
    "what_3_words": what3Words,
    "nota": nota,
    "empleado_id": empleadoId,
    "status": status ?? 1,
    "pendiente": pendiente ?? 1,
    "aceptado_empleado": aceptadoEmpleado,
    "creado": creado == null ? null :   Timestamp.fromDate(creado!),
    "modificado": modificado == null ? null : Timestamp.fromDate(modificado!)
    };

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre_completo": nombreCompleto,
    "latitud": latitud,
    "longitud": longitud,
    "domicilio": domicilio,
    "fecha_domicilio": fechaDomicilio == null
        ? null
        : Textos.fechaYMDHMS(fecha: fechaDomicilio!),
    "numero": numero,
    "numero_fecha": numeroFecha == null
        ? null
        : Textos.fechaYMDHMS(fecha: numeroFecha!),
    "otro_numero": otroNumero,
    "otro_numero_fecha": otroNumeroFecha == null
        ? null
        : Textos.fechaYMDHMS(fecha: otroNumeroFecha!),
    "agendar": agendar == null ? null : Textos.fechaYMD(fecha: agendar!),
    "tipo": tipo,
    "tipo_fecha":
        tipoFecha == null ? null : Textos.fechaYMDHMS(fecha: tipoFecha!),
    "estado": estado,
    "estado_fecha": estadoFecha == null
        ? null
        : Textos.fechaYMDHMS(fecha: estadoFecha!),
    "foto": foto,
    "foto_fecha":
        fotoFecha == null ? null : Textos.fechaYMDHMS(fecha: fotoFecha!),
    "foto_referencia": fotoReferencia,
    "foto_referencia_fecha": fotoReferenciaFecha == null
        ? null
        : Textos.fechaYMDHMS(fecha: fotoReferenciaFecha!),
    "empleado_foto": empleadoFoto,
    "empleado_foto_referencia": empleadoFotoReferencia,
    "empleado_domicilio": empleadoDomicilio,
    "empleado_numero": empleadoNumero,
    "empleado_otro_num": empleadoOtroNumero,
    "empleado_tipo": empleadoTipo,
    "empleado_estado": empleadoEstado,
    "what_3_words": what3Words,
    "nota": nota,
    "empleado_id": empleadoId,
    "status": status ?? 1,
    "pendiente": pendiente ?? 1,
    "aceptado_empleado": aceptadoEmpleado,
    "creado": creado?.toIso8601String(),
    "modificado": modificado?.toIso8601String()
    };
}
