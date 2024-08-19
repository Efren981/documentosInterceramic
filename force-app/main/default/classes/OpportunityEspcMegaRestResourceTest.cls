@isTest
public class OpportunityEspcMegaRestResourceTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Pais__c pais = TestDataFactory.createPais('1');
        Estado__c estado = TestDataFactory.createEstado(15, '1 15', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado, estado.INT_EntFedNum__c, pais.INT_PaisClave__c, 126, 'Test Ciudad');
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
        Franquicia__c franquicia = TestDataFactory.createFranquicia(colonia, pais.INT_PaisClave__c, estado.INT_EntFedNum__c, ciudad.INT_MpoNum__c, 12);
        Sucursal__c sucursal = TestDataFactory.createSucursal(pais.INT_PaisClave__c, estado.INT_EntFedNum__c, franquicia.INT_EmpNum__c);
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opp', 'Acuerdo / Convenio', pais, ciudad, estado, colonia, franquicia, sucursal);
    }
    
    @IsTest
    static void testGetOpportunity() {
        Opportunity objOpp = [SELECT Id, RecordType.Name, INT_Id_Convenio__c FROM Opportunity LIMIT 1];
		System.debug('INT_Id_Convenio__c: ' + objOpp.INT_Id_Convenio__c);
        // Create a mock REST request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getOpportunityEspcMega/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('Empnum', 202);
        requestBody.put('Nombre_Oportunidad', 'Prueba');
        requestBody.put('Ejecutivo', 'Pablo Rodriguez');
        requestBody.put('Cuenta', 'Cuenta de Prueba CPQ');
        requestBody.put('Paisclave', '1');
        requestBody.put('Entfednum', 15);
        requestBody.put('Mponum', 126);
        requestBody.put('IdConvenio', objOpp.INT_Id_Convenio__c);
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        
        // Set the mock request context
        RestContext.request = request;
        
        // Call the REST resource method
        Test.startTest();
        OpportunityEspcMegaRestResource.getOpportunity();
        Test.stopTest();
    }
}