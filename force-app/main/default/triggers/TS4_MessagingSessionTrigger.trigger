trigger TS4_MessagingSessionTrigger on MessagingSession (after insert, after update) {
    List<Case> casesToUpdate = new List<Case>();
    
    for (MessagingSession ms : Trigger.new) {
        // Verifica si el campo de búsqueda de Caso no está vacío
        if (ms.CaseId != null) {
            Case relatedCase = new Case(
                Id = ms.CaseId,
                OwnerId = ms.OwnerId
            );
            casesToUpdate.add(relatedCase);
        }
    }
    
    if (!casesToUpdate.isEmpty()) {
        try {
            update casesToUpdate;
        } catch (Exception e) {
            System.debug('Error al actualizar los casos: ' + e.getMessage());
            // Aquí podrías agregar lógica adicional para manejar errores, como enviar un email de notificación
        }
    }
}