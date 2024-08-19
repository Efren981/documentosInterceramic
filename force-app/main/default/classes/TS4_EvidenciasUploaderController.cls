public with sharing class TS4_EvidenciasUploaderController {
    @AuraEnabled
    public static void saveFile(String fileName, String base64Data, String productoId) {
        // Decodificar los datos base64
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);
        
        // Crear el archivo adjunto
        TS4_AdjuntoDeProductoDeGarantia__c adjunto = new TS4_AdjuntoDeProductoDeGarantia__c(
            Producto_del_ticket__c = productoId
            // Campo para almacenar el archivo
        );
        
        // Insertar el adjunto
        insert adjunto;
    }
}