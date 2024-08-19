@isTest
public class INT_QuoteLineTriggerHandlerTest {
    @isTest
    static void deleteCase_Test() {
        // Create test data
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        insert testQuote;
        
        Product2 testProduct = new Product2(
            ProductCode = 'A1',
            Name = 'Test Product',
            UnidadVenta__c = 'Pza'
        );
        insert testProduct;
        
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id
            /* set other required fields */
        );
        insert testQuoteLine;
        
        
        Test.startTest();
        try{
            delete testQuoteLine;
        }catch(Exception ex){
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void insertCaseException_Test() {
        Id idPB = Test.getStandardPricebookId();
        Pricebook2 objPB2 = new Pricebook2();
        objPB2.Name = 'TESTPBDos';
        insert objPB2;
        
        // Create test data
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__PriceBook__c = objPB2.Id;
        insert testQuote;
        
        Product2 testProduct = new Product2(
            ProductCode = 'A1',
            Name = 'Test Product',
            UnidadVenta__c = 'Pza'
        );
        insert testProduct;
        
        PricebookEntry objSPE = new PricebookEntry();
        objSPE.Product2Id  = testProduct.Id;
        objSPE.Pricebook2Id = idPB;
        objSPE.UnitPrice = 100.00;
        insert objSPE;
        
        PricebookEntry objPE = new PricebookEntry();
        objPE.Product2Id  = testProduct.Id;
        objPE.Pricebook2Id = objPB2.Id;
        objPE.UnitPrice = 100.00;
        insert objPE;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__ListPrice__c = 99.00
        );
        
        List<SBQQ__QuoteLine__c> lstQL = new List<SBQQ__QuoteLine__c>();
        lstQL.add(testQuoteLine);
        //User u = [select Id, profile.name from User where profile.Name = 'Autorizador Excepciones MB' LIMIT 1];
        
        Test.startTest();
            try{
                INT_QuoteLineTriggerHandler.validateInsertPriceChange(lstQL);
            }catch(Exception ex){
                System.debug('ENTRAMOS AL ERROR DEL MENSAJE DEL CAMBIO DE PRECIO');
            }
        Test.stopTest();
    }
    
    
}