/**
 * @description       : 
 * @author            : Jesus Alvarez
 * @group             : 
 * @last modified on  : 12-28-2023
 * @last modified by  : Jesus Alvarez
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-27-2023   Jesus Alvarez   Initial Version
**/
public class BatchGetFranquicias implements Database.Batchable<sObject>{
    private List<Object> dataFranquicias;

    public BatchGetFranquicias(List<Object> data){
        this.dataFranquicias = data;
        System.debug('dataFranquicias:: ' + dataFranquicias);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, INT_External_Id__c FROM Colonia__c]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        Set<Decimal> processedFranquiciaIds = new Set<Decimal>();
        //HttpResponse response = new HttpResponse();
        //response = WS_Interceramic.getFranquicias();

        for (Franquicia__c processed : [SELECT Id, INT_EmpNum__c, INT_UpdateFranquicia__c FROM Franquicia__c WHERE INT_UpdateFranquicia__c = TRUE]) {
            processedFranquiciaIds.add(processed.INT_EmpNum__c);
        }

        Map<String, String> mapColonias = new Map<String, String>();
        //List<Colonia__c> lstColonia = [SELECT Id, INT_External_Id__c FROM Colonia__c WHERE Id IN :scope];
        for(Colonia__c iColonia : [SELECT Id, INT_External_Id__c FROM Colonia__c WHERE Id IN :scope]){
            mapColonias.put(iColonia.INT_External_Id__c, iColonia.Id);
        }
        System.debug('mapColonias:: ' + mapColonias);
        //String body = response.getBody();
        //Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(body);
        //System.debug('data::PAISCLAVE ' + data.get('PAISCLAVE'));
        //List<Object> franquicias = (List<Object>) data.get('FRANQUICIAS');
        
        List<Franquicia__c> listFranquicias = new List<Franquicia__c>();
        
        
        //if(!franquicias.isEmpty()){
        if(!dataFranquicias.isEmpty()){
            System.debug('If::franquicias:: '+ dataFranquicias);
            for(Object obj : dataFranquicias){
                Map<String, Object> franquiciaMap = (Map<String, Object>) obj;
                Integer EMPNUM = (Integer) franquiciaMap.get('EMPNUM');
                
                if(EMPNUM != null && !processedFranquiciaIds.contains(EMPNUM)){
                    Franquicia__c franquicia = new Franquicia__c();
                    franquicia.INT_EmpNum__c = EMPNUM;
                    franquicia.Name = (String) franquiciaMap.get('NOMBRE');
                    franquicia.INT_NameCorto__c = (String) franquiciaMap.get('NOMBRECORTO');
                    franquicia.INT_PaisClave__c = (String) franquiciaMap.get('PAISCLAVE');
                    franquicia.INT_EntFedNum__c = (Integer) franquiciaMap.get('ENTFEDNUM');
                    franquicia.INT_MpoNum__c = (Integer) franquiciaMap.get('MPONUM');
                    franquicia.INT_Localidad__c = (String) franquiciaMap.get('LOCALIDAD');
                    franquicia.INT_ColNum__c = (Integer) franquiciaMap.get('COLNUM');
                    franquicia.INT_CP__c = (String) franquiciaMap.get('CP');
                    franquicia.INT_Colonia__c = mapColonias.get((String) franquiciaMap.get('PAISCLAVE') + ' ' + String.valueOf((Integer) franquiciaMap.get('ENTFEDNUM')) + ' ' + String.valueOf((Integer) franquiciaMap.get('MPONUM')) + ' ' + String.valueOf((Integer) franquiciaMap.get('COLNUM')));
                    franquicia.INT_Calle__c = (String) franquiciaMap.get('CALLE');
                    franquicia.INT_UpdateFranquicia__c = true;
                    System.debug('Colonias:: ' + mapColonias.get((String) franquiciaMap.get('PAISCLAVE') + ' ' + String.valueOf((Integer) franquiciaMap.get('ENTFEDNUM')) + ' ' + String.valueOf((Integer) franquiciaMap.get('MPONUM')) + ' ' + String.valueOf((Integer) franquiciaMap.get('COLNUM'))));
                    listFranquicias.add(franquicia);
                    if (franquicia.INT_Colonia__c != null) {
                        processedFranquiciaIds.add(franquicia.INT_EmpNum__c);
                        System.debug('processedFranquiciaIds' + processedFranquiciaIds);
                    }
                    
                }
            }
        }
        if (!listFranquicias.isEmpty()) {
            System.debug('listFranquicias' + listFranquicias);
            Database.upsertResult[] upsertResults = Database.upsert(listFranquicias, Franquicia__c.INT_EmpNum__c, false);
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
                log.Endpoint__c = 'AWS_Franquicias';
                log.Error_Message__c = null;
                log.Request__c = String.valueOf('{}').abbreviate(131072);
                //log.Response__c = (body).abbreviate(131072);
                log.Method__c = 'POST';
                log.Date__c = Date.today();
                logs.add(log);
            }
            
            if(failedCount > 0){
                Log_Integration__c log = new Log_Integration__c();
                log.Status_Code__c = String.valueOf(500);
                log.Endpoint__c = 'AWS_Franquicias';
                log.Error_Message__c = 'Failed to upsert. Errors: ' + failedCount;
                log.Request__c = String.valueOf('{}').abbreviate(131072);
                log.Response__c = Errors.abbreviate(131072);
                log.Method__c = 'POST';
                log.Date__c = Date.today();
                logs.add(log);
            }
            if(logs.size() > 0){
                insert logs;
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.Debug('FINISHED JOB');
    }

    

}