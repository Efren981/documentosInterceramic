public class StopMilestonesBatch implements Database.Batchable<SObject>, Database.Stateful {
    // Query para seleccionar los casos que deseas detener
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, IsStopped 
            FROM Case 
            WHERE Status NOT IN ('Closed', 'Cancelado') 
        ]);
    }

    // Proceso por lotes de 50 casos
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        for (Case c : scope) {
            c.IsStopped = true;
        }

        if (!scope.isEmpty()) {
            update scope;
        }
    }

    // Finalizar el batch
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process finished.');
    }
}