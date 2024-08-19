@IsTest
private with sharing class INT_UploadQuoteControllerTest {
    
     @isTest
    static void testUploadFile() {
        Test.startTest();
        User u = [SELECT Id, Name  FROM User WHERE (Profile.Name = 'Autorizador Excepciones MB') AND IsActive = true LIMIT 1]; 
		Product2 prod= TestDataFactory.createProduct('','','MB','');
        prod.ProductCode = 'Test';
        update prod;
        Account acc = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        TestDataFactory.createStandardEntry(prod,100.0);
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        insert q;
        SBQQ__Quote__c quote = [SELECT Id, Name from SBQQ__Quote__c where id =:q.Id];
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos2(q);
        system.debug('test cotizacion name :' + q.Name );
        SBQQ__QuoteLine__c Qli = TestDataFactory.createQuoteLineItem(q,prod,5.0,2,grupo);
        system.debug('QLI Id::' + QLI.Id);
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Name, SBQQ__ProductCode__c, INT_Nombre_de_producto__c from SBQQ__QuoteLine__c where id =:Qli.Id];
        system.debug('quoteLine::::' + quoteLine.SBQQ__ProductCode__c);
        
        // Set up mock CSV data
        List<INT_UploadQuoteController.CSVData> csvDataList = new List<INT_UploadQuoteController.CSVData>();
        INT_UploadQuoteController.CSVData csvData = new INT_UploadQuoteController.CSVData();
        csvData.GruposdeproductosGrupodeproductosaaprobarId = grupo.Id;
        csvData.CotizacinId = q.Id;
        csvData.PartidadepresupuestoId = String.valueOf(Qli.Id).substring(0, 15);
        csvData.Nmerodepresupuesto = quote.Name;
        csvData.Nombredepartida = quoteLine.Name;
        csvData.Cdigodelproducto = quoteLine.SBQQ__ProductCode__c;
        csvData.Nombredelproducto = quoteLine.INT_Nombre_de_producto__c;
        csvData.UnidaddeMedida = 'Unit';
        csvData.Cantidad = '1';
        csvData.PreciounitariodelistaDivisa = 'USD';
        csvData.Preciounitariodelista = '100';
        csvData.Descuentoadicional = '0';
        csvData.PrecioProyectoUnidaddeVentaMBDivisa = 'USD';
        csvData.PrecioProyectoUnidaddeVentaMB = '100';
        csvDataList.add(csvData);

        String csvDataJson = JSON.serialize(csvDataList);

        
        INT_UploadQuoteController.uploadFile(csvDataJson, grupo.Id);
        Test.stopTest();

        SBQQ__QuoteLine__c updatedQuoteLine = [SELECT Id, SBQQ__ListPrice__c, SBQQ__Discount__c FROM SBQQ__QuoteLine__c WHERE Id = :Qli.Id];
        //System.assertEquals(Decimal.valueOf(100), updatedQuoteLine.SBQQ__ListPrice__c);
        //System.assertEquals(Decimal.valueOf(0), updatedQuoteLine.SBQQ__Discount__c);
    }
    
     @isTest
    static void testUploadFileFail() {
        Test.startTest();
        User u = [SELECT Id, Name  FROM User WHERE (Profile.Name = 'Autorizador Excepciones MB') AND IsActive = true LIMIT 1]; 
		Product2 prod= TestDataFactory.createProduct('','','MB','');
        Account acc = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        TestDataFactory.createStandardEntry(prod,100.0);
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        insert q;
        SBQQ__Quote__c quote = [SELECT Id, Name from SBQQ__Quote__c where id =:q.Id];
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos2(q);
        system.debug('test cotizacion name :' + q.Name );
        SBQQ__QuoteLine__c Qli = TestDataFactory.createQuoteLineItem(q,prod,5.0,2,grupo);
        system.debug('QLI Id::' + QLI.Id);
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Name, SBQQ__ProductCode__c, INT_Nombre_de_producto__c from SBQQ__QuoteLine__c where id =:Qli.Id];
        system.debug('quoteLine::::' + quoteLine.SBQQ__ProductCode__c);
        
        // Set up mock CSV data
        List<INT_UploadQuoteController.CSVData> csvDataList = new List<INT_UploadQuoteController.CSVData>();
        INT_UploadQuoteController.CSVData csvData = new INT_UploadQuoteController.CSVData();
        csvData.GruposdeproductosGrupodeproductosaaprobarId = grupo.Id;
        csvData.CotizacinId = q.Id;
        csvData.PartidadepresupuestoId = Qli.Id;
        csvData.Nmerodepresupuesto = quote.Name;
        csvData.Nombredepartida = quoteLine.Name;
        csvData.Cdigodelproducto = quoteLine.SBQQ__ProductCode__c;
        csvData.Nombredelproducto = quoteLine.INT_Nombre_de_producto__c;
        csvData.UnidaddeMedida = 'Unit';
        csvData.Cantidad = '1';
        csvData.PreciounitariodelistaDivisa = 'USD';
        csvData.Preciounitariodelista = '100';
        csvData.Descuentoadicional = '0';
        csvData.PrecioProyectoUnidaddeVentaMBDivisa = 'USD';
        csvData.PrecioProyectoUnidaddeVentaMB = '100';
        csvDataList.add(csvData);

        String csvDataJson = JSON.serialize(csvDataList);

        
        INT_UploadQuoteController.uploadFile(csvDataJson, grupo.Id);
        Test.stopTest();

        SBQQ__QuoteLine__c updatedQuoteLine = [SELECT Id, SBQQ__ListPrice__c, SBQQ__Discount__c FROM SBQQ__QuoteLine__c WHERE Id = :Qli.Id];
        //System.assertEquals(Decimal.valueOf(100), updatedQuoteLine.SBQQ__ListPrice__c);
        //System.assertEquals(Decimal.valueOf(0), updatedQuoteLine.SBQQ__Discount__c);
    }
    
    @isTest
    static void testUploadFileQuoteNull() {
        Test.startTest();
        User u = [SELECT Id, Name  FROM User WHERE (Profile.Name = 'Autorizador Excepciones MB') AND IsActive = true LIMIT 1]; 
		Product2 prod= TestDataFactory.createProduct('','','MB','');
        Account acc = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        TestDataFactory.createStandardEntry(prod,100.0);
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        insert q;
        SBQQ__Quote__c quote = [SELECT Id, Name from SBQQ__Quote__c where id =:q.Id];
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos2(q);
        system.debug('test cotizacion name :' + q.Name );
        SBQQ__QuoteLine__c Qli = TestDataFactory.createQuoteLineItem(q,prod,5.0,2,grupo);
        system.debug('QLI Id::' + QLI.Id);
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Name, SBQQ__ProductCode__c, INT_Nombre_de_producto__c from SBQQ__QuoteLine__c where id =:Qli.Id];
        system.debug('quoteLine::::' + quoteLine.SBQQ__ProductCode__c);
        
        // Set up mock CSV data
        List<INT_UploadQuoteController.CSVData> csvDataList = new List<INT_UploadQuoteController.CSVData>();
        INT_UploadQuoteController.CSVData csvData = new INT_UploadQuoteController.CSVData();
        csvData.GruposdeproductosGrupodeproductosaaprobarId = grupo.Id;
        csvData.CotizacinId = null;
        csvData.PartidadepresupuestoId = Qli.Id;
        csvData.Nmerodepresupuesto = quote.Name;
        csvData.Nombredepartida = quoteLine.Name;
        csvData.Cdigodelproducto = quoteLine.SBQQ__ProductCode__c;
        csvData.Nombredelproducto = quoteLine.INT_Nombre_de_producto__c;
        csvData.UnidaddeMedida = 'Unit';
        csvData.Cantidad = '1';
        csvData.PreciounitariodelistaDivisa = 'USD';
        csvData.Preciounitariodelista = '100';
        csvData.Descuentoadicional = '0';
        csvData.PrecioProyectoUnidaddeVentaMBDivisa = 'USD';
        csvData.PrecioProyectoUnidaddeVentaMB = '100';
        csvDataList.add(csvData);

        String csvDataJson = JSON.serialize(csvDataList);

        
        INT_UploadQuoteController.uploadFile(csvDataJson, grupo.Id);
        Test.stopTest();

        SBQQ__QuoteLine__c updatedQuoteLine = [SELECT Id, SBQQ__ListPrice__c, SBQQ__Discount__c FROM SBQQ__QuoteLine__c WHERE Id = :Qli.Id];
        //System.assertEquals(Decimal.valueOf(100), updatedQuoteLine.SBQQ__ListPrice__c);
        //System.assertEquals(Decimal.valueOf(0), updatedQuoteLine.SBQQ__Discount__c);
    }
 /*
    /*@isTest
    static void uploadFileExceptionTest() {
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        try {
            AMC_UploadCSVOrderController.uploadFile(opportunityId, 'csvData');
        } catch(AuraHandledException ex) {
            System.assertEquals(false, String.IsBlank(ex.getMessage()));
        }
        Test.stopTest();
    }*/

    /*
    @isTest
    static void uploadFileException2Test() {
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<AMC_UploadCSVOrderController.CSVData> csvData = new List<AMC_UploadCSVOrderController.CSVData>{new AMC_UploadCSVOrderController.CSVData()};
        Test.startTest();
        try {
            AMC_UploadCSVOrderController.uploadFile(opportunityId, JSON.serialize(csvData));
        } catch(AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void uploadFileTest() {
        

        Grupo_de_productos_a_aprobar__c grupo = [SELECT Id FROM Grupo_de_productos_a_aprobar__c];
        
        
        
        
        User u = [SELECT Id, Name  FROM User WHERE (Profile.Name = 'Autorizador Excepciones MB') AND IsActive = true LIMIT 1]; 
        
        String csvData = '[{"GruposdeproductosGrupodeproductosaaprobarId":"'+ grupo.Id+'","QuoteId":"a0z78000000bwzU","QuoteLineId":"a0v7x000000TAQb","QuoteNumber":"Q-00039","LineName":"QL-0001703","ProductCode":"1068490-0","ProductName":"TAPA UNIVERSAL PARA TANQUE WHITE","UnidaddeMedida":"Pza","Quantity":"1","ListUnitPriceDivisa":"MX","ListUnitPrice":"150.4","AdditionalDisc":"4.9","PrecioProyectoUnidaddeVentaMBDivisa":"400.9","PrecioProyectoUnidaddeVentaMB":"355.8"}]'; 
        System.runAs(u) {
            try {
                //INT_UploadQuoteController.uploadFile(csvData, JSON.serialize(csvData));
                
            } catch(AuraHandledException ex) {
            	//System.assertEquals('Script-thrown exception', ex.getMessage());
            }
            
        }
        

        Test.stopTest();
    }*/
    
   
}