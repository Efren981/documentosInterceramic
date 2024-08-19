public with sharing class TS4_ProductTableController {
    @AuraEnabled(cacheable=true)
    public static List<TS4_Producto_del_ticket__c> getProductosDelTicket(Id casoId) {
        return [SELECT Id, TS4_Clave_de_articulo__c, DESCRIPCION__c, TS4_Tipo__c, 
                       TS4_PRECIOUNITARIO__c, CANTIDAD__c, TS4_Monto_Garantia__c, 
                       TS4_Dictamen__c, TS4_Numero_de_piezas_a_reclamar__c
                FROM TS4_Producto_del_ticket__c
                WHERE TS4_Id_Caso__c = :casoId];
    }

    @AuraEnabled
    public static String updateProductos(List<TS4_Producto_del_ticket__c> productos) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<TS4_Producto_del_ticket__c> productosToUpdate = new List<TS4_Producto_del_ticket__c>();
            for (TS4_Producto_del_ticket__c producto : productos) {
                TS4_Producto_del_ticket__c updatedProducto = new TS4_Producto_del_ticket__c(
                    Id = producto.Id,
                    TS4_Monto_Garantia__c = producto.TS4_Monto_Garantia__c,
                    TS4_Dictamen__c = producto.TS4_Dictamen__c,
                    TS4_Numero_de_piezas_a_reclamar__c = producto.TS4_Numero_de_piezas_a_reclamar__c
                );
                productosToUpdate.add(updatedProducto);
            }
            
            update productosToUpdate;
            return 'Success';
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error updating productos: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error al actualizar productos: ' + e.getMessage());
        }
    }
}