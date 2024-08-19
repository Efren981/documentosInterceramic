@isTest
public class ScheduleGetSucursalesTest {

    @IsTest
    static void testExecute() {
        // Create test data
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
        
        Franquicia__c fran = new Franquicia__c();
        fran.INT_PaisClave__c = '1';
        fran.INT_EntFedNum__c = 15;
        fran.INT_MpoNum__c = 126;
        fran.INT_EmpNum__c = 202;
        fran.INT_ColNum__c = 2;
        fran.INT_Colonia__c = colo.Id;
        insert fran;
        
        // Prepare the mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"SUCURSALES": [{"EMPNUM": 202,"SUCCLAVE": "TECH","NOMBRE": "TECNOLOGICO AMBIENTE DE PRUEBAS","NOMBRECORTO": "TECNOLOGICO","PAISCLAVE": "1","ENTFEDNUM": 8,"MPONUM": 19,"LOCALIDAD": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","COLNUM": 245,"CP": "31160","CALLE": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","NUMEXT": "XXXXXXXXXX","NUMINT": "XXXXXXXXXX","TELEFONO": "6144422900","IVA": 16,"IMPUESTOPRECIOS": 16,"TIPOSUC": "NR","SUCURSALFISICA": "NR","LAT": 28.6708699,"LNG": -106.0959206,"TIPOTIENDA": "A2","ABIERTAPUBLICO": 1}]}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        // Enqueue the queueable job
        Test.startTest();
        ScheduleGetSucursales scheduledJob = new ScheduleGetSucursales();
        String cronExpression = '0 0 0 1 2 ? 2025';
        System.schedule('Test Scheduled Job', cronExpression, scheduledJob);
        //System.enqueueJob(new QueueableGetSucursales());
        Test.stopTest();
        
    }
    
    // Mock implementation of HttpCalloutMock
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        HttpResponse mockResponse;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return mockResponse;
        }
    }
}