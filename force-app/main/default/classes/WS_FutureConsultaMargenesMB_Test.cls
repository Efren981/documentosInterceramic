@isTest
private class WS_FutureConsultaMargenesMB_Test {
    @isTest
    static void consultaMargenesMB_Test() {
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
        
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"PRODUCTOS":[{"ARTCLAVE":"A1","CANTIDAD":10,"PRECIO_FRANQ":100.00}]}');
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new CustomHttpCalloutMockMargenesMB(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        WS_FutureConsultaMargenesMB.consultaMargenesMB(testQuote.Id, 'mock body');
        Test.stopTest();
    }
    
    @isTest
    static void consultaMargenesMB2_Test() {
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
        
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"PRODUCTOS":[{"ARTCLAVE":"A2","CANTIDAD":1,"PRECIO_FRANQ":100.00}]}');
        
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new CustomHttpCalloutMockMargenesMB(mockResponse));
        
        // Call the method to be tested
        Test.startTest();
        WS_FutureConsultaMargenesMB.consultaMargenesMB(testQuote.Id, 'mock body');
        Test.stopTest();
    }
}