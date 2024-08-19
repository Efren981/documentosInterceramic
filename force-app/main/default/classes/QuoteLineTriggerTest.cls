@isTest
public class QuoteLineTriggerTest {
	@TestSetup
    static void makeData(){
        
        Pricebook2 standardPricebook = new Pricebook2(
        	Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        Pricebook2 customPricebook = new Pricebook2(
        	Name = 'PENINSULA SIN IVA',
            IsActive = true
        );
        insert customPricebook;
        
        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TEST-PROD', IsActive = true);
        insert prod;
        
        PricebookEntry standardPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id, 
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert standardPbe;
        
        PricebookEntry customPbe = new PricebookEntry(
            Pricebook2Id = customPricebook.Id, 
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert customPbe;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;  
    }
    
    @isTest
    static void testQuoteLineTrigger(){
        Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST-PROD' LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = prod.Id
        );
        
        Test.startTest();
        insert quoteLine;
        Test.stopTest();
        
        quoteLine = [SELECT Precio_unitario_de_lista_peninsula__c FROM SBQQ__QuoteLine__c WHERE Id = :quoteLine.Id];
        System.assertEquals(100.00, quoteLine.Precio_unitario_de_lista_peninsula__c, 'El precio no se actualizó correctamente');
    }
        
    @isTest
    static void testQuoteLineTriggerWithInvalidProduct() {
        // Crear una cotización
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        // Crear una línea de cotización con un producto que no existe en la lista de precios
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = '01t000000000001AAA' // ID de producto inválido
        );
        
        Test.startTest();
        try {
            insert quoteLine;
            System.assert(false, 'Se esperaba una excepción');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Producto con ID'), 'Mensaje de error incorrecto');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testQuoteLineTriggerWithInvalidPricebook() {
        // Eliminar la lista de precios creada en el setup
        delete [SELECT Id FROM Pricebook2 WHERE Name = 'PENINSULA SIN IVA'];
        
        // Obtener el producto y la cotización creados en el setup
        Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST-PROD' LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        // Crear una línea de cotización
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = prod.Id
        );
        
        Test.startTest();
        try {
            insert quoteLine;
            System.assert(false, 'Se esperaba una excepción');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('No se encontró la lista de precios'), 'Mensaje de error incorrecto');
        }
        Test.stopTest();
    }     
}