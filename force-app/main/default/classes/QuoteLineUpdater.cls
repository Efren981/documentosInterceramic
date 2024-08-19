/*---------------------------------------------------------------------------------------------------------------
--- Company: Interceramic
--- Author: Victor Ruiz - TS4 Strategy
--- Description: Clase que actualiza cada partida de presupuesto los importes de la lista de precio peninsula en el campo Precio_unitario_de_lista_peninsulta__c.
--- CreateDate:  23/07/2024
--- Update for: 
--- UpdateDate: 
--- Update Description: 
----------------------------------------------------------------------------------------------------------------*/

public class QuoteLineUpdater implements IQuoteLineUpdater {
    private static final String PRICEBOOK_NAME = 'PENINSULA SIN IVA';
    
    public void updateQuoteLines(List<SBQQ__QuoteLine__c> quoteLines) {
        Id newPricebookId = getPricebookId();
        if (newPricebookId == null) {
            throw new QuoteLineUpdaterException('No se encontró la lista de precios: ' + PRICEBOOK_NAME);
        }
        
        // Crear un mapa para almacenar los nuevos precios por Product2Id
        Map<Id, Decimal> productPrices = new Map<Id, Decimal>();
        
        // Obtener los Product2Id de las líneas de cotización
        Set<Id> productIds = new Set<Id>();
        for (SBQQ__QuoteLine__c qli : quoteLines) {
            productIds.add(qli.SBQQ__Product__c);
        }
        
        // Consultar los PricebookEntry para la nueva lista de precios
        List<PricebookEntry> pricebookEntries = [
            SELECT Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :newPricebookId
            AND Product2Id IN :productIds
        ];
        
        // Llenar el mapa con los nuevos precios
        for (PricebookEntry pbe : pricebookEntries) {
            productPrices.put(pbe.Product2Id, pbe.UnitPrice);
        }
        
        // Actualizar las líneas de cotización con los nuevos precios
        for (SBQQ__QuoteLine__c qli : quoteLines) {
            if (productPrices.containsKey(qli.SBQQ__Product__c)) {
                qli.Precio_unitario_de_lista_peninsula__c = productPrices.get(qli.SBQQ__Product__c);
            } else {
                // Producto no encontrado en el PricebookEntry, lanzar una excepción
                throw new QuoteLineUpdaterException('Producto con ID ' + qli.SBQQ__Product__c + ' no encontrado en la lista de precios: ' + PRICEBOOK_NAME);
            }
        }
    }
    
    private Id getPricebookId() {
        List<Pricebook2> pricebooks = [SELECT Id FROM Pricebook2 WHERE Name = :PRICEBOOK_NAME LIMIT 1];
        return !pricebooks.isEmpty() ? pricebooks[0].Id : null;
    }
    
    public class QuoteLineUpdaterException extends Exception {}
}