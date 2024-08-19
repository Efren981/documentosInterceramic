global class ActualizarCasosProgramable implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        System.debug('Job ejecutado a las: ' + System.now());
        actualizarCasos();
    }
    
    @future
    public static void actualizarCasos() {
        List<Case> casosParaActualizar = [
            SELECT Id, IsStopped, Status
            FROM Case 
            WHERE Status NOT IN ('Closed', 'Cancelado')
            AND IsStopped = false
        ];
        
        System.debug('Casos encontrados: ' + casosParaActualizar.size());
        
        for(Case caso : casosParaActualizar) {
            caso.IsStopped = true;
            System.debug('Actualizando caso: ' + caso.Id + ' con Status: ' + caso.Status);
        }
        
        if(!casosParaActualizar.isEmpty()) {
            try {
                update casosParaActualizar;
                System.debug('Casos actualizados con éxito: ' + casosParaActualizar.size());
            } catch(Exception e) {
                System.debug('Error al actualizar casos: ' + e.getMessage());
            }
        } else {
            System.debug('No se encontraron casos para actualizar');
        }
    }
}