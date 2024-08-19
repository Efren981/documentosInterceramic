@isTest
private class ProductRestResourceTest {

    @isTest
    static void testCreateProducts() {
        // Create a mock REST request with your JSON payload
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/upsertProducts';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"PRODUCTOS":[{"ARTCLAVE":"MK.LICE.0699","ARTNUM":116560,"DESCRIPCION":"LICEO SATINADO CREMA 8X8 TACO","UOM":"Pza","METRO_UVENTA":12,"GRUPO":"PISO","SUBGRUPO":"PIEZA ESPECIAL","LINEA":"3D ACCENTS","MEDIDA":"33 cm x 33 cm","MEDIDA_GENERICA":"Mediano","PIEZAS_X_CAJA":6,"MARCA":"INTERCERAMIC","SUBMARCA":"STI","ESTATUS":"ACTIVO","TIPO":"LOSETA","FUENTE":"MANUFACTURADO","CUERPO":"CUERPO ROJO","APARIENCIA":"Piedra","COLOR":"Caoba","COLOR_GENERICO":"Café","ESTILO":"DECORADO","PESO":27.74,"TIPO_MERCADO":"NACIONAL","MOSTRAR":1,"COMPLETO":[{"ARCLAVE":"IN.3DAC.FUCA.186.2045.1"}],"IMAGEN_URL":"https://interceramic.com/media/catalog/product/cache/c687aa751us7cf01e65c009f6943c2b1e9/6/7/6743_001_5.jpg","FICHA_TECNICA_URL":"https://interceramic.com/pub/media/interceramic/downloadable/catalogs/ABED-Piso-CR-Brillante.pdf","HOJA_CATALOGO_URL":"https://interceramic.com/pub/media/interceramic/downloadable/catalogs/Interceramic_ABED_Abedul_MXHoja_de_Catalogo-005033.pdf","MANUAL_INSTALACION_URL":"https://interceramic.com/pub/media/interceramic/downloadable/catalogs/MB-SAGEO-02-0_Instructivo.pdf"}]}');

        RestContext.request = request;

        // Create test data for your batch class
        List<Log_Integration__c> logs = new List<Log_Integration__c>();

        // Set up any necessary data for your test

        // Call the REST endpoint
        Test.startTest();
        ProductRestResource.createProducts();
        Test.stopTest();
    }
    
     @isTest
    static void testCreateProducts2() {
          // Create a mock REST request with your JSON payload
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/upsertProducts';
        request.httpMethod = 'POST';
        //request.requestBody = Blob.valueOf(null);

        RestContext.request = request;

        // Create test data for your batch class
        List<Log_Integration__c> logs = new List<Log_Integration__c>();

        // Set up any necessary data for your test

        // Call the REST endpoint - Exception Scenario
        Test.startTest();

        // Simulate an exception within the createProducts method
        try {
            ProductRestResource.createProducts();
        } catch (Exception ex) {
            // Verify that the catch block was executed
            System.assertEquals('Expected exception message', ex.getMessage());

            // Check if a Log_Integration__c record was created
            List<Log_Integration__c> createdLogs = [SELECT Id FROM Log_Integration__c];
            System.assertEquals(1, createdLogs.size());
        }

        Test.stopTest();

        // Verify other data or behavior after the catch block if needed
        // e.g., assert response data or logs
    }
}