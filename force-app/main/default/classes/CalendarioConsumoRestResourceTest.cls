@IsTest
private class CalendarioConsumoRestResourceTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Product2 product = TestDataFactory.createProduct(null, null, null, null);
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
        Calendario_de_Consumo__c testCalendarioConsumo = TestDataFactory.createCalendarioConsumo(opp, oppLineItem);
    }

    @IsTest
    static void testGetCalendarioConsumo() {

        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getCalendarioConsumo/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        // Create a request body with the Opportunity ID
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', testOpportunity.Id);
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        Test.startTest();
        RestContext.request = request;
        
        // Call the REST resource method
        CalendarioConsumoRestResource.getCalendarioConsumo();
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetCalendarioConsumoOppIdNULL() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getCalendarioConsumo/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        // Create a request body with the Opportunity ID
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', null);
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        Test.startTest();
        RestContext.request = request;
        
        // Call the REST resource method
        CalendarioConsumoRestResource.getCalendarioConsumo();
        
        Test.stopTest();
    }
    
    
    @IsTest
    static void testGetCalendarioConsumoCatchBlock() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getCalendarioConsumo/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        // Create a request body with the Opportunity ID
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', testOpportunity.Id);
        request.requestBody = Blob.valueOf(JSON.serialize(''));
        
        Test.startTest();
        RestContext.request = request;
        CalendarioConsumoRestResource.getCalendarioConsumo();
        Test.stopTest();
    }
    
}