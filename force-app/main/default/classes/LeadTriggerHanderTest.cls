@isTest
public class LeadTriggerHanderTest {
    @TestSetup
    static void makeData(){
        Lead iLead = TestDataFactory.createLead('First Name Initial', 'Last Name Initial', 'testInitial@test.com', null);
    }
    
    @isTest
    public static void testOKIdLealtad(){
        Test.setMock(HttpCalloutMock.class, new LeadSuccessMock());
        
        test.startTest();
        TestDataFactory.createLead('First Name', 'Last Name', 'test@test.com', 15);
        test.stopTest();
    }
    
    @isTest
    public static void testNotOKIdLealtad(){
        Test.setMock(HttpCalloutMock.class, new LeadNotSuccessMock());
        
        test.startTest();
        TestDataFactory.createLead('First Name', 'Last Name', 'test@test.com', 16);
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateOKIdLealtad(){
        Lead iLead = [SELECT INT_Id_Interface__c FROM Lead LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new LeadSuccessMock());
        
        test.startTest();
        iLead.INT_Id_Interface__c = 15;
        update iLead;
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateNotOKIdLealtad(){
        Lead iLead = [SELECT INT_Id_Interface__c FROM Lead LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new LeadNotSuccessMock());
        
        test.startTest();
        iLead.INT_Id_Interface__c = 16;
        update iLead;
        test.stopTest();
    }
    
    private class LeadSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a mock HTTP response for successful Lead conversion
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String jsonData = '{"RESULTADO":"OK","NOMBRE":"JORGE ELOHIM","APELLIDO":"SALCIDO HERRERA","NIVEL":"White","ESTATUS":"Activo","MENSAJEIDVALIDO":"Id socio Interpass Interceramic válido","MENSAJEIDACTUALIZADO":"Id socio Interpass Interceramic actualizado"}';
            response.setBody(jsonData);
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class LeadNotSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a mock HTTP response for successful Lead conversion
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String jsonData = '{"RESULTADO":"NOT OK","ERROR":"El ID de la Cuenta INTERPASS no es válido"}';
            response.setBody(jsonData);
            response.setStatusCode(200);
            return response;
        }
    }
}