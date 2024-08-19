public without sharing class ApprovalGrupoController {
    
    @AuraEnabled
    public static List<String> executeApprovalFlow(Id recordId) {
        
        List<String> response = new List<String>();
        List<SBQQ__QuoteLine__c> lstProduct = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lstProductDiscontinuedFirstApproved = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lstProductDiscontinuedNotApproved = new List<SBQQ__QuoteLine__c>();
        Boolean flagError = false;
        
        try{
            SBQQ__Quote__c cotizacion = [ SELECT id, name, SBQQ__ListAmount__c,Excepcion__c, (SELECT Id, Name, Cotizacion__c, Nivel__c, Excepcion__c, Descontinuado__c, Tipo_de_producto__c, Aprobado__c, No_aprobado__c FROM Grupos_de_productos_a_aprobar__r) FROM SBQQ__Quote__c WHERE id = :recordId];

            for(SBQQ__QuoteLine__c quoteLineItem : [SELECT id,SBQQ__Discount__c,Tipo_producto__c, 	Clasificacion__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, Confirmar_Aprobacion_Descontinuado__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Estado_Aprobacion_Nivel_1__c, INT_NeedUpdateMargen__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recordId AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)]){
                if(ApprovalGrupoController.validateConsultaMargen(quoteLineItem)){
                    flagError = true;
                }else{
                    if(quoteLineItem.SBQQ__Product__r.INT_Status__c == 'DESCONTINUADO' && !quoteLineItem.Confirmar_Aprobacion_Descontinuado__c && quoteLineItem.Estado_Aprobacion_Nivel_1__c == null){
                        lstProductDiscontinuedFirstApproved.add(quoteLineItem);
                    }else if(quoteLineItem.SBQQ__Product__r.INT_Status__c == 'DESCONTINUADO' && quoteLineItem.Estado_Aprobacion_Nivel_1__c == 'Rejected'){
                        lstProductDiscontinuedNotApproved.add(quoteLineItem);
                    }else{
                        lstProduct.add(quoteLineItem);
                    }
                }  
            }

            System.debug('lstProduct:SIZE: ' + lstProduct.size() + ', lstProduct: ' + lstProduct);
            System.debug('lstProductDiscontinuedFirstApproved:SIZE: ' + lstProductDiscontinuedFirstApproved.size() + ', lstProductDiscontinuedFirstApproved: ' + lstProductDiscontinuedFirstApproved);
            System.debug('lstProductDiscontinuedNotApproved:SIZE: ' + lstProductDiscontinuedNotApproved.size() + ', lstProductDiscontinuedNotApproved: ' + lstProductDiscontinuedNotApproved);

            if(!flagError){
                if(lstProductDiscontinuedFirstApproved.size() > 0){
                    response = ApprovalGrupoHelper.executeApprovalGroupProccess(cotizacion.Id, lstProductDiscontinuedFirstApproved, true);
                }else if(lstProductDiscontinuedNotApproved.size() > 0){
                    response.add('ERROR');
                    response.add('Tu cotización tiene productos descontinuados no aprobados, eliminalos antes de enviar a aprobar!');
                }else{
                    response = ApprovalGrupoHelper.executeApprovalGroupProccess(cotizacion.Id, lstProduct, false);
                }
            }else{
                response.add('ERROR');
                response.add('Debe de consultar margenes primero para enviar aprobar!');
            }
        }catch(Exception e){
            System.debug('ERROR: ' + e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString());
            response.add('ERROR');
            response.add(e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString());
        }
        
        return response;
    }


    public static Boolean validateConsultaMargen(SBQQ__QuoteLine__c quoteLineItem){
        Boolean response = false;

        if(quoteLineItem.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c && quoteLineItem.SBQQ__Discount__c == null){
            response = true;
        }else if(!quoteLineItem.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c && String.isBlank(quoteLineItem.INT_Estatus_margen__c)){
            response = true;
        }else if(!quoteLineItem.INT_NeedUpdateMargen__c){
            response = true;
        }

        return response;
    }
    
}