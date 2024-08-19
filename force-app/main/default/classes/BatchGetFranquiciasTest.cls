/**
 * @description       : 
 * @author            : Jesus Alvarez
 * @group             : 
 * @last modified on  : 12-28-2023
 * @last modified by  : Jesus Alvarez
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-28-2023   Jesus Alvarez   Initial Version
**/
@IsTest
public with sharing class BatchGetFranquiciasTest {
    @IsTest
    static void testExecute_Success() {
        
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
        fran.INT_NameCorto__c = 'NOMBRE';
        fran.INT_EmpNum__c = 12;
        fran.INT_UpdateFranquicia__c = true;
        insert fran;
        // Create test data for mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"FRANQUICIAS":[{"EMPNUM":204,"NOMBRE":"NORTE AMBIENTE DE PRUEBAS","NOMBRECORTO":"NORTE","PAISCLAVE":"1","ENTFEDNUM":15,"MPONUM":126,"LOCALIDAD":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","COLNUM":2,"CP":"54080","CALLE":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","NUMEXT":"XXXXXXXXXX","NUMINT":"XXXXXXXXXX","TELEFONO":"6144422900","RFC":"DIN971119GG6","SUBSIDIARIA":1,"REGION":"NORTE"}]}');
        
        Test.setMock(HttpCalloutMock.class, new QueueableGetFranquiciasMock(mockResponse));

        // Enqueue the QueueableGetFranquicias job
        //Test.startTest();
        //Database.executeBatch(new QueueableGetFranquicias(),200);
        //System.enqueueJob(new QueueableGetFranquicias());
        //Test.stopTest();

        Test.startTest();
        String jsonString = '[{"EMPNUM":204,"NOMBRE":"NORTE AMBIENTE DE PRUEBAS","NOMBRECORTO":"NORTE","PAISCLAVE":"1","ENTFEDNUM":15,"MPONUM":126,"LOCALIDAD":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","COLNUM":2,"CP":"54080","CALLE":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","NUMEXT":"XXXXXXXXXX","NUMINT":"XXXXXXXXXX","TELEFONO":"6144422900","RFC":"DIN971119GG6","SUBSIDIARIA":1,"REGION":"NORTE"}]';
        List<Object> dataList = (List<Object>) JSON.deserializeUntyped(jsonString);
        Database.executeBatch(new BatchGetFranquicias(dataList), 1000);
        Test.stopTest();
        
    }

    //@IsTest
    /*static void testExecute_FailedUpsert() {
        // Create test data for mock HTTP response
        // ...

        // Create a mock result for the upsert operation
        Database.UpsertResult mockResult = new Database.UpsertResult();
        mockResult.setSuccess(false);
        mockResult.setErrors(new List<Database.Error>());

        // Replace the actual upsert method with a mock result
        Test.startTest();
        Test.setMock(Database.upsertResult.class, new QueueableGetFranquiciasMock(mockResult));
        System.enqueueJob(new QueueableGetFranquicias());
        Test.stopTest();

        // Verify the expected results
        // ...
    }*/
    
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