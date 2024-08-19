/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-11-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-31-2023   emeza@freewayconsulting.com   Initial Version
 * 2.0   09-09-2023   esalas@freewayconsulting.com  Adding methods to create Quotes and LineItems
 * 3.0   09-18-2023   esalas@freewayconsulting.com  Adding methods refactor all org test without setUp
 **/
@isTest
public with sharing class TestDataFactory {
    public static Opportunity createOpportunity(Account acc){
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            INT_Fecha_inicio__c = Date.today().addDays(-5),
            AccountId = acc.Id
        );
        insert testOpportunity;
        return testOpportunity;
    }

    public static Opportunity createOpportunity(Account acc, String name, String stageName, Pais__c pais, Ciudad__c ciudad, Estado__c estado, Colonia__c colonia, Franquicia__c franquicia, Sucursal__c sucursal) {
        Opportunity testOpportunity = new Opportunity(
            Name = name,
            StageName = stageName,
            INT_Pais__c = pais.Id,
            INT_Ciudad__c = ciudad.Id,
            INT_Estado__c = estado.Id,
            INT_Colonia__c = colonia.Id,
            INT_Franquicia__c = franquicia.Id,
            INT_Sucursal__c = sucursal.Id,
            CloseDate = Date.today()+30,
            INT_Fecha_inicio__c = Date.today().addDays(-5),
            AccountId = acc.Id,
            Tipo_de_cotizacion__c = 'Descuento'
        );
        insert testOpportunity;
        return testOpportunity;
    }

    @IsTest
    public static void createContentVersion(){
        ContentVersion contentVersion = new ContentVersion(
          Title          = 'a picture',
          PathOnClient   = 'Pic.jpg',
          VersionData    = Blob.valueOf('Test Content'),
          IsMajorVersion = true);
        insert contentVersion;

    }
    
    public static void createDocumentLink(Id recordId, Id docId){
    //create ContentDocumentLink  record
    ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = docId;
        cdl.shareType = 'V';
        cdl.visibility = 'AllUsers';
        insert cdl;
    }

    @IsTest
    public static Account createAccount(){
        Account testAccount = new Account(
            Name = 'Cuenta de Prueba CPQ', 
            Phone = '0123456789',
            INT_Clasificacion__c = 'Nacional',
            INT_RFC__c='VECJ880326XXX',
            INT_Tipo_Cuenta__c = 'Inversionista',
            INT_Presencia__c = 'Nacional',
            INT_Giro_Negocio__c = 'Casas y Residencias',
            INT_Tipo_Persona__c = 'Física',
            INT_Calle__c = 'calle test',
            INT_CP__c = 'cp',
            INT_NumExt__c = 'num ext',
            INT_Colonia__c = createColonia(10, '01', 10).Id
        );
        insert testAccount;
        return testAccount;
    }

    public static Account createAccount(String name, String phone, String email, String rfc){
        Account testAccount = new Account(
            Name = name, 
            Phone = phone,
            INT_Clasificacion__c = 'Nacional',
            INT_RFC__c = rfc,
            INT_Tipo_Cuenta__c = 'Inversionista',
            INT_Presencia__c = 'Nacional',
            INT_Giro_Negocio__c = 'Casas y Residencias',
            INT_Tipo_Persona__c = 'Física',
            INT_Calle__c = 'calle test',
            INT_CP__c = 'cp',
            INT_NumExt__c = 'num ext',
            INT_email__c = email,
            INT_Colonia__c = createColonia(10, '01', 10).Id
        );
        insert testAccount;
        return testAccount;
    }

    public static Grupo_de_productos_a_aprobar__c createGrupoProductos2(SBQQ__Quote__c quote) {
        Grupo_de_productos_a_aprobar__c grupo = new Grupo_de_productos_a_aprobar__c(
            Name = 'Grupo de Prueba CPQ',
            Cotizacion__c = quote.Id,
        	Nivel__c = 6,
            CurrencyIsoCode = 'MXN',
            Tipo_de_producto__c = 'MB',
            Fecha_Ultima_Aprobacion__c = System.now(),
            Excepcion__c = true
        );
        insert grupo;
        return grupo;
    }
    public static Grupo_de_productos_a_aprobar__c createGrupoProductos() {
        Grupo_de_productos_a_aprobar__c grupo = new Grupo_de_productos_a_aprobar__c(
            Name = 'Grupo de Prueba CPQ'
        );
        insert grupo;
        return grupo;
    }

    public static Product2 createProduct(String name, String description, String productType, String isoCode) {
        Product2 product = new Product2(
            Name = String.isBlank(name) == true ? 'Product Test' : name,
            Description = String.isBlank(description) == true ? 'Product Test Description' : description,
            IsActive = true,
            CurrencyIsoCode = String.isBlank(isoCode) == true ? 'MXN' : isoCode,
            TipoProducto__c = String.isBlank(productType) == true ? 'ESTRATEGICO' : productType
        );
        insert product;
        return product;
    }

    public static Product2 createProduct(String name, String unidadVenta, String externalId) {
        Product2 product = new Product2(
            Name = String.isBlank(name) == true ? 'Product Test' : name,
            INT_External_Id__c = String.isBlank(externalId) == true ? 'external' : externalId,
            UnidadVenta__c = String.isBlank(unidadVenta) == true ? 'Pza' : unidadVenta
        );
        insert product;
        return product;
    }

    public static PricebookEntry createStandardEntry(Product2 product, Decimal unitPrice) {
        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert standardPricebookEntry;
        return standardPricebookEntry;
    }

    public static SBQQ__Quote__c createQuote2(Account acc, Opportunity opp) {
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
        	SBQQ__Account__c = acc.Id,
        	SBQQ__Opportunity2__c = opp.Id,
        	SBQQ__PriceBook__c = Test.getStandardPricebookId(),
        	SBQQ__Type__c = 'Quote',
        	SBQQ__Status__c = 'Draft',
        	CurrencyIsoCode = 'MXN'
        );
        	
        
        insert quote;
        system.debug('Quote Name::: '+ quote.Name);
        return quote;
    }
    
    public static SBQQ__Quote__c createQuote() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        return quote;
    }

    public static SBQQ__QuoteLine__c createQuoteLineItem(SBQQ__Quote__c quote, Product2 product, Decimal discount, Decimal quantity, Grupo_de_productos_a_aprobar__c grupo) {
        SBQQ__QuoteLine__c lineItem = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = product.Id,
            SBQQ__Discount__c = discount,
            SBQQ__Quantity__c = quantity,
            Grupos_de_productos__c = grupo.Id,
            Estado_Aprobacion_Nivel_1__c = null
        );
        try{
            insert lineItem;
        }catch(Exception e){
            
        }
        return lineItem;
    }

    public static User createUser(Profile p, String userName, String mail) {   
        User us = new User(
            Username = userName,
            LastName = 'lastName',
            Email = mail,
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert us;
        return us;
    }

    public static Reassign_Config__c createReassignConfig(Integer numberOfHours) {
        Reassign_Config__c config = new Reassign_Config__c(
            Reassign_after__c = numberOfHours
        );
        insert config;
        return config;
    }

    public static OpportunityLineItem createOpportunityLineItem(Opportunity opp, PricebookEntry pricebook, Product2 product) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pricebook.Id,
            Product2Id = product.Id,
            Quantity = 10,
            UnitPrice = 100
        );
        insert oppLineItem;
        return oppLineItem;
    }

    public static Calendario_de_Consumo__c createCalendarioConsumo(Opportunity opp, OpportunityLineItem oppLineItem) {
        Calendario_de_Consumo__c calendario = new Calendario_de_Consumo__c(
            INT_Nombre_Producto__c = 'Test Product',
            INT_Mes__c = 1,
            INT_Metros_Cuadrados__c = 50,
            INT_Ejercicio__c = 2024,
            INT_Cantidad__c = 5,
            INT_Oportunidad__c = opp.Id,
            INT_Producto__c = oppLineItem.Id
        );
        insert calendario;
        return calendario;
    }

    public static Pais__c createPais(String clave) {
        Pais__c pais = new Pais__c(
            INT_PaisClave__c = clave
        );
        insert pais;
        return pais;
    }

    public static Estado__c createEstado(Decimal entidadFed, String extId, String clavePais, Pais__c pais) {
        Estado__c estado = new Estado__c(
            INT_EntFedNum__c = entidadFed,
            INT_External_Id__c = extId,
            INT_Pais__c = pais.Id,
            INT_PaisClave__c = clavePais
        );
        insert estado;
        return estado;
    }

    public static Ciudad__c createCiudad(Decimal entidadFederativa, String clavePais) {
        Ciudad__c ciudad = new Ciudad__c(
            Name = 'Ciudad Test',
            INT_EntFedNum__c = entidadFederativa,
            INT_PaisClave__c = clavePais,
            INT_MpoNum__c = 1
        );
        insert ciudad;
        return ciudad;
    }

    public static Ciudad__c createCiudad(Estado__c estado, Decimal entidadFederativa, String clavePais, Decimal numMunicipio, String name) {
        Ciudad__c ciudad = new Ciudad__c(
            Name = name,
            INT_EntFedNum__c = entidadFederativa,
            INT_PaisClave__c = clavePais,
            INT_MpoNum__c = numMunicipio,
            INT_Estado__c =  estado.Id
        );
        insert ciudad;
        return ciudad;
    }

    public static Colonia__c createColonia(Decimal entidadFederativa, String clavePais, Decimal numMunicipio) {
        Colonia__c colonia = new Colonia__c(
            Name = 'Colonia Test',
            INT_MpoNum__c = numMunicipio,
            INT_EntFedNum__c = entidadFederativa,
            INT_PaisClave__c = clavePais
        );
        insert colonia;
        return colonia;
    }

    public static Franquicia__c createFranquicia(Colonia__c colonia, String clavePais, Decimal entFed, Decimal mpoNum, Decimal empNum) {
        Franquicia__c franquicia = new Franquicia__c(
            INT_PaisClave__c = clavePais,
            INT_EntFedNum__c = entFed,
            INT_MpoNum__c = mpoNum,
            INT_EmpNum__c = empNum,
            INT_Colonia__c = colonia.Id
        );
        insert franquicia;
        return franquicia;
    }

    public static Sucursal__c createSucursal(String clavePais, Decimal entFed, Decimal empNum) {
        Sucursal__c sucursal = new Sucursal__c(
            INT_ColNum__c = 12,
            INT_CP__c = 09720,
            INT_EmpNum__c = empNum,
            INT_EntFedNum__c = entFed,
            INT_PaisClave__c = clavePais
        );
        insert sucursal;
        return sucursal;
    }

    public static Contact createContact(String firstName, String lastName, String email, Integer idInterface, Account acc, Pais__c pais, Estado__c estado, Ciudad__c ciudad, Colonia__c colonia) {
        Contact contc = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            INT_Id_Interface__c = idInterface,
            Title = 'Titulo',
            AccountId = acc.Id,
            Phone = '5512345678',
            MobilePhone = '5512345679',
            INT_Pais__c = pais.Id, 
            INT_Estado__c = estado.Id, 
            INT_Ciudad__c = ciudad.Id, 
            INT_Colonia__c = colonia.Id, 
            INT_Calle__c = 'Calle', 
            INT_CP__c = 'CP', 
            INT_NumExt__c = 'numExt'
        );
        insert contc;
        return contc;
    }

    public static Lead createLead(String firstName, String lastName, String email, Decimal idInterface) {
        Lead leadRec = new Lead(
            FirstName = firstName,    
            LastName = lastName,
            Email = email,
            INT_Id_Interface__c = idInterface
        );
        insert leadRec;
        return leadRec;
    }

    public static Lead createLeadToConvert(String firstName, String lastName, String email, Decimal idInterface, Pais__c pais, Estado__c estado, Ciudad__c ciudad, Colonia__c colonia) {
        Lead leadRec = new Lead(
            FirstName = firstName,    
            LastName = lastName,
            Email = email,
            INT_Id_Interface__c = idInterface,
            INT_RFC__c = 'SIWN981214UY2',
            Phone = '5548297461',
            MobilePhone = '5548297461',
            INT_Clasificacion__c = 'Nacional',
            INT_Presencia__c = 'Nacional',
            INT_Giro_Negocio__c = 'Casas y Residencias',
            INT_Tipo_Persona__c = 'Física',
            INT_Calle__c = 'calle test',
            INT_CP__c = 'cp',
            INT_NumExt__c = 'num ext',
            INT_Colonia__c = colonia.Id,
            INT_Pais__c = pais.Id,
            INT_Estado__c = estado.Id,
            INT_Ciudad__c = ciudad.Id,
            Company = 'Test Company Name',
            LeadSource='Facebook',
            Title = 'Test Title',
            Status = 'Acercamiento',
            INT_Tipo_Prospecto__c = 'Inversionista',
            Salutation = 'Mr.'
        );
        insert leadRec;
        return leadRec;
    }

    public static OpportunityContactRole createOpportunityContactRole(Contact cont, Opportunity opp, String role) {
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            ContactId = cont.Id,
            OpportunityId = opp.Id,
            Role = role
        );
        insert oppContactRole;
        return oppContactRole;
    }

    public static Carta__c createCarta(String Name, String encabezado, String cond1, String cond2, String cond3, String cond4, String cond5, String cond6, String cond7, String firmaYfecha, String anexoA, String anexoACont, String anexoACond, String anexoB) {
        Carta__c carta = new Carta__c(
            Name = name,
            INT_Encabezado__c = encabezado,
            INT_Condicion_1__c = cond1,
            INT_Condicion_2__c = cond2,
            INT_Condicion_3__c = cond3,
            INT_Condicion_4__c = cond4,
            INT_Condicion_5__c = cond5,
            INT_Condicion_6__c = cond6,
            INT_Condicion_7__c = cond7,
            INT_Firma_y_Fecha__c = firmaYfecha,
            INT_Anexo_A__c = anexoA,
            INT_Anexo_A_contacto__c = anexoACont,
            INT_Anexo_A_condiciones__c = anexoACond,
            INT_Anexo_B__c = anexoB
        );
        insert carta;
        return carta;
    }
    
    public static void createBaseDataApprobalProccess(){
        
        Colonia__c objC = new Colonia__c();
        objC.Name = 'TestColoniaName';
        
        insert objC;
        
        Account acc = new Account();
        //acc.FirstName = 'TestAccName';
        //acc.LastName = 'TestAccLastName';
        acc.Name = 'testAccName';
        //acc.PersonEmail = 'test@test.com';
        acc.Phone = '5500550055';
        acc.INT_Tipo_Cuenta__c = 'Constructora';
        acc.INT_Presencia__c = 'Nacional';
        acc.INT_Giro_Negocio__c = 'Gobierno';
        acc.INT_Tipo_Persona__c = 'Moral';
        acc.INT_Calle__c = 'testAddress';
        acc.INT_CP__c = '42780';
        acc.INT_NumExt__c = '11';
        acc.INT_Clasificacion__c = 'Nacional';
        acc.INT_RFC__c = 'TES127609S7S';
        acc.INT_Canal_Venta__c = 'Especificaciones';
		acc.INT_Colonia__c = objC.Id;

        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Prueba niveles aprobacion';
        opp.StageName = 'Propuesta económica';
        opp.AccountId = acc.Id;
        opp.CloseDate =  Date.TODAY().addDays(5);

        insert opp;

        SBQQ__Quote__c objQ = new SBQQ__Quote__c();
        objQ.SBQQ__Account__c = acc.Id;
        objQ.SBQQ__Opportunity2__c = opp.Id;
        objQ.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        objQ.SBQQ__Type__c = 'Quote';
        objQ.SBQQ__Status__c = 'Draft';
        objQ.CurrencyIsoCode = 'MXN';

        insert objQ;

        List<Product2> lstP = new List<Product2>();

        Product2 p1 = new Product2();
        p1.Name = 'testProductUno';
        p1.ProductCode = 'CU.COSC.SDBR.300M.SILI1';
        p1.CurrencyIsoCode = 'MXN';
        p1.INT_Clasificacion__c = 'PREMIUM';
        p1.TipoProducto__c = 'MATERIAL DE INSTALACION';
        p1.INT_TIPOCPQ__c = 'NO';
        p1.IsActive = true;
        lstP.add(p1);

        Product2 p2 = new Product2();
        p2.Name = 'testProductDos';
        p2.ProductCode = 'CU.COSC.SDBR.300M.SILI2';
        p2.CurrencyIsoCode = 'MXN';
        p2.INT_Clasificacion__c = 'DESCONTINUADO';
        p2.TipoProducto__c = 'MATERIAL DE INSTALACION';
        p2.INT_TIPOCPQ__c = 'NO';
        p2.IsActive = true;
        p2.INT_Status__c = 'DESCONTINUADO';
        lstP.add(p2);

        Product2 p3 = new Product2();
        p3.Name = 'testProductTres';
        p3.ProductCode = 'CU.COSC.SDBR.300M.SILI3';
        p3.CurrencyIsoCode = 'MXN';
        p3.INT_Clasificacion__c = 'ECONOMICO';
        p3.TipoProducto__c = 'MATERIAL DE INSTALACION';
        p3.INT_TIPOCPQ__c = 'NO';
        p3.IsActive = true;
        lstP.add(p3);

        Product2 p4 = new Product2();
        p4.Name = 'testProductCuatro';
        p4.ProductCode = 'CU.COSC.SDBR.300M.SILI4';
        p4.CurrencyIsoCode = 'MXN';
        p4.INT_Clasificacion__c = 'OTROS';
        p4.TipoProducto__c = 'TEST PRODUCT TYPE';
        p4.INT_TIPOCPQ__c = 'NO';
        p4.IsActive = true;
        lstP.add(p4);
        
        Product2 p5 = new Product2();
        p5.Name = 'testProductCinco';
        p5.ProductCode = 'CU.COSC.SDBR.300M.SILI5';
        p5.CurrencyIsoCode = 'MXN';
        p5.INT_Clasificacion__c = 'OTROS';
        p5.TipoProducto__c = 'TEST PRODUCT TYPE';
        p5.INT_TIPOCPQ__c = 'NO';
        p5.IsActive = true;
        lstP.add(p5);

        insert lstP;

        List<SBQQ__QuoteLine__c> lstObjQL = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c objQL1 = new SBQQ__QuoteLine__c();
        objQL1.SBQQ__Quote__c = objQ.Id;
        objQL1.SBQQ__Product__c = p1.Id;
        objQL1.SBQQ__Number__c = 1;
        objQL1.SBQQ__Quantity__c = 50;
        objQL1.SBQQ__Discount__c = 1.0;
        objQL1.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL1);

        SBQQ__QuoteLine__c objQL2 = new SBQQ__QuoteLine__c();
        objQL2.SBQQ__Quote__c = objQ.Id;
        objQL2.SBQQ__Product__c = p2.Id;
        objQL2.SBQQ__Number__c = 2;
        objQL2.SBQQ__Quantity__c = 50;
        objQL2.SBQQ__Discount__c = 1.0;
        objQL2.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL2);

        SBQQ__QuoteLine__c objQL3 = new SBQQ__QuoteLine__c();
        objQL3.SBQQ__Quote__c = objQ.Id;
        objQL3.SBQQ__Product__c = p3.Id;
        objQL3.SBQQ__Number__c = 3;
        objQL3.SBQQ__Quantity__c = 50;
        objQL3.SBQQ__Discount__c = 50.0;
        objQL3.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL3);

        SBQQ__QuoteLine__c objQL4 = new SBQQ__QuoteLine__c();
        objQL4.SBQQ__Quote__c = objQ.Id;
        objQL4.SBQQ__Product__c = p4.Id;
        objQL4.SBQQ__Number__c = 4;
        objQL4.SBQQ__Quantity__c = 50;
        objQL4.SBQQ__Discount__c = 1.0;
        objQL4.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL4);
        
        SBQQ__QuoteLine__c objQL5 = new SBQQ__QuoteLine__c();
        objQL5.SBQQ__Quote__c = objQ.Id;
        objQL5.SBQQ__Product__c = p5.Id;
        objQL5.SBQQ__Number__c = 5;
        objQL5.SBQQ__Quantity__c = 50;
        objQL5.SBQQ__Discount__c = 50.0;
        objQL5.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL5);
        
        /*SBQQ__QuoteLine__c objQL6 = new SBQQ__QuoteLine__c();
        objQL6.SBQQ__Quote__c = objQ.Id;
        objQL6.SBQQ__Product__c = p1.Id;
        objQL6.SBQQ__Number__c = 6;
        objQL6.SBQQ__Quantity__c = 50;
        objQL6.SBQQ__Discount__c = 11.0;
        objQL6.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL6);*/
        
        /*SBQQ__QuoteLine__c objQL7 = new SBQQ__QuoteLine__c();
        objQL7.SBQQ__Quote__c = objQ.Id;
        objQL7.SBQQ__Product__c = p1.Id;
        objQL7.SBQQ__Number__c = 7;
        objQL7.SBQQ__Quantity__c = 50;
        objQL7.SBQQ__Discount__c = 13.0;
        objQL7.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL7);*/
        
        /*SBQQ__QuoteLine__c objQL8 = new SBQQ__QuoteLine__c();
        objQL8.SBQQ__Quote__c = objQ.Id;
        objQL8.SBQQ__Product__c = p1.Id;
        objQL8.SBQQ__Number__c = 8;
        objQL8.SBQQ__Quantity__c = 50;
        objQL8.SBQQ__Discount__c = 16.0;
        objQL8.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL8);*/
        
        /*SBQQ__QuoteLine__c objQL9 = new SBQQ__QuoteLine__c();
        objQL9.SBQQ__Quote__c = objQ.Id;
        objQL9.SBQQ__Product__c = p1.Id;
        objQL9.SBQQ__Number__c = 9;
        objQL9.SBQQ__Quantity__c = 50;
        objQL9.SBQQ__Discount__c = 20.0;
        objQL9.SBQQ__ProratedListPrice__c = 3000;
        lstObjQL.add(objQL9);*/

        try{
            insert lstObjQL;
        }catch(Exception e){
            
        }
        

        List<Grupo_de_productos_a_aprobar__c> lstGPA = new List<Grupo_de_productos_a_aprobar__c>();
        
        Grupo_de_productos_a_aprobar__c GPA = new Grupo_de_productos_a_aprobar__c();
        GPA.Cotizacion__c = objQ.Id;
        GPA.Nivel__c = 1;
        GPA.CurrencyIsoCode = 'MXN';
        GPA.Tipo_de_producto__c = 'NO';
        GPA.Fecha_Ultima_Aprobacion__c = System.now();
        //GPA.Excepcion__c = true;
        lstGPA.add(GPA);
        
        Grupo_de_productos_a_aprobar__c GPA2 = new Grupo_de_productos_a_aprobar__c();
        GPA2.Cotizacion__c = objQ.Id;
        GPA2.Nivel__c = 6;
        GPA2.CurrencyIsoCode = 'MXN';
        GPA2.Tipo_de_producto__c = 'MB';
        GPA2.Fecha_Ultima_Aprobacion__c = System.now();
        GPA2.Excepcion__c = true;
        lstGPA.add(GPA2);

        insert lstGPA;
    }
}