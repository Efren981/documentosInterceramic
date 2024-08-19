public class ObtenerIdSesionMensajeria {
    @InvocableMethod(label='Obtener ID de Sesión de Mensajería' description='Este método devuelve el ID de la sesión de mensajería')
    public static List<String> obtenerIdSesion(List<String> sessionIds) {
        List<String> resultado = new List<String>();
        
        for (String sessionId : sessionIds) {
            // Log para verificar si se obtiene un ID
            System.debug('Obteniendo ID de Sesión: ' + sessionId);
            
            // Añadir el ID al resultado
            resultado.add(sessionId);
        }

        // Log final para mostrar la lista completa de IDs obtenidos
        System.debug('IDs de Sesión obtenidos: ' + resultado);
        
        return resultado;
    }
}