public class QueueableGetSucursales implements Queueable, Database.AllowsCallouts {

    public static void execute(QueueableContext ctx){
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        HttpResponse response = new HttpResponse();
        response = WS_Interceramic.getSucursales();
        
        Map<Decimal, String> mapFranquicias = new Map<Decimal, String>();
        for(Franquicia__c iFranquicia : [SELECT Id, INT_EmpNum__c FROM Franquicia__c]){
            mapFranquicias.put(iFranquicia.INT_EmpNum__c, iFranquicia.Id);
        }
        
        String body = response.getBody();
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> sucursales = (List<Object>) data.get('SUCURSALES');
        
        List<Sucursal__c> listSucursales = new List<Sucursal__c>();
        
        if(!sucursales.isEmpty()){
            for(Object obj : sucursales){
                Map<String, Object> sucursalMap = (Map<String, Object>) obj;
                String SUCCLAVE = (String) sucursalMap.get('SUCCLAVE');
                
                if(SUCCLAVE != null){
                    Sucursal__c sucursal = new Sucursal__c();
                    sucursal.INT_SucClave__c = SUCCLAVE;
                    sucursal.Name = (String) sucursalMap.get('NOMBRE');
                    sucursal.INT_NombreCorto__c = (String) sucursalMap.get('NOMBRECORTO');
                    sucursal.INT_PaisClave__c = (String) sucursalMap.get('PAISCLAVE');
                    sucursal.INT_EntFedNum__c = (Integer) sucursalMap.get('ENTFEDNUM');
                    sucursal.INT_MpoNum__c = (Integer) sucursalMap.get('MPONUM');
                    sucursal.INT_Localidad__c = (String) sucursalMap.get('LOCALIDAD');
                    sucursal.INT_ColNum__c = (Integer) sucursalMap.get('COLNUM');
                    sucursal.INT_CP__c = Decimal.valueOf((String) sucursalMap.get('CP'));
                    sucursal.INT_Franquicia__c = mapFranquicias.get(Decimal.valueOf((Integer) sucursalMap.get('EMPNUM')));
                    sucursal.INT_Calle__c = (String) sucursalMap.get('CALLE');
                    sucursal.INT_NumExt__c = (String) sucursalMap.get('NUMEXT');
                    sucursal.INT_NumInt__c = (String) sucursalMap.get('NUMINT');
                    listSucursales.add(sucursal);
                }
            }
        }
        
        if (!listSucursales.isEmpty()) {
            Database.upsertResult[] upsertResults = Database.upsert(listSucursales, Sucursal__c.INT_SucClave__c, false);
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
        }
    }

}