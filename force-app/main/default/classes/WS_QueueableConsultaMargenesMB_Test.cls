/**FREEWAY
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Clase Test de la clase WS_QueueableConsultaMargenesMB
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Abraham Gudiño   <agudino@freewayconsulting.com>
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        25-10-2023
* @modified       
* @systemLayer    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            xxxxxxxxx@xxxxx.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class WS_QueueableConsultaMargenesMB_Test {
    
    @testSetup
    static void setup(){
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
    }

    @isTest
    static void consultaMargenesMB_Test() {
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"PRODUCTOS":[{"ARTCLAVE":"A1","CANTIDAD":10,"PRECIO_FRANQ":100.00}]}');
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new CustomHttpCalloutMockMargenesMB(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        System.enqueueJob(new WS_QueueableConsultaMargenesMB(testQuote.Id, 'mock body'));
        Test.stopTest();
    }
    
    @isTest
    static void consultaMargenesMB2_Test() {
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"PRODUCTOS":[{"ARTCLAVE":"A2","CANTIDAD":1,"PRECIO_FRANQ":100.00}]}');
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new CustomHttpCalloutMockMargenesMB(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        System.enqueueJob(new WS_QueueableConsultaMargenesMB(testQuote.Id, 'mock body'));
        Test.stopTest();
    }
    
    
}