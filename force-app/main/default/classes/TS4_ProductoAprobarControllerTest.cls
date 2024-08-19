@isTest
public class TS4_ProductoAprobarControllerTest{
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
		product.ProductCode = 'ASDASD';
		update product;
		PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
		Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opportunity', 'Propuesta economica', pais, ciudad, estado, colonia, franquicia, sucursal);
		OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
		SBQQ__Quote__c quote = TestDataFactory.createQuote();
		Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
		SBQQ__QuoteLine__c lineItem = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
		Calendario_de_Consumo__c testCalendarioConsumo = TestDataFactory.createCalendarioConsumo(opp, oppLineItem);
	}

	@isTest
	public static void testMethod1(){
		List<SBQQ__QuoteLine__c> queline = [SELECT Id
		FROM SBQQ__QuoteLine__c
		LIMIT 1];
		Grupo_de_productos_a_aprobar__c groupAprobar = [SELECT Id
		                                                FROM Grupo_de_productos_a_aprobar__c
		                                                LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MockPageReferenceContent());
		Test.startTest();
		PageReference pdfPage = new PageReference('/apex/TS4_ProductosAprobarVf');
		pdfPage.getParameters().put('id', groupAprobar.Id);
		Test.setCurrentPage(pdfPage);
		String e = TS4_ProductoAprobarController.getPdfFileAsBase64String(groupAprobar.Id);
		List<TS4_ProductoAprobarController.productosAprobar> el = TS4_ProductoAprobarController.fetchRecords(groupAprobar.Id);
		groupAprobar = TS4_ProductoAprobarController.getGrupoAprobar(groupAprobar.Id);
		TS4_ProductoAprobarController controller = new TS4_ProductoAprobarController();
        controller.grupoAprobar = groupAprobar;
        controller.quoteLine = queline;

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