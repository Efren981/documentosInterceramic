@isTest
public class OpportunityRestResourceTest {
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
        cont.INT_Validez_Id_Lealtad__c = 'El ID de la Cuenta INTERPASS no es válido';
        update cont;
        Product2 product = TestDataFactory.createProduct('test product', null, null, null);
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opportunity', 'Plan de Obra', pais, ciudad, estado, colonia, franquicia, sucursal);
        OpportunityContactRole oppContactRole = TestDataFactory.createOpportunityContactRole(cont, opp, 'Oportunidad');
        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
    }

    @isTest
    public static void getOpportunityTest(){
        /*
        Account testAccount = new Account(Name = 'Test Account', INT_RFC__c='VECJ880326XXX');
        insert testAccount;
                
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            LastName = 'Test Contact',
            INT_Tipo_Contacto__c = 'Contacto principal',
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
            StageName = 'Plan de Obra',
            CloseDate = Date.today().addDays(30),
            Pricebook2Id = test.getStandardPricebookId()
        );
        insert testOpportunity;
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            ContactId = testContact.Id,
            OpportunityId = testOpportunity.Id,
            Role = 'Oportunidad'
        );
        insert oppContactRole;
        
        // Create the opportunity line item
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
        // Create test request
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/obtainOpportunityObra/';
        request.httpMethod = 'POST';

        // Set request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', testOpportunity.Id);
        // Add other required fields
        String requestBodyString = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(requestBodyString);

        // Call the REST service
        RestContext.request = request;
        RestContext.response = new RestResponse();

        test.startTest();
        OpportunityRestResource.getOpportunity();
        test.stopTest();

        // Retrieve the response
        /*String responseBodyString = RestContext.response.responseBody.toString();
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(responseBodyString);*/

    }

    @isTest
    public static void getChildOpportunityTest(){

        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Opportunity newOpp = new Opportunity();

        newOpp.Name = 'Child Opp Test Name';
        newOpp.AccountId = testAccount.Id;
        newOpp.Oportunidad_Relacionada__c = testOpportunity.Id;
        newOpp.StageName = 'Plan de Obra';
        newOpp.CloseDate = Date.today().addDays(5);

        insert newOpp;
        
        // Create test request
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/obtainOpportunityObra/';
        request.httpMethod = 'POST';

        // Set request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', testOpportunity.Id);
        // Add other required fields
        String requestBodyString = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(requestBodyString);

        // Call the REST service
        RestContext.request = request;
        RestContext.response = new RestResponse();

        test.startTest();
        OpportunityRestResource.getOpportunity();
        test.stopTest();
    }

    @isTest
    public static void getOpportunityTestFailWithoutId(){
        // Create test request
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/obtainOpportunityObra/';
        request.httpMethod = 'POST';

        // Set request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', '');
        // Add other required fields
        String requestBodyString = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(requestBodyString);

        // Call the REST service
        RestContext.request = request;
        RestContext.response = new RestResponse();

        test.startTest();
        OpportunityRestResource.getOpportunity();
        test.stopTest();
    }

    @isTest
    public static void getOpportunityTestFailWithoutOpp(){
        // Create test request
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/obtainOpportunityObra/';
        request.httpMethod = 'POST';

        // Set request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('OpportunityId', '00678000008NvvpAAZ');
        // Add other required fields
        String requestBodyString = JSON.serialize(requestBody);
        request.requestBody = Blob.valueOf(requestBodyString);

        // Call the REST service
        RestContext.request = request;
        RestContext.response = new RestResponse();

        test.startTest();
        OpportunityRestResource.getOpportunity();
        test.stopTest();
    }
}