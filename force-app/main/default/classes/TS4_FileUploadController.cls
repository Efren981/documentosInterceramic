public with sharing class TS4_FileUploadController {
    @AuraEnabled
    public static List<TS4_AdjuntoDeProductoDeGarantia__c> getAdjuntosDeProducto(Id recordId) {
        return [SELECT Id, Producto_del_ticket__c, Producto_del_ticket__r.Name, URL_del_archivo__c 
                FROM TS4_AdjuntoDeProductoDeGarantia__c
                WHERE Producto_del_ticket__c = :recordId];
    }
    
    @AuraEnabled
    public static void updateAdjuntoUrl(Id adjuntoId, String fileUrl) {
        TS4_AdjuntoDeProductoDeGarantia__c adjunto = [
            SELECT Id, URL_del_archivo__c 
            FROM TS4_AdjuntoDeProductoDeGarantia__c 
            WHERE Id = :adjuntoId
        ];
        
        adjunto.URL_del_archivo__c = fileUrl;
        update adjunto;
    }
}