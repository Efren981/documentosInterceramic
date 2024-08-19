public class QueueableGetColonias implements Queueable, Database.AllowsCallouts {
    Integer iPages;
    
    public QueueableGetColonias (Integer iPag) {
        this.iPages = iPag;
    }
    
    public void execute(QueueableContext ctx){
        List<Object> listData = new List<Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<Colonia__c> colonias = new List<Colonia__c>();
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        String body;
        
        Map<String, Id> mapCiudad = new Map<String, Id>();
        for(Ciudad__c iCiudad : [SELECT Id, INT_External_Id__c FROM Ciudad__c]){
            mapCiudad.put(iCiudad.INT_External_Id__c, iCiudad.Id);
        }
        
        try{
            HttpResponse response = new HttpResponse();
            response = WS_Interceramic.getColonias(iPages);
            body = response.getBody();
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(body);
            listData = (List<Object>) data.get('COLONIAS');
            
            if(!listData.isEmpty()){
                for (Object obj : listData) {
                    Map<String, Object> jsonMap = (Map<String, Object>) obj;
                    
                    Colonia__c colonia = new Colonia__c();
                    colonia.Name = (String) jsonMap.get('NOMBRE');
                    colonia.INT_NomCompleto__c = (String) jsonMap.get('NOMBRECOMPLETO');
                    colonia.INT_PaisClave__c = (String) jsonMap.get('PAISCLAVE');
                    colonia.INT_CP__c = Decimal.valueOf((Integer) jsonMap.get('CP'));
                    colonia.INT_EntFedNum__c = (Integer) jsonMap.get('ENTFEDNUM');
                    colonia.INT_MpoNum__c = (Integer) jsonMap.get('MPONUM');
                    colonia.INT_ColNum__c = (Integer) jsonMap.get('COLNUM');
                    colonia.INT_External_Id__c = (String) jsonMap.get('PAISCLAVE') + ' ' + String.ValueOf((Integer) jsonMap.get('ENTFEDNUM')) + ' ' + String.ValueOf((Integer) jsonMap.get('MPONUM')) + ' ' + String.ValueOf((Integer) jsonMap.get('COLNUM'));
                    colonia.INT_Ciudad__c = mapCiudad.get((String) jsonMap.get('PAISCLAVE') + ' ' + String.ValueOf((Integer) jsonMap.get('ENTFEDNUM')) + ' ' + String.ValueOf((Integer) jsonMap.get('MPONUM')));
                    colonia.INT_TipoAsenta__c = (String) jsonMap.get('TIPOASENTA');
                    colonia.INT_LAT_LNG__Latitude__s = (Decimal) jsonMap.get('LAT');
                    colonia.INT_LAT_LNG__Longitude__s = (Decimal) jsonMap.get('LNG');
                    
                    colonias.add(colonia);
                }
            }
            
            if (!colonias.isEmpty()) {
                System.debug('colonias ' + colonias);
                Database.upsertResult[] upsertResults = Database.upsert(colonias, Colonia__c.INT_External_Id__c, false);
                for (Database.UpsertResult upsertResult : upsertResults) {
                    if (upsertResult.isSuccess()) {
                        upsertedCount++;
                    }else{
                        failedCount++;
                        Errors += upsertResult.getErrors();
                    }
                }
                
                if(upsertedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(200);
                    log.Endpoint__c = 'AWS_Colonias';
                    log.Error_Message__c = null;
                    log.Request__c = String.valueOf('{}').abbreviate(131072);
                    log.Response__c = (body).abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
                
                if(failedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(500);
                    log.Endpoint__c = 'AWS_Colonias';
                    log.Error_Message__c = 'Failed to upsert Lead. Errors: ' + failedCount;
                    log.Request__c = String.valueOf('{}').abbreviate(131072);
                    log.Response__c = Errors.abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'AWS_Colonias';
            log.Error_Message__c = 'Error: ' + ex.getMessage();
            log.Request__c = null;
            log.Response__c = 'Error: ' + ex.getMessage();
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
        }
        insert logs;
    }
}