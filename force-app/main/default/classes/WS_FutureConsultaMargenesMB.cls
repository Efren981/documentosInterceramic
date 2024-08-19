/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-28-2023
 * @last modified by  : emeza@freewayconsulting.com 
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-28-2023   emeza@freewayconsulting.com   Initial Version
**/
public class WS_FutureConsultaMargenesMB {
    @future(callout=true)
    public static void consultaMargenesMB(String id, String b) {
        String sBody = b;
        String sRecordId = id;
        
        System.debug('body ' + sBody);
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        String jsonString = '';
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<SBQQ__QuoteLine__c> listQuoteLineToUpsert = new List<SBQQ__QuoteLine__c>();
        Map<String, SBQQ__QuoteLine__c> mapQlineItem = new Map<String, SBQQ__QuoteLine__c>();
        
        for (SBQQ__QuoteLine__c iQline : [SELECT Id, SBQQ__Quote__r.CreatedBy.Name, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Discount__c, SBQQ__Product__c, INT_ChangeForServiceMargenes__c 
                                           FROM SBQQ__QuoteLine__c 
                                           WHERE SBQQ__Quote__c = :sRecordId]) {
            mapQlineItem.put(iQline.SBQQ__Product__r.ProductCode, iQline);
        }
        
        HttpResponse response = WS_Interceramic.getMargenesMB(sBody);
        System.debug('response ' + response.getBody());
        
        try {
            jsonString = response.getBody();        
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            List<Object> productos = (List<Object>) parsedJson.get('PRODUCTOS');
            
            for (Object producto : productos) {
                Map<String, Object> productoMap = (Map<String, Object>) producto;
                
                SBQQ__QuoteLine__c iQuoteLine = new SBQQ__QuoteLine__c();
                iQuoteLine.Id = mapQlineItem.get((String) productoMap.get('ARTCLAVE')).Id;
                iQuoteLine.SBQQ__Quantity__c = (Integer) productoMap.get('CANTIDAD');
                iQuoteLine.PRECIO_FRANQ__c = (Decimal) productoMap.get('PRECIO_FRANQ');
                iQuoteLine.PROP_MARGEN__c = (Decimal) productoMap.get('PROP_MARGEN');
                iQuoteLine.PROP_MARGEN_PORC__c = (Decimal) productoMap.get('PROP_MARGEN_PORC');
                iQuoteLine.MARGEN__c = (Decimal) productoMap.get('MARGEN');
                iQuoteLine.MARGEN_PORC__c = (Decimal) productoMap.get('MARGEN_PORC');
                iQuoteLine.FLETE_OBRA__c = (Decimal) productoMap.get('FLETE_OBRA');
                iQuoteLine.PRECIO_PROY_SIN_IVA__c = (Decimal) productoMap.get('PRECIO_PROY_SIN_IVA');
                if((Decimal) productoMap.get('DESCTO_PROY_PORC') > 0){
                    system.debug('entre?');
                    iQuoteLine.DESCTO_PROY_PORC__c = (Decimal) productoMap.get('DESCTO_PROY_PORC');
                    if(productoMap.get('DESCTO_PROY_PORC') != null)iQuoteLine.SBQQ__Discount__c = (Decimal) productoMap.get('DESCTO_PROY_PORC');
                    iQuoteLine.INT_GridDiscount_PORC__c = (Decimal) productoMap.get('DESCTO_PROY_PORC');
                }
                
                iQuoteLine.INT_ChangeForServiceMargenes__c = (mapQlineItem.get((String) productoMap.get('ARTCLAVE')).INT_ChangeForServiceMargenes__c == true) ? false : true;
                iQuoteLine.INT_NeedUpdateMargen__c = true;
                
                iQuoteLine.TOTAL_PROYECTO__c = (Decimal) productoMap.get('TOTAL_PROYECTO');
                iQuoteLine.TOTAL_IVA__c = (Decimal) productoMap.get('TOTAL_IVA');
                iQuoteLine.PRECIO_PROY_CON_IVA__c = (Decimal) productoMap.get('PRECIO_PROY_CON_IVA');
                iQuoteLine.PRECIO_FRANQ_LISTA__c = (Decimal) productoMap.get('PRECIO_FRANQ_LISTA');
                iQuoteLine.DESCTO_FRANQ_PORC__c = (Decimal) productoMap.get('DESCTO_FRANQ_PORC');
                iQuoteLine.PRECIO_BASE__c = (Decimal) productoMap.get('PRECIO_BASE');
                iQuoteLine.ARANCEL_PESOS__c = (Integer) productoMap.get('ARANCEL_PESOS');
                iQuoteLine.FLETE_ELP__c = (Decimal) productoMap.get('FLETE_ELP');
                iQuoteLine.LAB_OBRA__c = (Decimal) productoMap.get('LAB_OBRA');
                iQuoteLine.FIANZA__c = (Integer) productoMap.get('FIANZA');
                iQuoteLine.LAB_OBRA_CON_FIANZA__c = (Decimal) productoMap.get('LAB_OBRA_CON_FIANZA');
                iQuoteLine.TIPO_PRECIO2__c = (String) productoMap.get('TIPO_PRECIO');
                iQuoteLine.REV__c = (Integer) productoMap.get('REV');
                iQuoteLine.DROP__c = (Integer) productoMap.get('DROP');
                iQuoteLine.INT_Margen_color__c = (String) productoMap.get('MARGEN_COLOR');
                
                listQuoteLineToUpsert.add(iQuoteLine);
                System.debug(listQuoteLineToUpsert);
            }
            
            if (!listQuoteLineToUpsert.isEmpty()) {
                Database.upsertResult[] upsertResults = Database.upsert(listQuoteLineToUpsert, false);
                for (Database.UpsertResult upsertResult : upsertResults) {
                    if (upsertResult.isSuccess()) {
                        upsertedCount++;
                    } else {
                        failedCount++;
                        Errors += upsertResult.getErrors();
                    }
                }
                
                if (upsertedCount > 0) {
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(200);
                    log.Endpoint__c = 'AWS_Margenes_MB';
                    log.Error_Message__c = null;
                    log.Request__c = String.valueOf('{}').abbreviate(131072);
                    log.Response__c = (jsonString).abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
                
                if (failedCount > 0) {
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(500);
                    log.Endpoint__c = 'AWS_Margenes_MB';
                    log.Error_Message__c = 'Failed to upsert Lead. Errors: ' + failedCount;
                    log.Request__c = String.valueOf('{}').abbreviate(131072);
                    log.Response__c = Errors.abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage() + ', Stack: ' + ex.getStackTraceString());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'AWS_Margenes_MB';
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