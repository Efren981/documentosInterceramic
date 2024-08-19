@IsTest
private class IngresoRestResourceTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount('FWY', '2223258974', 'fwy@freewayconsulting.com', 'DOEJ891011ABC');
        Pais__c pais = TestDataFactory.createPais('1');
        Estado__c estado = TestDataFactory.createEstado(15, '1 15', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado, estado.INT_EntFedNum__c, pais.INT_PaisClave__c, 126, 'Ciudad Test');
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
        Franquicia__c franquicia = TestDataFactory.createFranquicia(colonia, pais.INT_PaisClave__c, estado.INT_EntFedNum__c, ciudad.INT_MpoNum__c, 202);
        Sucursal__c sucursal = TestDataFactory.createSucursal(pais.INT_PaisClave__c, estado.INT_EntFedNum__c, franquicia.INT_EmpNum__c);
    }

    @isTest
    static void testCreateIngreso() {
        Account acc = [SELECT Id, Name, INT_RFC__c FROM Account LIMIT 1];
        System.debug('ACC: ' + acc);

        Contact newCto = new Contact();
        newCto.FirstName = 'F';
        newCto.LastName = 'WY';
        newCto.AccountId = acc.Id;
        newCto.Title = 'test';
        newCto.Phone = '1231231231';
        newCto.MobilePhone = '1231231231';
        newCto.Email = 'test@test.com';
        
        insert newCto;
        
        Contact afCto = [SELECT Id, Name FROM Contact Where Id =: newCto.Id LIMIT 1];
        System.debug('afCto: ' + afCto);
        
        String jsonString = '{'+
            '"VENTAS": ['+
                '{'+
                    '"nombrecte": "F WY",'+
                    '"telefonocte": "2223258974",'+
                    '"celularcte": "2223258974",'+
                    '"emailcte": "fwy@freewayconsulting.com",'+
                    '"rfccte": "DOEJ891011ABC",'+
                    '"pasiclave": "1",'+
                    '"entfednumcte": 15,'+
                    '"mponumcte": 106,'+
                    '"colnumcte": 221,'+
                    '"montoventa": 50000,'+
                    '"anio": 2023,'+
                    '"mes": 5,'+
                    '"dia": 1,'+
                    '"canalventa": "",'+
                    '"folioTicket": "204TECHCO56879"'+
                '}'+
            ']'+
        '}';
        
        // Create a new RestRequest instance and set the request body
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/upsertIngresos/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        
        // Call the createIngreso method in the IngresoRestResource class
        Test.startTest();
        IngresoRestResource.createIngreso();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateIngresoFail() { 
        String jsonString = '{'+
            '"VENTAS": ['+
                '{'+
                    '"nombrecte": "FWY",'+
                    '"telefonocte": "2223258974",'+
                    '"celularcte": "2223258974",'+
                    '"emailcte": "fwy@freewayconsulting.com",'+
                    '"rfccte": "DOEJ891011ABC",'+
                    '"pasiclave": "1",'+
                    '"entfednumcte": 15,'+
                    '"mponumcte": 106,'+
                    '"colnumcte": 221,'+
                    '"montoventa": 50000,'+
                    '"anio": 2023,'+
                    '"mes": 5,'+
                    '"dia": 1,'+
                    '"canalventa": "",'+
                    '"folioTicket": "204TECHCO56879"'+
                '}'+
            ']'+
        '}';
        
        // Create a new RestRequest instance and set the request body
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/upsertIngresos/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        
        // Call the createIngreso method in the IngresoRestResource class
        Test.startTest();
        IngresoRestResource.createIngreso();
        Test.stopTest();
    }
}