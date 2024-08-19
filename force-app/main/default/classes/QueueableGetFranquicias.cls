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
public class QueueableGetFranquicias implements Queueable, Database.AllowsCallouts {

    public static void execute(QueueableContext ctx){

        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        HttpResponse response = new HttpResponse();

        response = WS_Interceramic.getFranquicias();

        String body = response.getBody();
        system.debug('body response'+ body);
        system.debug(response.getStatusCode());
        try{
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(body);
            List<Object> franquicias = (List<Object>) data.get('FRANQUICIAS');
            
            Database.executeBatch(new BatchCleanFranquicias(franquicias), 1000);
        }catch(Exception e){
            system.debug('Exception');
                Log_Integration__c log = new Log_Integration__c();
                log.Status_Code__c = String.valueOf(response.getStatusCode());
                log.Endpoint__c = 'AWS_Franquicias';
                log.Error_Message__c = 'Failed. Errors: ' + e;
                log.Request__c = String.valueOf('{}').abbreviate(131072);
                //log.Response__c = Errors.abbreviate(131072);
                log.Response__c = body.abbreviate(131072);
                log.Method__c = 'POST';
                log.Date__c = Date.today();
                insert log;
            system.debug('exception franquicias');
        }

        //Database.executeBatch(new BatchGetFranquicias(franquicias),1000);
        
        /*
        List<Franquicia__c> listFranquicias = new List<Franquicia__c>();

        Map<String, String> mapColonias = new Map<String, String>();
        for(Colonia__c iColonia : [SELECT Id, INT_External_Id__c , INT_PaisClave__c, INT_EntFedNum__c,INT_MpoNum__c,INT_ColNum__c
                                    FROM Colonia__c ]){
            mapColonias.put(iColonia.INT_External_Id__c, iColonia.Id);
        }
        System.debug('mapColonias:: ' + mapColonias);

        if(!franquicias.isEmpty()){

            for(Object obj : franquicias){
                Map<String, Object> franquiciaMap = (Map<String, Object>) obj;
                Integer EMPNUM = (Integer) franquiciaMap.get('EMPNUM');
                if(EMPNUM != null){
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
                    System.debug('mapColonia:: ' + mapColonias.get((String) franquiciaMap.get('PAISCLAVE') + ' ' + String.valueOf((Integer) franquiciaMap.get('ENTFEDNUM')) + ' ' + String.valueOf((Integer) franquiciaMap.get('MPONUM')) + ' ' + String.valueOf((Integer) franquiciaMap.get('COLNUM'))));
                    listFranquicias.add(franquicia);
                }
            }
        }

        if (!listFranquicias.isEmpty()) {
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
                log.Response__c = (body).abbreviate(131072);
                log.Method__c = 'POST';
                log.Date__c = Date.today();
                logs.add(log);
            }

            if(failedCount > 0){
                Log_Integration__c log = new Log_Integration__c();
                log.Status_Code__c = String.valueOf(500);
                log.Endpoint__c = 'AWS_Franquicias';
                log.Error_Message__c = 'Failed to upsert Lead. Errors: ' + failedCount;
                log.Request__c = String.valueOf('{}').abbreviate(131072);
                log.Response__c = Errors.abbreviate(131072);
                log.Method__c = 'POST';
                log.Date__c = Date.today();
                logs.add(log);
            }
        }*/
    }

    
}