public without sharing class WS_ConsultaMargenesNormalBatch implements Database.Batchable<SObject> {
    public List<SBQQ__QuoteLine__c> quoteLines;
    public String recordId;
    
    public WS_ConsultaMargenesNormalBatch(List<SBQQ__QuoteLine__c> quoteLines, String rId) {
        this.recordId = rId;
        this.quoteLines = quoteLines;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, SBQQ__Quantity__c, SBQQ__Discount__c, TIPO__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: recordId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<SBQQ__QuoteLine__c> scope) {
        System.debug('Scope ' + scope);
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        String jsonString = '';
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        Set<Id> setQuoteLineId = new Set<Id>();
        List<SBQQ__QuoteLine__c> lstQuoteLineToUpsert = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c iQuote : scope){
            setQuoteLineId.add(iQuote.Id);
        }
        
        // Upsert the quote lines
        for(SBQQ__QuoteLine__c iQuote : quoteLines){
            if(iQuote.Id == null && !setQuoteLineId.contains(iQuote.Id)){
                lstQuoteLineToUpsert.add(iQuote);
            }
        }
        Database.upsertResult[] upsertResults = Database.upsert(lstQuoteLineToUpsert, false);
        // Process the upsert results
        for (Database.upsertResult result : upsertResults) {
            if (result.isSuccess()) {
                upsertedCount++;
            } 
        }
        
        if (upsertedCount > 0) {
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(200);
            log.Endpoint__c = 'AWS_Margenes_Normal';
            log.Error_Message__c = null;
            log.Request__c = String.valueOf('{}').abbreviate(131072);
            log.Response__c = (jsonString).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
        }
        
        insert logs;
    }
    
    
    public void finish(Database.BatchableContext context) {
        System.debug('Finish process...');
    }
}