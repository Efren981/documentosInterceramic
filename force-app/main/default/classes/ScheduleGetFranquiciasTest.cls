@isTest
public class ScheduleGetFranquiciasTest {

     @isTest
    static void testScheduledJob() {
        Pais__c pais = new Pais__c();
        pais.INT_PaisClave__c = '1';
        insert pais;
        
        Estado__c estado = new Estado__c();
        estado.INT_Pais__c = pais.Id;
        estado.INT_PaisClave__c = '1';
        estado.INT_EntFedNum__c = 15;
        estado.INT_External_Id__c = '1 15';
        insert estado;
        
        Ciudad__c ciu = new Ciudad__c();
        ciu.INT_Estado__c = estado.Id;
        ciu.INT_PaisClave__c = '1';
        ciu.INT_EntFedNum__c = 15;
        ciu.INT_MpoNum__c = 126;
        ciu.INT_External_Id__c = '1 15 126';
        insert ciu;
        
		Colonia__c colo = new Colonia__c();
        colo.INT_PaisClave__c = '1';
        colo.INT_ColNum__c = 2;
        colo.INT_Colonia__c = 76169;
        colo.INT_CP__c = 54080;
        colo.INT_External_Id__c = '1 15 126 2';
        colo.INT_EntFedNum__c = 15;
        colo.INT_MpoNum__c = 126;
        colo.INT_Ciudad__c = ciu.Id;
        insert colo;
        
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"FRANQUICIAS":[{"EMPNUM":204,"NOMBRE":"NORTE AMBIENTE DE PRUEBAS","NOMBRECORTO":"NORTE","PAISCLAVE":"1","ENTFEDNUM":15,"MPONUM":126,"LOCALIDAD":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","COLNUM":2,"CP":"54080","CALLE":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","NUMEXT":"XXXXXXXXXX","NUMINT":"XXXXXXXXXX","TELEFONO":"6144422900","RFC":"DIN971119GG6","SUBSIDIARIA":1,"REGION":"NORTE"}]}');
        
        Test.setMock(HttpCalloutMock.class, new QueueableGetFranquiciasMock(mockResponse));
        
        // Start the scheduled job
        Test.startTest();
        ScheduleGetFranquicias scheduledJob = new ScheduleGetFranquicias();
        String cronExpression = '0 0 0 1 1 ? 2025';
        System.schedule('Test Scheduled Job', cronExpression, scheduledJob);
        Test.stopTest();
    }
    
        // Mock implementation of HttpCalloutMock
    private class QueueableGetFranquiciasMock implements HttpCalloutMock {
        HttpResponse mockResponse;
        
        public QueueableGetFranquiciasMock(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return mockResponse;
        }
    }
}