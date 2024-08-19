@isTest
public class ContactTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Pais__c pais = TestDataFactory.createPais('1234');
        Estado__c estado = TestDataFactory.createEstado(10.0, '1', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado, estado.INT_EntFedNum__c, pais.INT_PaisClave__c, 126, 'Ciudad Test');
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
    }

    @isTest
    public static void testOKIdLealtad(){
        test.startTest();
        Estado__c estado = [SELECT Id, INT_Pais__c FROM Estado__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Ciudad__c ciudad = [SELECT Id FROM Ciudad__c LIMIT 1];
        Colonia__c colonia = [SELECT Id, INT_Ciudad__c FROM Colonia__c LIMIT 1];
        
        estado.INT_Pais__c = pais.Id;
        update estado;
        
        colonia.INT_Ciudad__c = ciudad.Id;
        update colonia;

        Test.setMock(HttpCalloutMock.class, new ContactSuccessMock());
        TestDataFactory.createContact('first', 'Contact1', 'mail1@mail.com', 15, acc, pais, estado, ciudad, colonia);
        test.stopTest();
    }
    
    @isTest
    public static void testNotOKIdLealtad(){
        Test.setMock(HttpCalloutMock.class, new ContactNotSuccessMock());
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Estado__c estado = [SELECT Id, INT_Pais__c FROM Estado__c LIMIT 1];
        Ciudad__c ciudad = [SELECT Id FROM Ciudad__c LIMIT 1];
        Colonia__c colonia = [SELECT Id FROM Colonia__c LIMIT 1];

        colonia.INT_Ciudad__c = ciudad.Id;
        update colonia;

        test.startTest();
        TestDataFactory.createContact('first', 'Contact1', 'mail1@mail.com', 16, acc, pais, estado, ciudad, colonia);
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateOKIdLealtad(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Ciudad__c ciudad = [SELECT Id FROM Ciudad__c LIMIT 1];
        Colonia__c colonia = [SELECT Id FROM Colonia__c LIMIT 1];
        Estado__c estado = [SELECT Id, INT_Pais__c FROM Estado__c LIMIT 1];
        
        colonia.INT_Ciudad__c = ciudad.Id;
        update colonia;

        Contact iContact = TestDataFactory.createContact('first', 'Contact1', 'mail1@mail.com', null, acc, pais, estado, ciudad, colonia);
        Test.setMock(HttpCalloutMock.class, new ContactSuccessMock());
        
        test.startTest();
        iContact.INT_Id_Interface__c = 15;
        update iContact;
        test.stopTest();
    }
    
    @isTest
    public static void testUpdateNotOKIdLealtad(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Ciudad__c ciudad = [SELECT Id FROM Ciudad__c LIMIT 1];
        Colonia__c colonia = [SELECT Id FROM Colonia__c LIMIT 1];
        Estado__c estado = [SELECT Id, INT_Pais__c FROM Estado__c LIMIT 1];
        
        colonia.INT_Ciudad__c = ciudad.Id;
        update colonia;

        Contact iContact = TestDataFactory.createContact('first', 'Contact1', 'mail1@mail.com', null, acc, pais, estado, ciudad, colonia);
        
        Test.setMock(HttpCalloutMock.class, new ContactNotSuccessMock());
        
        test.startTest();
        iContact.INT_Id_Interface__c = 16;
        update iContact;
        test.stopTest();
    }
    
    private class ContactSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a mock HTTP response for successful Contact conversion
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String jsonData = '{"RESULTADO":"OK","NOMBRE":"JORGE ELOHIM","APELLIDO":"SALCIDO HERRERA","NIVEL":"White","ESTATUS":"Activo","MENSAJEIDVALIDO":"Id socio Interpass Interceramic válido","MENSAJEIDACTUALIZADO":"Id socio Interpass Interceramic actualizado"}';
            response.setBody(jsonData);
            response.setStatusCode(200);
            return response;
        }
    }
    
    private class ContactNotSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a mock HTTP response for successful Contact conversion
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String jsonData = '{"RESULTADO":"NOT OK","ERROR":"El ID de la Cuenta INTERPASS no es válido"}';
            response.setBody(jsonData);
            response.setStatusCode(200);
            return response;
        }
    }
}