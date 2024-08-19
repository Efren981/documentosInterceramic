/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-28-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-25-2023   emeza@freewayconsulting.com   Initial Version
**/
public without sharing class WS_FutureConsultaMargenesNormal {
    /*@future(callout=true)*/
    public static void consultaMargenesNormal(String id, String b) {
        String sBody = b;
        String sRecordId = id;
        
        System.debug('body ' + sBody);
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        String jsonString = '';
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<SBQQ__QuoteLine__c> listQuoteLineToUpsert = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> listQuoteLineAditional = new List<SBQQ__QuoteLine__c>();
        Map<String, SBQQ__QuoteLine__c> mapQlineItem = new Map<String, SBQQ__QuoteLine__c>();
        Map<String, SBQQ__QuoteLine__c> mapQlineItemAdd = new Map<String, SBQQ__QuoteLine__c>();
        Map<String, Product2> mapProduct2Add = new Map<String, Product2>();
        
        for(SBQQ__QuoteLine__c iQline : [SELECT Id, SBQQ__Quote__r.CreatedBy.Name, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Discount__c, SBQQ__Product__c, TIPO__c, INT_ChangeForServiceMargenes__c 
                                         FROM SBQQ__QuoteLine__c 
                                         WHERE SBQQ__Quote__c =: sRecordId])
        {
            mapQlineItem.put(iQline.SBQQ__Product__r.ProductCode, iQline);
            if(iQline.TIPO__c != null){
                mapQlineItemAdd.put(iQline.SBQQ__Product__r.ProductCode + ' ' + String.valueOf(Integer.valueOf(iQline.SBQQ__Quantity__c) + ' ' + iQline.TIPO__c), iQline);
            }else{
                mapQlineItemAdd.put(iQline.SBQQ__Product__r.ProductCode + ' ' + String.valueOf(Integer.valueOf(iQline.SBQQ__Quantity__c)), iQline);
            }
        }
        
        for(Product2 iProd : [SELECT Id, INT_External_Id__c, ProductCode FROM Product2 WHERE INT_Grupo__c = 'ADHESIVO' OR INT_Grupo__c = 'BOQUILLA']){
            mapProduct2Add.put(iProd.ProductCode, iProd);
        }
        
        HttpResponse response = new HttpResponse();
        response = WS_Interceramic.getMargenesNormal(sBody);
        System.debug('response ' + response.getBody());
        
        try{
            jsonString = response.getBody();
            System.debug(jsonString);
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            List<Object> productos = (List<Object>) jsonMap.get('PRODUCTOS');
            
            for (Object productoObj : productos) {
                Map<String, Object> productoMap = (Map<String, Object>) productoObj;
                
                SBQQ__QuoteLine__c iQuoteLine = new SBQQ__QuoteLine__c();
                if(mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Decimal) productoMap.get('CANTIDAD'))) != null){
                    iQuoteLine.Id = mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Decimal) productoMap.get('CANTIDAD'))).Id;
                    iQuoteLine.SBQQ__Quantity__c = (Decimal) productoMap.get('CANTIDAD');
                    iQuoteLine.METROS__c = String.valueOf((Decimal) productoMap.get('METROS'));
                    iQuoteLine.SBQQ__OriginalPrice__c = (Decimal) productoMap.get('PRECIO_UNITARIO');
                    iQuoteLine.TIPO_PRECIO__c = (String) productoMap.get('TIPO_PRECIO');
                    iQuoteLine.TIPO_PROMO__c = (String) productoMap.get('TIPO_PROMO');
                    
                    iQuoteLine.INT_ChangeForServiceMargenes__c = (mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Decimal) productoMap.get('CANTIDAD'))).INT_ChangeForServiceMargenes__c == true) ? false : true;
                    iQuoteLine.INT_NeedUpdateMargen__c = true;
                    
                    List<Object> descuentos = (List<Object>) productoMap.get('DESCUENTOS');
                    for (Object descuentoObj : descuentos) {
                        Map<String, Object> descuentoMap = (Map<String, Object>) descuentoObj;
                        
                        iQuoteLine.IMPORTE_BRUTO__c = (Decimal) descuentoMap.get('IMPORTE_BRUTO');
                        iQuoteLine.IMPORTE_NETO__c = (Decimal) descuentoMap.get('IMPORTE_NETO');
                        if(descuentoMap.get('PORCENTAJE_DESCUENTO') != null) iQuoteLine.SBQQ__Discount__c = (Decimal) descuentoMap.get('PORCENTAJE_DESCUENTO');
                        iQuoteLine.PRECIO_DESCUENTO__c = (Decimal) descuentoMap.get('PRECIO_DESCUENTO');
                        //iQuoteLine.SBQQ__AdditionalDiscount__c = (Decimal) descuentoMap.get('DESCUENTO');
                        iQuoteLine.IVA__c = (Decimal) descuentoMap.get('IVA');
                        iQuoteLine.NETO_CON_DESCUENTO__c = (Decimal) descuentoMap.get('NETO_CON_DESCUENTO');
                        iQuoteLine.PRECIO_FRANQ_LISTA__c = (Decimal) descuentoMap.get('PRECIO_FRANQ_LISTA');
                        iQuoteLine.INT_Margen_color__c = (String) descuentoMap.get('MARGEN_COLOR');
                    }
                    
                    List<Object> gastos = (List<Object>) productoMap.get('GASTOS');
                    for (Object gastoObj : gastos) {
                        Map<String, Object> gastoMap = (Map<String, Object>) gastoObj;
                        
                        // Access the properties of each expense
                        iQuoteLine.FLETE_TONELADA__c = (Decimal) gastoMap.get('FLETE_TONELADA');
                        iQuoteLine.APOYO_FLETE__c = (Decimal) gastoMap.get('APOYO_FLETE');
                        iQuoteLine.COSTO_REPOSICION__c = (Decimal) gastoMap.get('COSTO_REPOSICION');
                        iQuoteLine.FLETE__c = (Decimal) gastoMap.get('FLETE');
                        iQuoteLine.FLETE_APLICADO__c = (Decimal) gastoMap.get('FLETE_APLICADO');
                        iQuoteLine.COSTO_PUBLICIDAD__c = (Decimal) gastoMap.get('COSTO_PUBLICIDAD');
                        iQuoteLine.COSTO_FLETE__c = (Decimal) gastoMap.get('COSTO_FLETE');
                        iQuoteLine.PORCENTAJE_APOYO_PLANTA__c = (Decimal) gastoMap.get('PORCENTAJE_APOYO_PLANTA');
                        iQuoteLine.APOYO_PLANTA__c = (Decimal) gastoMap.get('APOYO_PLANTA');
                    }
                    
                    List<Object> margen = (List<Object>) productoMap.get('MARGEN');
                    for (Object margenObj : margen) {
                        Map<String, Object> margenMap = (Map<String, Object>) margenObj;
                        
                        // Access the properties of each margin
                        iQuoteLine.FLETE_MARGEN__c = (Decimal) margenMap.get('FLETE');
                        iQuoteLine.BONIFICACION__c = (Decimal) margenMap.get('BONIFICACION');
                        iQuoteLine.PUBLICIDAD__c = (Decimal) margenMap.get('PUBLICIDAD');
                        iQuoteLine.FLETE_ENTREGA__c = (Decimal) margenMap.get('FLETE_ENTREGA');
                        iQuoteLine.APOYO_PLANTA_MARGEN__c = (Decimal) margenMap.get('APOYO_PLANTA');
                        iQuoteLine.COSTO_REPOSICION_MARGEN__c = (Decimal) margenMap.get('COSTO_REPOSICION');
                        iQuoteLine.PROYECTO__c = (Decimal) margenMap.get('PROYECTO');
                        iQuoteLine.MARGEN_FRANQUICIA_PORC__c = (Decimal) margenMap.get('MARGEN_FRANQUICIA_PORC');
                        iQuoteLine.MARGEN_FRANQUICIA__c = (Decimal) margenMap.get('MARGEN_FRANQUICIA');
                    }
                    
                    List<Object> margenPlanta = (List<Object>) productoMap.get('MARGEN_PLANTA');
                    for (Object margenPlantaObj : margenPlanta) {
                        Map<String, Object> margenPlantaMap = (Map<String, Object>) margenPlantaObj;
                        
                        // Access the properties of each plant margin
                        iQuoteLine.COSTO_PLANTA__c = (Decimal) margenPlantaMap.get('COSTO_PLANTA');
                        iQuoteLine.MARGEN_FRANQUICIA_PLANTA__c = (Decimal) margenPlantaMap.get('MARGEN_FRANQUICIA');
                        iQuoteLine.MARGEN_CONSOLIDADO__c = (Decimal) margenPlantaMap.get('MARGEN_CONSOLIDADO');
                        iQuoteLine.MARGEN_PLANTA__c = (Decimal) margenPlantaMap.get('MARGEN_PLANTA');
                        iQuoteLine.MARGEN_FRANQUICIA_PORC_PLANTA__c = (Decimal) margenPlantaMap.get('MARGEN_FRANQUICIA_PORC');
                        iQuoteLine.MARGEN_CONSOLIDADO_PORC__c = (Decimal) margenPlantaMap.get('MARGEN_CONSOLIDADO_PORC');
                        iQuoteLine.MARGEN_PLANTA_PORC__c = (Decimal) margenPlantaMap.get('MARGEN_PLANTA_PORC');
                        iQuoteLine.IMPORTE_PROYECTO__c = (Decimal) margenPlantaMap.get('IMPORTE_PROYECTO');
                        iQuoteLine.IMPORTE_COSTO_PLANTA__c = (Decimal) margenPlantaMap.get('IMPORTE_COSTO_PLANTA');
                        iQuoteLine.UTILIDAD_FRANQUICIA__c = (Decimal) margenPlantaMap.get('UTILIDAD_FRANQUICIA');
                        iQuoteLine.UTILIDAD_CONSOLIDADA__c = (Decimal) margenPlantaMap.get('UTILIDAD_CONSOLIDADA');
                        iQuoteLine.UTILIDAD_PLANTA__c = (Decimal) margenPlantaMap.get('UTILIDAD_PLANTA');
                    }
                    iQuoteLine.MARGEN_PORC__c = (Decimal) productoMap.get('MARGEN_PORC');
                    iQuoteLine.FLETE_OBRA__c = (Decimal) productoMap.get('FLETE_OBRA');
                    iQuoteLine.PRECIO_PROY_SIN_IVA__c = (Decimal) productoMap.get('PRECIO_PROY_SIN_IVA');
                    iQuoteLine.DESCTO_PROY_PORC__c = (Decimal) productoMap.get('DESCTO_PROY_PORC');
                    iQuoteLine.TOTAL_PROYECTO__c = (Decimal) productoMap.get('TOTAL_PROYECTO');
                    iQuoteLine.TOTAL_IVA__c = (Decimal) productoMap.get('TOTAL_IVA');
                    iQuoteLine.PRECIO_PROY_CON_IVA__c = (Decimal) productoMap.get('PRECIO_PROY_CON_IVA');
                    iQuoteLine.PRECIO_FRANQ_LISTA2__c = (Decimal) productoMap.get('PRECIO_FRANQ_LISTA');
                    iQuoteLine.DESCTO_FRANQ_PORC__c = (Decimal) productoMap.get('DESCTO_FRANQ_PORC');
                    iQuoteLine.PRECIO_BASE__c = (Decimal) productoMap.get('PRECIO_BASE');
                    iQuoteLine.ARANCEL_PESOS__c = (Decimal) productoMap.get('ARANCEL_PESOS');
                    iQuoteLine.FLETE_ELP__c = (Decimal) productoMap.get('FLETE_ELP');
                    iQuoteLine.LAB_OBRA__c = (Decimal) productoMap.get('LAB_OBRA');
                    iQuoteLine.FIANZA__c = (Decimal) productoMap.get('FIANZA');
                    iQuoteLine.LAB_OBRA_CON_FIANZA__c = (Decimal) productoMap.get('LAB_OBRA_CON_FIANZA');
                    iQuoteLine.TIPO_PRECIO2__c = (String) productoMap.get('TIPO_PRECIO');
                    iQuoteLine.REV__c = (Integer) productoMap.get('REV');
                    iQuoteLine.DROP__c = (Integer) productoMap.get('DROP');
                }
                
                
                system.debug('color '+iQuoteLine.INT_Margen_color__c);
                List<Object> materialInstalacion = (List<Object>) productoMap.get('MATERIAL_INSTALACION');
                if(materialInstalacion != null){
                    for (Object materialInstalacionObj : materialInstalacion) {
                        Map<String, Object> materialInstalacionMap = (Map<String, Object>) materialInstalacionObj;
                        
                        // Access the properties of the installation material
                        iQuoteLine.TOTAL_ADHESIVO__c = (Decimal) materialInstalacionMap.get('TOTAL_ADHESIVO');
                        iQuoteLine.TOTAL_BOQUILLO__c = (Decimal) materialInstalacionMap.get('TOTAL_BOQUILLO');
                        
                        // Access the "MATERIAL_INSTALACION" array within the installation material map
                        List<Object> materialInstalacionList = (List<Object>) materialInstalacionMap.get('MATERIAL_INSTALACION');
                        for (Object materialObj : materialInstalacionList) {
                            Map<String, Object> materialMap = (Map<String, Object>) materialObj;
                            
                            SBQQ__QuoteLine__c iQuoteLineInstalacion = new SBQQ__QuoteLine__c();                    
                            // Access the properties of each installation material
                            /*if(mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Integer) materialMap.get('CANTIDAD')) + ' ' + (String) materialMap.get('TIPO')) != null 
                               && mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Integer) materialMap.get('CANTIDAD')) + ' ' + (String) materialMap.get('TIPO')).Id != null )
                            {
                                iQuoteLineInstalacion.Id = mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Integer) materialMap.get('CANTIDAD')) + ' ' + (String) materialMap.get('TIPO')).Id;
                            }*/
                            
                            if(mapQlineItem.get((String) materialMap.get('ARTCLAVE')) != null)
                            {
                                iQuoteLineInstalacion.SBQQ__Product__c = mapQlineItem.get((String) materialMap.get('ARTCLAVE')).SBQQ__Product__c;
                                iQuoteLineInstalacion.Id = mapQlineItem.get((String) materialMap.get('ARTCLAVE')).Id;
                            }else if(mapQlineItem.get((String) materialMap.get('ARTCLAVE')) == null)
                            {
                                System.debug(mapProduct2Add);
                                System.debug((String) materialMap.get('ARTCLAVE'));
                                System.debug('GET ' + mapProduct2Add.get((String) materialMap.get('ARTCLAVE')).Id);
                                iQuoteLineInstalacion.SBQQ__Product__c = mapProduct2Add.get((String) materialMap.get('ARTCLAVE')).Id;
                                iQuoteLineInstalacion.SBQQ__Quote__c = sRecordId;
                            }
                            
                            /*if(mapQlineItemAdd.get((String) productoMap.get('ARTCLAVE') + ' ' + String.valueOf((Integer) materialMap.get('CANTIDAD')) + ' ' + (String) materialMap.get('TIPO')) == null){
                                iQuoteLineInstalacion.SBQQ__Quote__c = sRecordId;
                            }*/
                            
                            iQuoteLineInstalacion.TIPO__c = (String) materialMap.get('TIPO');
                            iQuoteLineInstalacion.SBQQ__Quantity__c = (Integer) materialMap.get('CANTIDAD');
                            /*if(!listQuoteLineToUpsert.contains(iQuoteLineInstalacion)){
                                listQuoteLineToUpsert.add(iQuoteLineInstalacion);
                            }*/
                            //if(!listQuoteLineAditional.contains(iQuoteLineInstalacion)){
                                listQuoteLineAditional.add(iQuoteLineInstalacion);
                            //}
                        }
                    }
                }
                
                
                if(!listQuoteLineToUpsert.contains(iQuoteLine)){
                    listQuoteLineToUpsert.add(iQuoteLine);   
                }
            }
            
            if (!listQuoteLineToUpsert.isEmpty()) {
                
                Database.upsertResult[] upsertResults = Database.upsert(listQuoteLineToUpsert, false);
                for (Database.UpsertResult upsertResult : upsertResults) {
                    system.debug('resltado '+upsertResult);
                    if (upsertResult.isSuccess()) {
                        upsertedCount++;
                    }else{
                        failedCount++;
                        Errors += upsertResult.getErrors();
                    }
                }
                
                if (!listQuoteLineAditional.isEmpty()) {
                    // Pass the listQuoteLineAditional to the batch job
                    //Database.upsertResult[] results = Database.upsert(listQuoteLineAditional, false);
                    WS_ConsultaMargenesNormalBatch batch = new WS_ConsultaMargenesNormalBatch(listQuoteLineAditional, sRecordId);
                    Database.executeBatch(batch, 200);
                }
                
                if(upsertedCount > 0){
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
                
                if(failedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(500);
                    log.Endpoint__c = 'AWS_Margenes_Normal';
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
            log.Endpoint__c = 'AWS_Margenes_Normal';
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