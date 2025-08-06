import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:oktoast/oktoast.dart';

class Excepcion {
  static void errorHttp({required int status}) {
    switch (status) {
      case 300:
        showToast(
            '$status Multiple eleccion\nEsta solicitud tiene más de una posible respuesta. User-Agent o el usuario debe escoger uno de ellos. No hay forma estandarizada de seleccionar una de las respuestas.');
        break;
      case 301:
        showToast(
            '$status Permanenmente movido\nEste código de respuesta significa que la URI del recurso solicitado ha sido cambiado. Probablemente una nueva URI sea devuelta en la respuesta.');
        break;
      case 302:
        showToast(
            '$status Encontrado\nla URI solicitada ha sido cambiado temporalmente');
        break;
      case 303:
        showToast(
            '$status Ver otros\nEl servidor envía esta respuesta para dirigir al cliente a un nuevo recurso solicitado a otra dirección usando una petición GET');
        break;
      case 304:
        showToast('$status No modificado\nLa respuesta no ha sido modificada');
        break;
      case 305:
        showToast(
            '$status Uso de proxy obsoleto\nLa respuesta solicitada debe ser accedida desde un proxy');
        break;
      case 306:
        showToast(
            '$status Sin uso\nEste código de respuesta ya no es usado más. Actualmente se encuentra reservado');
        break;
      case 307:
        showToast(
            '$status Redirección temporal\nEl recurso solicitado se encuentra en otra URI con el mismo método que se usó la petición anterior');
        break;
      case 308:
        showToast(
            '$status Redirección permanente\nEl recurso ahora se encuentra permanentemente en otra URI, especificada por la respuesta de encabezado HTTP Location');
        break;
      case 400:
        showToast(
            '$status Solicitud incorrecta\nEl servidor no pudo interpretar la solicitud dada una sintaxis inválida');
        break;
      case 401:
        showToast(
            '$status Sin autorizacion\nEs necesario autenticar para obtener la respuesta solicitada');
        break;
      case 402:
        showToast('$status Pago requerido\n');
        break;
      case 403:
        showToast(
            '$status Prohibido\nEl cliente no posee los permisos necesarios para cierto contenido, por lo que el servidor está rechazando otorgar una respuesta apropiada');
        break;
      case 404:
        showToast(
            '$status No encontrado\nEl servidor no pudo encontrar el contenido solicitado');
        break;
      case 405:
        showToast(
            '$status Metodo no permitido\nEl método solicitado es conocido por el servidor pero ha sido deshabilitado y no puede ser utilizado');
        break;
      case 406:
        showToast(
            '$status No aceptable\nNo encuentra ningún contenido seguido por la criteria dada por el usuario');
        break;
      case 407:
        showToast(
            '$status Autentificacion de proxy requerida\nLa autenticación debe estar hecha a partir de un proxy');
        break;
      case 408:
        showToast(
            '$status Solicitud fuera de tiempo\nEl servidor quiere desconectar esta conexión sin usar');
        break;
      case 409:
        showToast(
            '$status Conflicto\nUna petición tiene conflicto con el estado actual del servidor');
        break;
      case 410:
        showToast(
            '$status Desaparecido\nEl contenido solicitado ha sido borrado del servidor');
        break;
      case 411:
        showToast(
            '$status Tamaño requerido\nEl campo de encabezado Content-Length no esta definido y el servidor lo requiere');
        break;
      case 412:
        showToast(
            '$status Condición previa falló\nEl cliente ha indicado pre-condiciones en sus encabezados la cual el servidor no cumple');
        break;
      case 413:
        showToast(
            '$status Carga útil demasiado grande\nLa entidad de petición es más larga que los límites definidos por el servidor');
        break;
      case 414:
        showToast(
            '$status URL demasiado larga\nLa URI solicitada por el cliente es más larga de lo que el servidor está dispuesto a interpretar');
        break;
      case 415:
        showToast(
            '$status Tipo de Multimedia no soportada\nEl formato multimedia de los datos solicitados no está soportado por el servidor');
        break;
      case 416:
        showToast(
            '$status Rango solicitado no satisfecho\nEl rango especificado por el campo de encabezado Range en la solicitud no cumpl');
        break;
      case 417:
        showToast(
            '$status Expectativa fallida\nLa expectativa indicada por el campo de encabezado Expect solicitada no puede ser cumplida por el servidor');
        break;
      case 418:
        showToast('$status Soy una tetera\n(\n)\nc[]');
        break;
      case 421:
        showToast(
            '$status Solicitud mal dirigida\nLa petición fue dirigida a un servidor que no es capaz de producir una respuesta');
        break;
      case 422:
        showToast(
            '$status Entidad no procesable\nLa petición estaba bien formada pero no se pudo seguir debido a errores de semántica');
        break;
      case 423:
        showToast(
            '$status Bloqueado\nEl recurso que está siendo accedido está bloqueado');
        break;
      case 424:
        showToast(
            '$status Dependencia fallida\nLa petición falló debido a una falla de una petición previa');
        break;
      case 426:
        showToast(
            '$status Actualizacion requerida\nEl servidor se rehúsa a aplicar la solicitud usando el protocolo actual pero puede estar dispuesto a hacerlo después que el cliente se actualice a un protocolo diferente');
        break;
      case 428:
        showToast(
            '$status Condición previa requerida\nEl servidor origen requiere que la solicitud sea condicional');
        break;
      case 429:
        showToast(
            '$status Demasiadas solicitudes\nEl usuario ha enviado demasiadas solicitudes en un periodo de tiempo dado');
        break;
      case 431:
        showToast(
            '$status Campos del encabezado de solicitud son demasiado grandes\nEl servidor no está dispuesto a procesar la solicitud porque los campos de encabezado son demasiado largos');
        break;
      case 451:
        showToast('$status Invalido por razones legales\nRecurso ilegal');
        break;
      case 500:
        showToast(
            '$status Error Interno del Servidor\nEl servidor ha encontrado una situación que no sabe cómo manejarla');
        break;
      case 501:
        showToast(
            '$status No implementado\nEl método solicitado no está soportado por el servidor y no puede ser manejado');
        break;
      case 502:
        showToast(
            '$status Mal Gateway\nEl servidor, mientras trabaja como una puerta de enlace para obtener una respuesta necesaria para manejar la petición, obtuvo una respuesta inválida');
        break;
      case 503:
        showToast(
            '$status Servicio invalido\nEl servidor no está listo para manejar la petición');
        break;
      case 504:
        showToast(
            '$status Gateway fuera de tiempo\nEl servidor está actuando como una puerta de enlace y no puede obtener una respuesta a tiempo');
        break;
      case 505:
        showToast(
            '$status Version de http no soportada\nLa versión de HTTP usada en la petición no está soportada por el servidor');
        break;
      case 506:
        showToast(
            '$status Variantes agendadas\nEl servidor tiene un error de configuración interna');
        break;
      case 507:
        showToast(
            '$status Espacio insuficiente\nEl servidor tiene un error de configuración interna');
        break;
      case 508:
        showToast(
            '$status Loop detectado\nEl servidor detectó un ciclo infinito mientras procesaba la solicitud');
        break;
      case 510:
        showToast(
            '$status No extendido\nExtensiones adicionales para la solicitud son requeridas para que el servidor las cumpla');
        break;
      case 511:
        showToast(
            '$status Autorizacion de red requerida\nEl cliente necesita autenticar para obtener acceso a la red');
        break;

      default:
        showToast('Desconocido\n¿como le hiciste?ඞ');
        break;
    }
  }

  static void errorRed({required Object excepcion}) {
    if (excepcion is SocketException) {
      showToast('Falta de conexión a Internet o servidor no disponible');
    } else if (excepcion is FormatException) {
      showToast('Formato de envio de datos (JSON) no valido');
    } else if (excepcion is TimeoutException) {
      showToast('Error por tiempo de espera llego al limite');
    } else if (excepcion is ClientException) {
      showToast('Error de conexion a la red');
    } else {
      showToast('Error desconocido revise LOG\n$excepcion');
    }
  }
}
