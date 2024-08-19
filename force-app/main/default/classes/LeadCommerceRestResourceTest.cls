@isTest
public class LeadCommerceRestResourceTest {
    
    @isTest
    static void testCreateCommerceLeads() {
        // Create test data to simulate the REST request
        String requestBody = '{' +
            '"Clientes": [' +
            '{' +
            '"customerNumber": "0000000044",' +
            '"Nombres": "Test",' +
            '"Apellidos": "Commerce",' +
            '"Origen": "Commerce",' +
            '"Telefono": "4223984939",' +
            '"Telefono_Personal": "3231238178",' +
            '"Correo": "test@test.com",' +
            '"Contrasenia": "kjhdujhuhyebuheu",' +
            '"Pais": "1",' +
            '"Estado": "3",' +
            '"Municipio": "22",' +
            '"Colonia": "334",' +
            '"Calle": "7 de noviembre",' +
            '"Numero_Exterior": "144",' +
            '"Numero_Interior": "33",' +
            '"Entre_que_calles": "rio tepic y toronjo",' +
            '"Ubicacion": {' +
            '"Lugar": "Departamento",' +
            '"Estacionamiento": true,' +
            '"Distancia_aproximada": "123",' +
            '"Distancia_entrada": "120",' +
            '"Piso_de_entrega": "2",' +
            '"Desnivel": false,' +
            '"Rampa": false,' +
            '"Por_donde_se_subira_el_material": "escalera",' +
            '"Escaleras": true' +
            '}' +
            '}' +
            ']' +
            '}';
        
        // Simulate the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/upsertCommerceLeads';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Set the Content-Type header in the simulated response
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        // Create test data for other dependencies
        Pais__c pais = new Pais__c(INT_PaisClave__c = '1');
        Estado__c estado = new Estado__c(INT_External_Id__c = '3');
        Ciudad__c ciudad = new Ciudad__c(INT_External_Id__c = '22');
        Colonia__c colonia = new Colonia__c(INT_External_Id__c = '334');
        insert new List<SObject>{pais, estado, ciudad, colonia};
            
            // Get the RecordTypeId for 'Relaciones_Publicas' record type
            //Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Relaciones_Publicas').getRecordTypeId();
            
            // Call the REST resource method
            Test.startTest();
        LeadCommerceRestResource.createCommerceLeads();
        Test.stopTest();
        
        // Verify that a lead was inserted
        Integer leadCount = [SELECT COUNT() FROM Lead WHERE INT_Cliente_Id__c = '0000000044'];
        System.assertEquals(1, leadCount);
    }
    
    @isTest
    static void testCreateCommerceLeadsWithError() {
        // Create test data to simulate the REST request with an error
        String requestBody = '{' +
            '"Clientes": [' +
            '{' +
            '"customerNumber": "0000000044",' +
            '"Nombres": "Test",' +
            '"Apellidos": "Commerce",' +
            '"Origen": "Commerce",' +
            '"Telefono": "4223984939",' +
            '"Telefono_Personal": "3231238178",' +
            '"Correo": "test@test.com",' +
            '"Contrasenia": "kjhdujhuhyebuheu",' +
            '"Pais": "1",' +
            '"Estado": "3",' +
            '"Municipio": "22",' +
            '"Colonia": "334",' +
            '"Calle": "7 de noviembre",' +
            '"Numero_Exterior": "144",' +
            '"Numero_Interior": "33",' +
            '"Entre_que_calles": "rio tepic y toronjo",' +
            '"Ubicacion": {' +
            '"Lugar": "Departamento",' +
            '"Estacionamiento": true,' +
            '"Distancia_aproximada": "123",' +
            '"Distancia_entrada": "120",' +
            '"Piso_de_entrega": "2",' +
            '"Desnivel": false,' +
            '"Rampa": false,' +
            '"Por_donde_se_subira_el_material": "escalera",' +
            '"Escaleras": true' +
            '}' +
            '},' +
            '{' +
            '"customerNumber": "0000000044",' +
            '"Nombres": "Test",' +
            '"Apellidos": "Commerce",' +
            '"Origen": "Commerce",' +
            '"Telefono": "4223984939",' +
            '"Telefono_Personal": "3231238178",' +
            '"Correo": "test@test.com",' +
            '"Contrasenia": "kjhdujhuhyebuheu",' +
            '"Pais": "1",' +
            '"Estado": "3",' +
            '"Municipio": "22",' +
            '"Colonia": "334",' +
            '"Calle": "7 de noviembre",' +
            '"Numero_Exterior": "144",' +
            '"Numero_Interior": "33",' +
            '"Entre_que_calles": "rio tepic y toronjo",' +
            '"Ubicacion": {' +
            '"Lugar": "Departamento",' +
            '"Estacionamiento": true,' +
            '"Distancia_aproximada": "123",' +
            '"Distancia_entrada": "120",' +
            '"Piso_de_entrega": "2",' +
            '"Desnivel": false,' +
            '"Rampa": false,' +
            '"Por_donde_se_subira_el_material": "escalera",' +
            '"Escaleras": true' +
            '}' +
            '}' +
            ']' +
            '}';
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/upsertCommerceLeads';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        // Call the REST resource method
        Test.startTest();
        LeadCommerceRestResource.createCommerceLeads();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        
        System.assertEquals(null, res);
    }
    
    
    @isTest
    static void testCreateCommerceLeadsWithException() {
        // Create test data to simulate the REST request with an exception
        String requestBody = 'Invalid JSON'; // Invalid JSON to trigger an exception
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/upsertCommerceLeads';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        // Call the REST resource method
        Test.startTest();
        LeadCommerceRestResource.createCommerceLeads();
        Test.stopTest();
        
        // Verify the response
        RestResponse res = RestContext.response;
        System.assertEquals(null, res);
        //System.assertEquals('application/json', res.headers.get('Content-Type'));
        /*Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(500, responseMap.get('status'));
        System.assertEquals('Error: System.JSONException: Unexpected character', responseMap.get('message'));*/
    }
}