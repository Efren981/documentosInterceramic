trigger TS4_ProductImage on Product2 (after insert, after update) {
    // Iterar sobre los registros nuevos
    for (Product2 proItem : Trigger.new) {
        // Variable para determinar si se debe ejecutar el método
        Boolean shouldExecute = false;

        // Validar si es una actualización (Trigger.oldMap contiene los valores antiguos)
        if (Trigger.isUpdate) {
            // Obtener el producto antiguo de Trigger.oldMap
            Product2 proOld = Trigger.oldMap.get(proItem.Id);
            
            // Comprobar si los valores han cambiado
            if (proItem.INT_Imagen_URL__c != proOld.INT_Imagen_URL__c ) {
                shouldExecute = true;
            }
        } else {
            // Si es una inserción, siempre ejecutar
            shouldExecute = true;
        }

        // Ejecutar el método si se cumple la condición
        if (shouldExecute) {
            if(System.IsBatch() == false && System.isFuture() == false){
                TS4_RestImage.TS4_RestImage(proItem.INT_Imagen_URL__c, proItem.Id);
            }
        }
    }
}