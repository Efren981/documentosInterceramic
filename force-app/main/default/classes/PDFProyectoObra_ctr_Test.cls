@isTest
public class PDFProyectoObra_ctr_Test {
    @TestSetup
    static void makeData(){
        Carta__c carta = TestDataFactory.createCarta('CARTA DE TÉRMINOS Y CONDICIONES DE DESCUENTOS', 'NOMBRE_CUENTA OPORTUNIDAD CONTACTO_PRINCIPAL', '1. MATERIAL.', '2. ENTREGA.', '3. DESCUENTOS.', '4. PROPUESTA INTEGRAL.', '5. VIGENCIA.', '6. INCUMPLIMIENTO.', '7. CONFIDENCIALIDAD.', '', '', '', '', '');
        carta.ContactoPrincipal__c = 'CONTACTO_PRINCIPAL';
        update carta;
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
    }

    @isTest
    static void testPDFProyectoObra_ctr() {
        /*
        Carta__c carta = new Carta__c(
            Name = 'CARTA DE TÉRMINOS Y CONDICIONES DE DESCUENTOS',
            INT_Encabezado__c = 'NOMBRE_CUENTA OPORTUNIDAD CONTACTO_PRINCIPAL',
            INT_Condicion_1__c = '',
            INT_Condicion_2__c = '',
            INT_Condicion_3__c = '',
            INT_Condicion_4__c = '',
            INT_Condicion_5__c = '',
            INT_Condicion_6__c = '',
            INT_Condicion_7__c = '',
            INT_Firma_y_Fecha__c = '',
            INT_Anexo_A__c = '',
            INT_Anexo_A_contacto__c = '',
            INT_Anexo_A_condiciones__c = '',
            INT_Anexo_B__c = ''
        );
        insert carta;
        
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
                
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            LastName = 'Test Contact',
            INT_Tipo_Contacto__c = 'Contacto principal'
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            UnidadVenta__c = 'Pza'
        );
        insert testProduct;
        
        // Create a standard pricebook entry for the product
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(), ///standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPricebookEntry;
        
        // Use the created standard pricebook in the opportunity and opportunity line item creation
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Propuesta economica',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = test.getStandardPricebookId()
        );
        insert testOpportunity;
        
        // Create the opportunity line item
        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = standardPricebookEntry.Id,
            Product2Id = testProduct.Id,
            Quantity = 10,
            UnitPrice = 100
        );
        insert testOpportunityLineItem;
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        insert testQuote;
        
        SBQQ__QuoteLine__c testQuoteLineItem = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 5,
            SBQQ__ListPrice__c = 200,
            SBQQ__Discount__c = 20
        );
        insert testQuoteLineItem;
        
        Calendario_de_Consumo__c testCalendarioConsumo = new Calendario_de_Consumo__c(
            INT_Nombre_Producto__c = 'Test Product',
            INT_Mes__c = 1,
            INT_Metros_Cuadrados__c = 50,
            INT_Cantidad__c = 5,
            INT_Oportunidad__c = testOpportunity.Id,
            INT_Producto__c = testOpportunityLineItem.Id
        );
        insert testCalendarioConsumo;
        */
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        OpportunityContactRole newOCR = new OpportunityContactRole();
        newOCR.OpportunityId = testOpportunity.Id;
        newOCR.ContactId = testCon.Id;
        newOCR.IsPrimary = true;
        insert newOCR;
        // Instantiate the class
        Test.startTest();
        PageReference pdfPage = new PageReference('/apex/PDFProyectoObra_vfp');
        pdfPage.getParameters().put('id', testOpportunity.Id);
        Test.setCurrentPage(pdfPage);
        PDFProyectoObra_ctr pdfProyectoObraCtr = new PDFProyectoObra_ctr();
        Test.stopTest();
    }
}