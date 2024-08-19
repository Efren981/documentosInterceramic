@IsTest
private class QueueableGetColoniaPagesTest {
    @IsTest
    static void testExecute() {
        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"COLONIAS": []}');
        
        // Create a mock implementation of the WS_Interceramic class
        // to simulate the getColonias method
        Test.setMock(HttpCalloutMock.class, new QueueableGetColoniaPagesMock(mockResponse));
        
        // Enqueue the Queueable job
        Test.startTest();
        System.enqueueJob(new QueueableGetColoniaPages());
        Test.stopTest();
        
        // Verify the results
        List<Colonia_Pagination__c> coloniaPages = [SELECT Name__c, Pages__c, Iterator__c, SetupOwnerId FROM Colonia_Pagination__c];
        System.assertEquals(1, coloniaPages.size());
        System.assertEquals('Pages', coloniaPages[0].Name__c);
        //System.assertEquals(1, coloniaPages[0].Pages__c);
        //System.assertEquals(0, coloniaPages[0].Iterator__c);
        //System.assertEquals(UserInfo.getUserId(), coloniaPages[0].SetupOwnerId);
    }
    
    // Mock implementation of HttpCalloutMock
    private class QueueableGetColoniaPagesMock implements HttpCalloutMock {
        HttpResponse mockResponse;
        
        public QueueableGetColoniaPagesMock(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return mockResponse;
        }
    }
}