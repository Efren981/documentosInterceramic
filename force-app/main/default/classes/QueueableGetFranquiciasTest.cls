/**
 * @description       : 
 * @author            : Jesus Alvarez
 * @group             : 
 * @last modified on  : 12-28-2023
 * @last modified by  : Jesus Alvarez
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-27-2023   Jesus Alvarez   Initial Version
**/
@IsTest
public class QueueableGetFranquiciasTest {
    @IsTest
    static void testExecute_Success() {
        // Create test data for mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"FRANQUICIAS":[{"EMPNUM":204,"NOMBRE":"NORTE AMBIENTE DE PRUEBAS","NOMBRECORTO":"NORTE","PAISCLAVE":"1","ENTFEDNUM":15,"MPONUM":126,"LOCALIDAD":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","COLNUM":2,"CP":"54080","CALLE":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","NUMEXT":"XXXXXXXXXX","NUMINT":"XXXXXXXXXX","TELEFONO":"6144422900","RFC":"DIN971119GG6","SUBSIDIARIA":1,"REGION":"NORTE"}]}');
        
        Test.setMock(HttpCalloutMock.class, new QueueableGetFranquiciasMock(mockResponse));

        Test.startTest();

        // Llamar a la clase Queueable
        System.enqueueJob(new QueueableGetFranquicias());

        // Detener la ejecución y esperar a que se complete el job
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