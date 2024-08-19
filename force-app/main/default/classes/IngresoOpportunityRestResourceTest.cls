@IsTest
private class IngresoOpportunityRestResourceTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Pais__c pais = TestDataFactory.createPais('1234');
        Estado__c estado = TestDataFactory.createEstado(10.0, '1', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado.INT_EntFedNum__c, pais.INT_PaisClave__c);
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
        Franquicia__c franquicia = TestDataFactory.createFranquicia(colonia, pais.INT_PaisClave__c, estado.INT_EntFedNum__c, ciudad.INT_MpoNum__c, 12);
        Sucursal__c sucursal = TestDataFactory.createSucursal(pais.INT_PaisClave__c, estado.INT_EntFedNum__c, franquicia.INT_EmpNum__c);
        Product2 product = TestDataFactory.createProduct('test product', null, null, null);
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opp', 'Acuerdo / Convenio', pais, ciudad, estado, colonia, franquicia, sucursal);
        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
    }

    @IsTest
    static void testUpsertIngresoOpp() {
        /*
        // Create test data
         Account testAccount = new Account(Name = 'Cuenta de Prueba CPQ');
        insert testAccount;
        
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
        
        Sucursal__c suc = new Sucursal__c();
        suc.INT_ColNum__c = 12;
        suc.INT_CP__c = 95780;
        suc.INT_EmpNum__c = 202;
        suc.INT_EntFedNum__c = 30;
        suc.INT_PaisClave__c = '1';
        insert suc;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            UnidadVenta__c = 'Pza',
            INT_External_Id__c = '0001'
        );
        insert testProduct;
        
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(), ///standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPricebookEntry;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Prueba',
            StageName = 'Acuerdo / Convenio',
            INT_Pais__c = pais.Id,
            INT_Ciudad__c = ciu.Id,
            INT_Estado__c = estado.Id,
            INT_Colonia__c = colo.Id,
            INT_Franquicia__c = fran.Id,
            INT_Sucursal__c = suc.Id,
            AccountId = testAccount.Id,
            CloseDate = date.today()+30
            //RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Especificaciones').getRecordTypeId()
        );
        insert testOpportunity;

        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = standardPricebookEntry.Id,
            Product2Id = testProduct.Id,
            Quantity = 10,
            UnitPrice = 100
        );
        insert testOpportunityLineItem;
        */
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1]; 
        // Create a mock request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/upsertIngresoOportunidad';
        request.httpMethod = 'POST';

        // Set the request body
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Object> oportunidades = new List<Object>();

        Map<String, Object> opportunityMap = new Map<String, Object>();
        opportunityMap.put('ID_OPORTUNIDAD', testOpportunity.Id);

        List<Object> productos = new List<Object>();

        Map<String, Object> productMap = new Map<String, Object>();
        productMap.put('ARTCLAVE', '0001');
        productMap.put('INGRESO_FACTURADO', 1000);
        productMap.put('CANTIDAD_FACTURADA', 15);
        productMap.put('MONEDA', 'MXN');

        List<Object> facturas = new List<Object>();

        Map<String, Object> facturaMap = new Map<String, Object>();
        facturaMap.put('EJECUTIVO_VENTAS', 'ALPAEZ');
        facturaMap.put('FECHA_TICKET_VENTA', '05-12-2023');
        facturaMap.put('TICKET_VENTA', '204TECHCO6789');
        facturaMap.put('INGRESO', 1000);
        facturaMap.put('CANTIDAD', 15);

        facturas.add(facturaMap);
        productMap.put('FACTURAS', facturas);

        productos.add(productMap);
        opportunityMap.put('PRODUCTOS', productos);

        List<Object> periodos = new List<Object>();

        Map<String, Object> periodoMap = new Map<String, Object>();
        periodoMap.put('EJERICIO', 2023);
        periodoMap.put('MES', 5);
        periodoMap.put('INGRESO', 5000);

        periodos.add(periodoMap);
        opportunityMap.put('PERIODOS', periodos);

        oportunidades.add(opportunityMap);
        requestBody.put('Oportunidades', oportunidades);
        String requestBodyJson = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(requestBodyJson);

        // Set the mock request
        RestContext.request = request;

        // Call the REST resource method
        Test.startTest();
        IngresoOpportunityRestResource.upsertIngresoOpp();
        Test.stopTest();
    }
    
    
    @IsTest
    static void testUpsertIngresoOppParse(){
        Test.startTest();
        IngresoOpportunityRestResource.parseDate('10-10-2010');
        Test.stopTest();
    }
}