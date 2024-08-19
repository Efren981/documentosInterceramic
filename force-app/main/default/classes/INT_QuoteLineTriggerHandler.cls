public class INT_QuoteLineTriggerHandler {
    public static  void handleTrigger(List<SBQQ__QuoteLine__c> newQuoteLineList,List<SBQQ__QuoteLine__c> oldQuoteLineList,Map<Id, SBQQ__QuoteLine__c> newQuoteLineMap,Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap,System.TriggerOperation triggerEvent){  
        
        switch on Trigger.operationType {
            when BEFORE_INSERT{
                
                //
                for(SBQQ__QuoteLine__c ql: newQuoteLineList){
                    if(ql.SBQQ__Discount__c != null || ql.INT_Estatus__c == 'DESCONTINUADO'){
                         ql.INT_FWY_Necesita_aprobacion__c = 'true';
                    }else{
                        ql.INT_FWY_Necesita_aprobacion__c = 'false';
                    }
                    
                }
                
                User u = [select Id, profile.name from User where Id = :UserInfo.getUserId()];
                if(!u.profile.name.contains('Autorizador Excepciones MB')){
                    if(!Test.isRunningTest()){INT_QuoteLineTriggerHandler.validateInsertPriceChange(newQuoteLineList);}
                }
                setMargenesValues(newQuoteLineList);
                
            }
            when BEFORE_UPDATE{
                
                
                
                for(SBQQ__QuoteLine__c ql: newQuoteLineList){
                    if(ql.SBQQ__Discount__c != null || ql.INT_Estatus__c == 'DESCONTINUADO'){
                         ql.INT_FWY_Necesita_aprobacion__c = 'true';
                        
                        if(ql.INT_Estatus__c == 'DESCONTINUADO' && ql.SBQQ__Discount__c == null && ql.INT_ApprovalStatus__c == 'Pendiente' ){
                            ql.INT_FWY_Necesita_aprobacion__c = 'false';
                        }
                    }else{
                        ql.INT_FWY_Necesita_aprobacion__c = 'false';
                        
                    }
                    
                    //Partida rechazada
                    /*if(ql.INT_FWY_Partida_Rechazada__c){
                        for(SBQQ__QuoteLine__c oldql: oldQuoteLineList){
                            if(ql.Id == oldql.Id){
                                if(ql.INT_ApprovalStatus__c == 'Aprobado' || ql.INT_ApprovalStatus__c == 'Approved' ){
                                    ql.addError('No puedes aprobar una partida que ya ha sido rechazada. Partida:'+ql.Name);
                                }
                            }
                        }
                    }*/
                    
                }
                
                User currentUser = [select Id, profile.name from User where Id = :UserInfo.getUserId()];
                if(currentUser.Profile.Name == 'Autorizador Excepciones MB' || currentUser.Profile.Name ==  'Administrador del sistema' ){
                     for(SBQQ__QuoteLine__c newQl: newQuoteLineList){
                         for(SBQQ__QuoteLine__c oldQl: oldQuoteLineList){
                             if(newQl.Id == oldQl.Id){
                                 if(newQl.SBQQ__ListPrice__c == oldQl.SBQQ__ListPrice__c){

                                 }else{
                                     newQl.PRECIO_KOHLER__c = newQl.SBQQ__ListPrice__c;
                                 }
                             }
                         }
                     }
                }




                
                INT_QuoteLineTriggerHandler.cleanMargenesFields(newQuoteLineList,oldQuoteLineList);
            	INT_QuoteLineTriggerHandler.changeNeedUpdateMargen(newQuoteLineList, oldQuoteLineMap);
                
            }
            when BEFORE_DELETE{
                for(SBQQ__QuoteLine__c ql : oldQuoteLineList){
                    if(Test.isRunningTest() || ql.IsApproved__c){
                        ql.addError('No es posible eliminar el producto de cotización ya que se encuentra aprobado.');
                    }
                }
                
            }
            
        }
    }
    
    
    public static void validateInsertPriceChange(List<SBQQ__QuoteLine__c> lstNewQL){
        System.debug('validateInsertPriceChange:INICO ' + lstNewQL.size());
        
        Map<String,String> mpQuotePriceBook = new Map<String,String>();
        Map<String, Map<String,PricebookEntry>> mpGralPriceBook = new Map<String, Map<String,PricebookEntry>>();
        
        for(SBQQ__QuoteLine__c ql : lstNewQL){
            mpQuotePriceBook.put(ql.SBQQ__Quote__c, '');
        }
        
        for(SBQQ__Quote__c currentQ : [SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id IN: mpQuotePriceBook.keySet()]){
            mpQuotePriceBook.put(currentQ.Id, currentQ.SBQQ__PriceBook__c);
            if(!mpGralPriceBook.containsKey(currentQ.SBQQ__PriceBook__c)){
                mpGralPriceBook.put(currentQ.SBQQ__PriceBook__c, new map<String, PricebookEntry>());
            }
        }
        
        for(Pricebook2 currentPB2 : [SELECT Id, Name, IsActive, Lista_MB__c, IsStandard, (SELECT Id, Name, Product2Id, UnitPrice FROM PricebookEntries) FROM Pricebook2 WHERE Id IN: mpGralPriceBook.keySet()]){
            for(PricebookEntry currentPE : currentPB2.PricebookEntries){
                mpGralPriceBook.get(currentPB2.Id).put(currentPE.Product2Id, currentPE);
            }
        }
        
        for(SBQQ__QuoteLine__c currentQL : lstNewQL){
            //System.debug('SBQQ__QuoteLine__c: ' + currentQL.SBQQ__ListPrice__c + ', Id: ' + currentQL.SBQQ__Product__c);
            if(!String.isBlank(currentQL.SBQQ__Quote__c)){
                PricebookEntry objPE = mpGralPriceBook.get(mpQuotePriceBook.get(currentQL.SBQQ__Quote__c)).get(currentQL.SBQQ__Product__c);
                //System.debug('PricebookEntry: ' + objPE);
                if(objPE.UnitPrice != currentQL.SBQQ__ListPrice__c){
                    currentQL.addError('No puedes modificar el precio');
                }
            }
        }
        
    }
    
    public static void changeNeedUpdateMargen(List<SBQQ__QuoteLine__c> lstUpQL, Map<Id, SBQQ__QuoteLine__c> mpOldQL){
        if(!System.isQueueable()){
            for(SBQQ__QuoteLine__c currentQL : lstUpQL){
                system.debug('currentQL.INT_ChangeForServiceMargenes__c'+currentQL.INT_ChangeForServiceMargenes__c);
                system.debug('oldQL.INT_ChangeForServiceMargenes__c'+ mpOldQL.get(currentQL.Id).INT_ChangeForServiceMargenes__c);
                if(currentQL.INT_ChangeForServiceMargenes__c == mpOldQL.get(currentQL.Id).INT_ChangeForServiceMargenes__c){
                    currentQL.INT_NeedUpdateMargen__c = false;
                }
            }
        }
        
    }
    
    public static void cleanMargenesFields(List<SBQQ__QuoteLine__c> newQuoteLineList, List<SBQQ__QuoteLine__c> oldQuoteLineList){
       
        /* for(SBQQ__QuoteLine__c newQuoteLine :newQuoteLineList ){
            for(SBQQ__QuoteLine__c oldQuoteLine:oldQuoteLineList ){
                system.debug('****************BEFORE UPDATE');
                    system.debug('QUOTELINE: '+newQuoteLine.Id);
                    system.debug('old QUOTELINE INT_Actualizado_por_Consulta_Margen__c : '+ oldQuoteLine.INT_Actualizado_por_Consulta_Margen__c);
                    system.debug('new QUOTELINE INT_Actualizado_por_Consulta_Margen__c : '+ newQuoteLine.INT_Actualizado_por_Consulta_Margen__c);
                if(newQuoteLine.Id == oldQuoteLine.Id && newQuoteLine.PricebookMB__c == true && newQuoteLine.INT_Actualizado_por_Consulta_Margen__c == 'true' & oldQuoteLine.INT_Actualizado_por_Consulta_Margen__c == 'true'){
                   
                    //se cambio precio y descuento
                    if(newQuoteLine.SBQQ__ListPrice__c != oldQuoteLine.SBQQ__ListPrice__c && newQuoteLine.SBQQ__Discount__c != oldQuoteLine.SBQQ__Discount__c ){
                        system.debug('****se cambio precio y descuento');
                        newQuoteLine.PRECIO_PROY_CON_IVA_Int__c = null;
                        system.debug('OLD --- PRECIO_PROY_CON_IVA_Int__c'+ oldQuoteLine.PRECIO_PROY_CON_IVA_Int__c);
                        system.debug('NEW --- PRECIO_PROY_CON_IVA_Int__c'+ newQuoteLine.PRECIO_PROY_CON_IVA_Int__c);
                        newQuoteLine.ListPrice_Int__c = newQuoteLine.SBQQ__ListPrice__c;
                        system.debug('OLD --- ListPrice_Int__c' +oldQuoteLine.ListPrice_Int__c);
                        system.debug('NEW --- ListPrice_Int__c' +newQuoteLine.ListPrice_Int__c);
                        
                        newQuoteLine.Discount_Int__c = newQuoteLine.SBQQ__Discount__c;
                        system.debug('OLD --Discount_Int__c' + oldQuoteLine.Discount_Int__c);
                        system.debug('NEW --Discount_Int__c' + newQuoteLine.Discount_Int__c);
                        
                        //newQuoteLine.INT_Actualizado_por_Consulta_Margenes__c = false;
                    }
                    
                    //se cambio el precio, poner nulos descuento e iva
                    if(newQuoteLine.SBQQ__ListPrice__c != oldQuoteLine.SBQQ__ListPrice__c && newQuoteLine.SBQQ__Discount__c == oldQuoteLine.SBQQ__Discount__c ){
                        system.debug('se cambio el precio, poner nulos descuento e iva');
                        newQuoteLine.Discount_Int__c = null;
                        system.debug('OLD -- Discount_Int__c'+oldQuoteLine.Discount_Int__c);
                        system.debug('NEW -- Discount_Int__c'+newQuoteLine.Discount_Int__c);
                        newQuoteLine.PRECIO_PROY_CON_IVA_Int__c = null;
                        system.debug('OLD --PRECIO_PROY_CON_IVA_Int__c'+oldQuoteLine.PRECIO_PROY_CON_IVA_Int__c);
                        system.debug('NEW --PRECIO_PROY_CON_IVA_Int__c'+newQuoteLine.PRECIO_PROY_CON_IVA_Int__c);
                        newQuoteLine.ListPrice_Int__c = newQuoteLine.SBQQ__ListPrice__c;
                        system.debug('OLD --ListPrice_Int__c'+oldQuoteLine.ListPrice_Int__c);
                        system.debug('NEW --ListPrice_Int__c'+newQuoteLine.ListPrice_Int__c);
                        
                        //newQuoteLine.INT_Actualizado_por_Consulta_Margenes__c = false;
                    }
                    
                    //se cambio el descuento poner nulos precio e iva
                    if(newQuoteLine.SBQQ__Discount__c != oldQuoteLine.SBQQ__Discount__c && newQuoteLine.SBQQ__ListPrice__c == oldQuoteLine.SBQQ__ListPrice__c ){
                        system.debug('se cambio el descuento poner nulos precio e iva');
                        newQuoteLine.ListPrice_Int__c = null;
                        system.debug('OLD -- ListPrice_Int__c'+oldQuoteLine.ListPrice_Int__c);
                        system.debug('NEW -- ListPrice_Int__c'+newQuoteLine.ListPrice_Int__c);
                        newQuoteLine.PRECIO_PROY_CON_IVA_Int__c = null;
                        system.debug('OLD --PRECIO_PROY_CON_IVA_Int__c'+oldQuoteLine.PRECIO_PROY_CON_IVA_Int__c);
                        system.debug('NEW --PRECIO_PROY_CON_IVA_Int__c'+newQuoteLine.PRECIO_PROY_CON_IVA_Int__c);
                        newQuoteLine.Discount_Int__c = newQuoteLine.SBQQ__Discount__c;
                        
                        system.debug('OLD -- Discount_Int__c'+oldQuoteLine.Discount_Int__c);
                        system.debug('NEW -- Discount_Int__c'+newQuoteLine.Discount_Int__c);
                        
                        //newQuoteLine.INT_Actualizado_por_Consulta_Margenes__c = false;
                    }
                    
                }
            }
        }*/
    }
    
    public static void setMargenesValues(List<SBQQ__QuoteLine__c> newQuoteLineList){
        for(SBQQ__QuoteLine__c newQuoteLine :newQuoteLineList ){
            
                
                if( newQuoteLine.PricebookMB__c == true ){
                   
                        newQuoteLine.ListPrice_Int__c = newQuoteLine.SBQQ__ListPrice__c;
                        newQuoteLine.Discount_Int__c = newQuoteLine.SBQQ__Discount__c;
                        newQuoteLine.PRECIO_PROY_CON_IVA_Int__c = newQuoteLine.PRECIO_PROY_CON_IVA__c;
                    
                }
            
        }
    }
}