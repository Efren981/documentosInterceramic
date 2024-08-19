@RestResource(urlMapping='/getCalendarioConsumo/*')
global class CalendarioConsumoRestResource {
    
    @HttpPost
    global static void getCalendarioConsumo(){
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        
        try{
            RestRequest request = RestContext.request;
            String jsonRequestBody = request.requestBody.toString();
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonRequestBody);
            String opportunityIdString = (String) data.get('OpportunityId');
            
            if(String.isBlank(opportunityIdString)){
                response.put('Exception: ', 'Opportunity ID is required.');
            }
            
            List<Periodo> periodos = new List<Periodo>();
            for(Calendario_de_Consumo__c iCc : [SELECT INT_Name_Periodo__c, INT_Producto__r.Product2.ProductCode, INT_Cantidad__c 
                                                FROM Calendario_de_Consumo__c 
                                                WHERE INT_Oportunidad__c =: opportunityIdString])
            {
                Periodo iPeriodo = new Periodo();
                iPeriodo.periodo = iCc.INT_Name_Periodo__c;
                iPeriodo.artclave = iCc.INT_Producto__r.Product2.ProductCode;
                iPeriodo.cantidad = iCc.INT_Cantidad__c;
                periodos.add(iPeriodo);
            }
            
            if(!String.isBlank(opportunityIdString)){
                response.put('status', 200);
                response.put('id_oportunidad', opportunityIdString);
                response.put('periodos', periodos);
                if(periodos.isEmpty()){
                    response.put('message', 'Está oportunidad aún no tiene un calendario de consumo');
                }
            }
            
            String jsonString = JSON.serialize(response);
            System.debug('jsonString ' + jsonString);
            if(!test.isRunningTest()){
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
            }
        }Catch(Exception ex){
            // Handle exception
            RestRequest request = RestContext.request;
            String jsonInput = request.requestBody.toString();
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: getCalendarioConsumo';
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
    }
    
    public class Periodo{
        String periodo;
        String artclave;
        Decimal cantidad;
    }
}