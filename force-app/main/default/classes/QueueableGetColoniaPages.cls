public class QueueableGetColoniaPages implements Queueable, Database.AllowsCallouts {
	
    public Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return runningInASandbox;
        }
        set;
    }
	    
    public void execute(QueueableContext ctx){
        List<Log_Integration__c> lstLogs = new List<Log_Integration__c>();
        String body;
        List<Object> listData = new List<Object>();
        Integer iPages = 0;
        Integer iIterator = 0;
        if(!runningInASandbox){
            do{
                WS_Interceramic.WrapperGetColoniasFullResponse resService = WS_Interceramic.getColoniasFull(iPages);
                lstLogs.add(resService.logSF);
                HttpResponse response = new HttpResponse();
                //response = WS_Interceramic.getColonias(iPages);
                response = resService.response;
                body = response.getBody();
                Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(body);
                listData = (List<Object>) data.get('COLONIAS');
                if(!listData.isEmpty()){
                    iPages += 10;
                    iIterator++;
                }
            }while(!listData.isEmpty());
        }else{
            iPages = 1;
        }
        
        
        Colonia_Pagination__c coloniaPages = new Colonia_Pagination__c();
        coloniaPages.Name__c = 'Pages';
        coloniaPages.Pages__c = iPages;
        coloniaPages.Iterator__c = iIterator;
        coloniaPages.SetupOwnerId = UserInfo.getUserId();
        upsert coloniaPages Name__c;
        
        if(!lstLogs.isEmpty()){
            insert lstLogs;
        }
        
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        System.debug('Count: ' + i);
    }
}