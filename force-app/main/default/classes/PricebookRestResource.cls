@RestResource(urlMapping='/upsertPricebooks/*')
global class PricebookRestResource {
    
    @HttpPost
    global static void createListaPrecios() {
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        String sResponse = '';
        try{
            RestRequest request = RestContext.request;
            String jsonRequest = request.requestBody.toString();
            
            Map<Id, Pricebook2> mapPricebook = new Map<Id, Pricebook2>();
            Map<String, Pricebook2> mapPricebookString = new Map<String, Pricebook2>();
            
            for(Pricebook2 iPricebook : [SELECT Id, IsActive, Description, IsStandard, Name FROM Pricebook2 WHERE IsActive = true]){
                System.debug('pricebook: ' + iPricebook.Name);
                System.debug('pricebook Id: ' + iPricebook.Id);
                mapPricebook.put(iPricebook.Id, iPricebook);
                mapPricebookString.put(iPricebook.Name, iPricebook);
            }
            
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            
            Map<String, Object> listaPreciosMap = (Map<String, Object>) jsonMap.get('listaprecios');
            String nombre = (String) listaPreciosMap.get('nombre');
            String pricebookId = (String) listaPreciosMap.get('id');
            Boolean activo = (Boolean) listaPreciosMap.get('activo');
            String descripcion = (String) listaPreciosMap.get('descripcion');
            String moneda = (String) listaPreciosMap.get('moneda');
            String ListId = '';
            
            System.debug('pricebookId: ' + pricebookId);
            System.debug('mapPricebook.get(pricebookId): ' + mapPricebook.get(pricebookId));
            if(pricebookId != null && pricebookId != '' && mapPricebook.get(pricebookId) != null){
                ListId = mapPricebook.get(pricebookId).Id;
            }else{
                System.debug('ListId: ' + ListId);
                if((pricebookId == '' || pricebookId == null) && mapPricebookString.get(nombre) != null){
                    ListId = mapPricebookString.get(nombre).Id;
                }
            }
            
            if(ListId == ''){
                Pricebook2 iPrice2 = new Pricebook2();
                iPrice2.Name = nombre;
                iPrice2.IsActive = activo;
                iPrice2.Description = descripcion;
                iPrice2.INT_CurrencyIsoCode__c = moneda;
                
                Database.SaveResult results = Database.insert(iPrice2, false);
                if(results.isSuccess()){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(200);
                    log.Endpoint__c = 'RestResource: upsertPricebook';
                    log.Error_Message__c = null;
                    log.Request__c = String.valueOf(jsonRequest).abbreviate(131072);
                    log.Response__c = ('Pricebook created: ' + results.getId()).abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                    sResponse = ('Pricebook created: ' + results.getId()).abbreviate(131072);
                }
                if(!results.isSuccess()){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(500);
                    log.Endpoint__c = 'RestResource: upsertPricebook';
                    log.Error_Message__c = String.valueOf(results.getErrors()).abbreviate(131072);
                    log.Request__c = String.valueOf(jsonRequest).abbreviate(131072);
                    log.Response__c = ('Pricebook failed: ' + results.getErrors()).abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                    sResponse = ('Pricebook failed: ' + results.getErrors()).abbreviate(131072);
                }
                ListId = iPrice2.Id;
            }else{
                sResponse = 'Pricebook already exist: Id = ' + ListId;
            }
            
            List<Object> productosList = (List<Object>) listaPreciosMap.get('productos');
            PricebookEntries.callBatchUpsertPricebookEntries(ListId, moneda, productosList);
            
            response.put('status', 200);
            response.put('message', sResponse);
            response.put('PricebookId', ListId);
            response.put('Products', 'Products are going to be upsert by asynchronous method');
        }catch(Exception ex){
            RestRequest request = RestContext.request;
            String jsonInput = request.requestBody.toString();
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertPricebook';
            log.Error_Message__c = 'Error: ' + ex.getMessage();
            log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
            log.Response__c = ('Error: ' + ex.getMessage() + ' ' + ex.getCause()).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            response.put('status', 500);
            response.put('message', ('Error: ' + ex.getMessage()));
        }
        insert logs;
        
        String jsonString = JSON.serialize(response);
        System.debug('jsonString ' + jsonString);
        if(!test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonString);
        }
    }
}