public with sharing class AdjuntosController {
    @AuraEnabled(cacheable=true)
    public static List<TS4_AdjuntoDeProductoDeGarantia__c> getAdjuntos() {
        return [SELECT Id, Nombre_del_Archivo__c 
                FROM TS4_AdjuntoDeProductoDeGarantia__c 
                WHERE Tipo__c = 'Adjunto'];
    }
}