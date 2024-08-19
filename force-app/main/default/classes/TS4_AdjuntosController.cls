public with sharing class TS4_AdjuntosController {

    @AuraEnabled(cacheable=true)
    public static List<TS4_AdjuntoDeProductoDeGarantia__c> getFiles(Id productId) {
        try {
            return [SELECT Id, Name, ContentDocumentId__c, Tipo__c, Estado__c 
                    FROM TS4_AdjuntoDeProductoDeGarantia__c 
                    WHERE Producto_del_ticket__c = :productId];
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener archivos: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String uploadFiles(Id productId, String fileType, List<ContentFile> files) {
        try {
            List<TS4_AdjuntoDeProductoDeGarantia__c> newRecords = new List<TS4_AdjuntoDeProductoDeGarantia__c>();

            for (ContentFile file : files) {
                TS4_AdjuntoDeProductoDeGarantia__c newRecord = new TS4_AdjuntoDeProductoDeGarantia__c();
                newRecord.Producto_del_ticket__c = productId;
                newRecord.Tipo__c = fileType;
                newRecord.Estado__c = 'Pendiente';
                // Aquí puedes agregar lógica para almacenar la URL cuando esté disponible
                newRecords.add(newRecord);
            }

            if (!newRecords.isEmpty()) {
                insert newRecords;
                return 'Archivos cargados correctamente';
            } else {
                return 'No se encontraron archivos para cargar';
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al cargar los archivos: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteFile(Id recordId) {
        try {
            TS4_AdjuntoDeProductoDeGarantia__c recordToDelete = [SELECT Id FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id = :recordId LIMIT 1];
            
            if (recordToDelete != null) {
                delete recordToDelete;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al eliminar el archivo: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateFile(Id recordId, ContentFile newFile) {
        try {
            TS4_AdjuntoDeProductoDeGarantia__c recordToUpdate = [SELECT Id FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id = :recordId LIMIT 1];
            
            if (recordToUpdate != null) {
                // Aquí puedes agregar lógica para actualizar el registro si es necesario
                return 'Archivo actualizado correctamente';
            } else {
                return 'Registro no encontrado';
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error al actualizar el archivo: ' + e.getMessage());
        }
    }

    public class ContentFile {
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Body { get; set; }
    }
}