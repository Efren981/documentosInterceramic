@IsTest
public class INT_FWY_QuoteTriggerHandlerTest {
    @isTest
    static void handleTrigger_Test(){
        string msg = '';
        Test.startTest();
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
        
        try{
            SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id
        );
        insert testQuoteLine2;
            
        }catch(Exception e){
            system.debug(e.getMessage());
           
        }
        
        
        
        Test.stopTest();
        
        
    }
}