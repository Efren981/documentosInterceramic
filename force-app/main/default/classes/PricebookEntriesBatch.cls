public class PricebookEntriesBatch implements Database.Batchable<sObject>, Database.Stateful {
	public final String sQuery;
    public final String PricebookId;
    public final String Moneda;
    public final List<Object> lstProductObject;
    public final List<String> listArtClave;
    public List<ProductPrices> listProductPrices = new List<ProductPrices>();
    public String sErrores = '';
    
    public PricebookEntriesBatch(String q, String pricebook, String Mon, List<Object> lObject, List<String> artProd){
        sQuery = q;
        PricebookId = pricebook;
        Moneda = Mon;
        lstProductObject = lObject; 
        listArtClave = artProd;
        listProductPrices = new List<ProductPrices>();
        sErrores = '';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('sQuery: ' + sQuery);
        return Database.getQueryLocator(sQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('Scope: ' + scope);
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        Integer iUpsertedCount = 0;
        Integer iFailedCount = 0;
        String sErrors = '';
        Id standarPricebook;
        if(test.isRunningTest()){
            standarPricebook = Test.getStandardPricebookId();
        }else{
            standarPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        }
                
        Map<String, String> mapProductExtId = new Map<String, String>();
        Map<String, PricebookEntry> mapPricebookEntry = new Map<String, PricebookEntry>();
        Map<String, PricebookEntry> mapStandardPricebookEntry = new Map<String, PricebookEntry>();
        Map<Id, String> mapProductIdExtId = new Map<Id, String>();
        List<Product2> listProduct2 = new List<Product2>();
        listProduct2 = (List<Product2>) scope;
                
        Set<Id> setProduct2Id = new set<Id>();
        for(Product2 iProd : listProduct2){
            mapProductExtId.put(iProd.INT_External_Id__c, iProd.Id);
            mapProductIdExtId.put(iProd.Id, iProd.INT_External_Id__c);
            mapPricebookEntry.put(iProd.INT_External_Id__c, null);
            setProduct2Id.add(iProd.Id);
        }
        
        for(PricebookEntry iPrice : [SELECT Id, Product2Id, Product2.INT_External_Id__c, CurrencyIsoCode, IsActive, UnitPrice, Pricebook2Id, ProductCode 
                                     FROM PricebookEntry 
                                     WHERE Product2.INT_External_Id__c IN: listArtClave AND Product2Id IN: setProduct2Id AND Pricebook2Id =: standarPricebook])
        {
            mapStandardPricebookEntry.put(iPrice.Product2.INT_External_Id__c, iPrice);
        }
        
        for(PricebookEntry iPrice : [SELECT Id, Product2Id, Product2.INT_External_Id__c, CurrencyIsoCode, IsActive, UnitPrice, Pricebook2Id, ProductCode 
                                     FROM PricebookEntry 
                                     WHERE Product2.INT_External_Id__c IN: listArtClave AND Pricebook2Id =: PricebookId AND Product2Id IN: setProduct2Id])
        {
            mapPricebookEntry.put(iPrice.Product2.INT_External_Id__c, iPrice);
        }
        
        System.debug('mapPricebookEntry ' + mapPricebookEntry);

		List<PricebookEntry> listPricebookEntry = new List<PricebookEntry>();
        List<String> listErrores = new List<String>();
        
        for(Object productoObject : lstProductObject) {
            Map<String, Object> productoMap = (Map<String, Object>) productoObject;
            String artclave = (String) productoMap.get('artclave');
            Decimal artnum = (Decimal) productoMap.get('artnum');
            Decimal precio = (Decimal) productoMap.get('precio');
            Boolean activoProducto = (Boolean) productoMap.get('activo');
            
            if(mapProductExtId.get(artclave) != null && mapStandardPricebookEntry.get(artclave) == null){
                PricebookEntry iPrice = new PricebookEntry();
                iPrice.Product2Id = mapProductExtId.get(artclave);
                iPrice.Pricebook2Id = standarPricebook;
                iPrice.CurrencyIsoCode = Moneda;
                iPrice.IsActive = activoProducto;
                iPrice.UnitPrice = precio;
                iPrice.UseStandardPrice = false;
                listPricebookEntry.add(iPrice);
            }else if(mapStandardPricebookEntry.get(artclave) != null 
                     && (mapStandardPricebookEntry.get(artclave).UnitPrice != precio 
                         || mapStandardPricebookEntry.get(artclave).IsActive != activoProducto)
                    )
            {
                PricebookEntry iPrice = new PricebookEntry();
                iPrice.Id = mapStandardPricebookEntry.get(artclave).Id;
                iPrice.IsActive = activoProducto;
                iPrice.UnitPrice = precio;
                listPricebookEntry.add(iPrice);
            }
            
            if(mapProductExtId.get(artclave) != null && mapPricebookEntry.get(artclave) == null){
                System.debug('Entro if');
                PricebookEntry iPrice = new PricebookEntry();
                iPrice.Product2Id = mapProductExtId.get(artclave);
                iPrice.Pricebook2Id = PricebookId;
                iPrice.CurrencyIsoCode = Moneda;
                iPrice.IsActive = activoProducto;
                iPrice.UnitPrice = precio;
                iPrice.UseStandardPrice = false;
                listPricebookEntry.add(iPrice);
            }else if(mapProductExtId.get(artclave) != null && mapPricebookEntry.get(artclave) != null){
                PricebookEntry iPrice = new PricebookEntry();
                iPrice.Id = mapPricebookEntry.get(artclave).Id;
                iPrice.IsActive = activoProducto;
                iPrice.UnitPrice = precio;
                iPrice.UseStandardPrice = false;
                listPricebookEntry.add(iPrice);
            }else{
				String error = 'El producto ' + artclave + ', No existe en la base de datos de Salesforce.';
                listErrores.add(error);
            }
        }
        
        System.debug('listPricebookEntry size ' + listPricebookEntry);
        
        List<ProductPrices> listProd = new List<ProductPrices>();
        Map<Id, String> mapPricebookArtclave = new Map<Id, String>();
        Database.UpsertResult[] results = Database.upsert(listPricebookEntry, false);
        for(PricebookEntry iPrices : [SELECT Id, Product2.INT_External_Id__c FROM PricebookEntry WHERE Id IN: listPricebookEntry]){
            mapPricebookArtclave.put(iPrices.Id, iPrices.Product2.INT_External_Id__c);
        }
        for (Database.UpsertResult upsertResult : results) {
            if (upsertResult.isSuccess()) {
                for(PricebookEntry iPrice : listPricebookEntry){
                    ProductPrices pPrices = new ProductPrices();
                    pPrices.Artclave = mapPricebookArtclave.get(upsertResult.getId());
                    pPrices.PricebookId = PricebookId;
                    pPrices.PricebookEntryId = upsertResult.getId();
                    listProd.add(pPrices);
                }
                iUpsertedCount++;
            }else{
                iFailedCount++;
                sErrors += upsertResult.getErrors();
                listErrores.add(sErrors);
            }
        }
        
        System.debug('listProd ' + listProd);
        listProductPrices = listProd;
        
        if(iUpsertedCount > 0){
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(200);
            log.Endpoint__c = 'RestResource: upsertPricebooks';
            log.Error_Message__c = null;
            log.Request__c = String.valueOf(lstProductObject).abbreviate(131072);
            log.Response__c = ('PricebookEntry upserted: ' + iUpsertedCount).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
        }
        if(iFailedCount > 0){
            sErrores = JSON.serialize(listErrores);
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertPricebooks';
            log.Error_Message__c = 'Errores : ' + listErrores;
            log.Request__c = String.valueOf(lstProductObject).abbreviate(131072);
            log.Response__c = ('PricebookEntry failed: ' + iFailedCount).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
        }
        
        insert logs;
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Finalizado...');
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('PricebookEntries.txt');
        attachment.setBody(Blob.valueOf(JSON.serialize(listProductPrices)));
        
        // create a new SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // set the recipient email address
        email.setToAddresses(new String[]{'eheredia@freewayconsulting.com', 'jesalcido@Interceramic.com'});
        // set the email subject
        email.setSubject('Pricebook Rest Resource');
        // set the email body
        String emailBody = 	'Los siguientes productos han sido creados/actualizados en Salesforce: <br>' + listProductPrices + ', <br>' + 
            				'<br>'+
            				'Los siguientes productos han fallado  <br>' + sErrores	+ ', <br>' +
            				'<br>'+
            				'Para mayor información acerca de los productos creados/actualizados descargue el adjunto';
        email.setHtmlBody(emailBody);
        
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        
        // send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        // check if the email was sent successfully
        if (results[0].isSuccess()) {
            System.debug('Email sent successfully.');
        } else {
            System.debug('Email failed to send.');
        }

    }
    
    public class ProductPrices {
        String Artclave;
        String PricebookId;
        String PricebookEntryId;
    }
}