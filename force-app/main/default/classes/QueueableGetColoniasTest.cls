@IsTest
private class QueueableGetColoniasTest {
    @IsTest
    static void testExecute() {
        Pais__c pais = new Pais__c();
        pais.INT_PaisClave__c = '1';
        insert pais;
        
        Estado__c estado = new Estado__c();
        estado.INT_Pais__c = pais.Id;
        estado.INT_PaisClave__c = '1';
        estado.INT_EntFedNum__c = 15;
        estado.INT_External_Id__c = '1 15';
        insert estado;
        
        Ciudad__c testCiudad = new Ciudad__c();
        testCiudad.INT_Estado__c = estado.Id;
        testCiudad.INT_PaisClave__c = '1';
        testCiudad.INT_EntFedNum__c = 15;
        testCiudad.INT_MpoNum__c = 126;
        testCiudad.INT_External_Id__c = '1 15 126';
        insert testCiudad;
        
        // Mock the HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody(
            '{\n' +
            '    "COLONIAS": [\n' +
            '        {\n' +
            '            "COLNUM": 300,\n' +
            '            "NOMBRE": "COLONIA LOS PINOS",\n' +
            '            "NOMBRECOMPLETO": "Los Pinos",\n' +
            '            "PAISCLAVE": "1",\n' +
            '            "ENTFEDNUM": 8,\n' +
            '            "MPONUM": 19,\n' +
            '            "LOCALIDAD": "Chihuahua",\n' +
            '            "LOCNUM": 1,\n' +
            '            "CP": 31416,\n' +
            '            "LAT": 28.594621,\n' +
            '            "LNG": -106.0919419,\n' +
            '            "TIPOASENTA": "Colonia             "\n' +
            '        }\n' +
            '    ],\n' +
            '    "first": {\n' +
            '        "$ref": "https://rkgz1v3qch.execute-api.us-west-2.amazonaws.com/dev/consultacolonias-post/0"\n' +
            '    },\n' +
            '    "next": {\n' +
            '        "$ref": "https://rkgz1v3qch.execute-api.us-west-2.amazonaws.com/dev/consultacolonias-post/1"\n' +
            '    },\n' +
            '    "RESULTADO": "OK"\n' +
            '}'
        );
        
        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new QueueableGetColoniasTest.MockHttpResponseGenerator(mockResponse));
        
        // Enqueue the Queueable job
        Test.startTest();
        QueueableGetColonias queueableJob = new QueueableGetColonias(1);
        System.enqueueJob(queueableJob);
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteInNULL() {
        Pais__c pais = new Pais__c();
        pais.INT_PaisClave__c = '1';
        insert pais;
        
        Estado__c estado = new Estado__c();
        estado.INT_Pais__c = pais.Id;
        estado.INT_PaisClave__c = '1';
        estado.INT_EntFedNum__c = 15;
        estado.INT_External_Id__c = '1 15';
        insert estado;
        
        Ciudad__c testCiudad = new Ciudad__c();
        testCiudad.INT_Estado__c = estado.Id;
        testCiudad.INT_PaisClave__c = '1';
        testCiudad.INT_EntFedNum__c = 15;
        testCiudad.INT_MpoNum__c = 126;
        testCiudad.INT_External_Id__c = '1 15 126';
        insert testCiudad;
        
        // Mock the HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('');
        
        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new QueueableGetColoniasTest.MockHttpResponseGenerator(mockResponse));
        
        // Enqueue the Queueable job
        Test.startTest();
        QueueableGetColonias queueableJob = new QueueableGetColonias(1);
        System.enqueueJob(queueableJob);
        Test.stopTest();
    }
    
    // Inner class to mock the HTTP callout response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}