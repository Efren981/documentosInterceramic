@isTest
private class TS4_ConsolidadorPDFControllerTest{
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Pais__c pais = TestDataFactory.createPais('1');
        Estado__c estado = TestDataFactory.createEstado(15, '1 15', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado, estado.INT_EntFedNum__c, pais.INT_PaisClave__c, 126, 'Test Ciudad');
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
        Franquicia__c franquicia = TestDataFactory.createFranquicia(colonia, pais.INT_PaisClave__c, estado.INT_EntFedNum__c, ciudad.INT_MpoNum__c, 12);
        Sucursal__c sucursal = TestDataFactory.createSucursal(pais.INT_PaisClave__c, estado.INT_EntFedNum__c, franquicia.INT_EmpNum__c);
        Contact cont = TestDataFactory.createContact('first', 'Test Contact', 'mail1@mail.com', 16, acc, pais, estado, ciudad, colonia);
        cont.INT_Tipo_Contacto__c = 'Contacto principal';
        update cont;
        Product2 product = TestDataFactory.createProduct('Test Product', 'Pza', 'extId');  
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opportunity', 'Propuesta economica', pais, ciudad, estado, colonia, franquicia, sucursal);
        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
        SBQQ__QuoteLine__c lineItem = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
        Calendario_de_Consumo__c testCalendarioConsumo = TestDataFactory.createCalendarioConsumo(opp, oppLineItem);
        Opportunity opp2 = TestDataFactory.createOpportunity(acc, 'Test Opportunity 2', 'Plan de Obra', pais, ciudad, estado, colonia, franquicia, sucursal);
        OpportunityLineItem oppLineItem2 = TestDataFactory.createOpportunityLineItem(opp2, entry, product);
        SBQQ__Quote__c quote2 = TestDataFactory.createQuote();
       
        Grupo_de_productos_a_aprobar__c grupo2 = TestDataFactory.createGrupoProductos();
        SBQQ__QuoteLine__c lineItem2 = TestDataFactory.createQuoteLineItem(quote2, product, 10, 10, grupo2);
        Calendario_de_Consumo__c testCalendarioConsumo2 = TestDataFactory.createCalendarioConsumo(opp2, oppLineItem2);
        OpportunityContactRole OppConRole = TestDataFactory.createOpportunityContactRole(cont, opp2, 'Firma Convenio');
    }

    @isTest
    static void testControllerInitialization(){
        Account testAccount = [SELECT Id
                               FROM Account
                               LIMIT 1];
        Opportunity testOpportunity = [SELECT Id
                                       FROM Opportunity WHERE StageName = 'Propuesta economica'
                                       LIMIT 1];
        Test.startTest();
        PageReference pdfPage = new PageReference('/apex/TS4_ConsolidadorPDFVf');
        pdfPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(pdfPage);

        TS4_ConsolidadorPDFController controller = new TS4_ConsolidadorPDFController();
        controller.account = testAccount;
        controller.oppunity = testOpportunity;
        Test.stopTest();
    }

    @isTest
    static void testControllerOppPlanObra(){
        Opportunity testOpportunity = [SELECT Id
        FROM Opportunity where StageName = 'Plan de Obra'
        LIMIT 1];
        OpportunityContactRole contactTest = [SELECT Id FROM OpportunityContactRole LIMIT 1];
        contactTest.IsPrimary = true;
        update contactTest;
        Product2 testProductCode = [SELECT Id FROM Product2 WHERE Name = 'Test Product'];
        testProductCode.ProductCode='Test';
        update testProductCode;
        Test.startTest();
        PageReference pdfPage = new PageReference('/apex/TS4_ConsolidadorPDFVf');
        pdfPage.getParameters().put('id', testOpportunity.Id);
        Test.setMock(HttpCalloutMock.class, new MockPageReferenceContent());
       
        Test.setCurrentPage(pdfPage);
        TS4_ConsolidadorPDFController controller = new TS4_ConsolidadorPDFController();
        controller.oppunity = testOpportunity;
        
        String e = TS4_ConsolidadorPDFController.getPdfFileAsBase64String(testOpportunity.Id);
		List<TS4_ConsolidadorPDFController.consolidado> el = TS4_ConsolidadorPDFController.fetchRecords(testOpportunity.Id);
		controller.oppunity = TS4_ConsolidadorPDFController.getOpportunity(testOpportunity.Id);
		String i = TS4_ConsolidadorPDFController.getTipo(testOpportunity.Id);
        Test.stopTest();
    }

    @isTest
    static void testControllerException(){
        
        
        PageReference pdfPage = new PageReference('/apex/TS4_ConsolidadorPDFVf');
        pdfPage.getParameters().put('id', 'testOpportunity');
        Test.setMock(HttpCalloutMock.class, new MockPageReferenceContent());
        Test.startTest();
        Test.setCurrentPage(pdfPage);
        Test.stopTest();
    }

    // Mock HTTP callout response
	public class MockPageReferenceContent implements HttpCalloutMock{
		public HttpResponse respond(HttpRequest request){
			HttpResponse response = new HttpResponse();

			response.setHeader('Content-Type', 'application/pdf');
			Blob pdfBlob = Blob.valueOf('%PDF-1.4...'); // Añade un contenido PDF simulado aquí
			response.setBodyAsBlob(pdfBlob);
			response.setStatusCode(200);
			return response;
		}

	}

}