@RestResource(urlMapping='/upsertProducts/*')
global class ProductRestResource {
    
    @HttpPost
    global static void createProducts() {
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        
        try{
            RestRequest request = RestContext.request;
            String jsonRequestBody = request.requestBody.toString();
            
            ProductUpsertBatch batch = new ProductUpsertBatch(jsonRequestBody);
            Database.executeBatch(batch, 49);
            response.put('status', 200);
            response.put('message', 'Cuando finalice la carga será informado mediante correo electrónico');
            
        }catch(Exception ex){
            // Handle exception
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Error_Message__c = 'Error: ' + ex.getMessage() + ' ' + ex.getCause();
            log.Request__c = null;
            log.Response__c = null;
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            response.put('status', 500);
            response.put('message', ('Error: ' + ex.getMessage() + ' ' + ex.getCause()));
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