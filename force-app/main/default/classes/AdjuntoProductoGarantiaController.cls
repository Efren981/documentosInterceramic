public class AdjuntoProductoGarantiaController {
    @AuraEnabled
    public static List<TS4_AdjuntoDeProductoDeGarantia__c> getAdjuntos(String recordId) {
        return [SELECT Id, Nombre_del_Archivo__c, Tipo__c, Estado__c, URL_del_archivo__c 
                FROM TS4_AdjuntoDeProductoDeGarantia__c 
                WHERE Producto_del_ticket__c =:recordId
                ORDER BY Tipo__c, Nombre_del_Archivo__c];
    }
    
    @AuraEnabled
    public static String uploadFile(String fileData,String fileType,String idAdjunto) {
        System.debug('>>');
        System.debug(fileData);
        System.debug(fileType);
        String extension=fileType.split('/')[1];
        //sacar la categoria (carpeta)
        String tipo=[SELECT Tipo__c FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id =:idAdjunto].Tipo__c;
        //definir el nombre del archivo numeroCasoCodigoProductoConsecutivo.png // consultar el cao, producto
        String codigoProducto=[SELECT Producto_del_ticket__r.TS4_Clave_de_articulo__c  FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id =:idAdjunto].Producto_del_ticket__r.TS4_Clave_de_articulo__c ;
        String numeroCaso=[SELECT Producto_del_ticket__r.TS4_Id_Caso__r.caseNumber  FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id =:idAdjunto].Producto_del_ticket__r.TS4_Id_Caso__r.caseNumber;
        String nombreArchivo=numeroCaso+'_'+codigoProducto+'.'+extension;
        String urlResource=TS4_consumoS3.cargaArchivo(fileData,fileType,tipo,nombreArchivo);
        TS4_AdjuntoDeProductoDeGarantia__c adjunto=[SELECT URL_del_archivo__c,Estado__c FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id =:idAdjunto];
        adjunto.Estado__c ='Completado';
        adjunto.URL_del_archivo__c=urlResource;
        update adjunto;
        return 'OK';
    }
    
    @AuraEnabled
    public static void updateAdjunto(Id adjuntoId, String url) {
        TS4_AdjuntoDeProductoDeGarantia__c adjunto = new TS4_AdjuntoDeProductoDeGarantia__c(
            Id = adjuntoId,
            URL_del_archivo__c = url,
            Estado__c = 'Completado'
        );
        update adjunto;
    }
    
    @AuraEnabled
    public static void deleteAdjunto(Id adjuntoId) {
        TS4_AdjuntoDeProductoDeGarantia__c adjunto = new TS4_AdjuntoDeProductoDeGarantia__c(
            Id = adjuntoId,
            URL_del_archivo__c = null,
            Estado__c = 'Pendiente'
        );
        update adjunto;
}
}