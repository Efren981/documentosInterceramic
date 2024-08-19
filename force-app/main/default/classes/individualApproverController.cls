/**
* @description       : This code could be used to display a list of quote line items for a particular quote on a Lightning component.
* @author            : emeza@freewayconsulting.com
* @group             : 
* @last modified on  : 09-25-2023
* @last modified by  : emeza@freewayconsulting.com
* Modifications Log
* Ver   Date         Author                        Modification
* 1.0   08-31-2023   emeza@freewayconsulting.com   Initial Version
**/
public with sharing class individualApproverController {
    /**
    * @description fetch and potentially cache a list of quote line items (SBQQ__QuoteLine__c) based on a provided quote ID and group ID. It also adjusts the discount values from percentage format to decimal format in the retrieved records.
    * @author emeza@freewayconsulting.com | 09-05-2023 
    * @param String quoteId 
    * @param String groupId 
    * @return List<SBQQ__QuoteLine__c> 
    **/
    @AuraEnabled( cacheable = true )
    public static List< SBQQ__QuoteLine__c > fetchQuoteLineItems( String quoteId, String groupId ) {
        List< SBQQ__QuoteLine__c > lstQuoteLineItems = [ SELECT Id, Name,SBQQ__Quote__c,SBQQ__ProductCode__c,Aprobador_Nivel_1__c,Aprobador_Nivel_2__c,Aprobador_Nivel_3__c,Aprobador_Nivel_4__c,Aprobador_Nivel_5__c,Aprobador_Nivel_6__c,Estado_Aprobacion_Nivel_1__c,Estado_Aprobacion_Nivel_2__c,Estado_Aprobacion_Nivel_3__c,Estado_Aprobacion_Nivel_4__c,Estado_Aprobacion_Nivel_5__c,Estado_Aprobacion_Nivel_6__c,SBQQ__Quantity__c,SBQQ__NetTotal__c,SBQQ__Discount__c,SBQQ__OriginalPrice__c,SBQQ__AdditionalDiscount__c,PRECIO_DESCUENTO__c,IMPORTE_BRUTO__c,MARGEN_CONSOLIDADO_PORC__c,MARGEN_CONSOLIDADO__c,PRECIO_BASE__c,DESCTO_PROY_PORC__c,PRECIO_PROY_SIN_IVA__c,TOTAL_PROYECTO__c,MARGEN_PORC__c,MARGEN__c,UTILIDAD_CONSOLIDADA__c, INT_Tipo_CPQ__c,Grupos_de_productos__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, INT_Nombre_de_producto__c, SBQQ__ListPrice__c FROM SBQQ__QuoteLine__c WHERE 	SBQQ__Quote__c =: quoteId AND Grupos_de_productos__c=:groupId FOR UPDATE];
        for (SBQQ__QuoteLine__c li : lstQuoteLineItems) {
            if(li.SBQQ__Discount__c != null) li.SBQQ__Discount__c = li.SBQQ__Discount__c/100;
            if(li.DESCTO_PROY_PORC__c != null) li.DESCTO_PROY_PORC__c = li.DESCTO_PROY_PORC__c/100;
            if(li.MARGEN_PORC__c != null) li.MARGEN_PORC__c = li.MARGEN_PORC__c/100;
            if(li.MARGEN_CONSOLIDADO_PORC__c != null) li.MARGEN_CONSOLIDADO_PORC__c = li.MARGEN_CONSOLIDADO_PORC__c/100;
        }
        return lstQuoteLineItems;
    }

    /**
    * @description update certain fields in a group approval record (Grupo_de_productos_a_aprobar__c) and a list of quote line records (SBQQ__QuoteLine__c) while performing user validation based on approval status and assigned approvers. If the validation conditions are not met, it throws an exception with an appropriate error message.
    * @author emeza@freewayconsulting.com | 09-05-2023 
    * @param SBQQ__QuoteLine__c[] lstQLIUpdate 
    **/
    @AuraEnabled
    public static void updateQLI(SBQQ__QuoteLine__c[] lstQLIUpdate, String comments) {
        System.debug('lstQLIUpdate'+lstQLIUpdate[0].Estado_Aprobacion_Nivel_1__c);
        
        // Set of users to be notified when approbed or rejected
        Set<String> setQuoteCreators = new Set<String>();
        //Quote Id record related to Quote Line Items
        Id quoteId;
        // First element in lstQLIUpdate param
        SBQQ__QuoteLine__c fstQLI = lstQLIUpdate[0];
        //If list contains discontinued records when rejected must be deleted
        SBQQ__QuoteLine__c[] qliDelete = new List<SBQQ__QuoteLine__c>();
        //Query to bring group approval record detail
        Grupo_de_productos_a_aprobar__c groupApprove = [SELECT Id,Name, No_aprobado__c,Aprobado__c,Fecha_Ultima_Aprobacion__c,Descontinuado__c,Comentarios_Aprobadores__c,Cotizacion__c,Cotizacion__r.Name,Cotizacion__r.CreatedById FROM Grupo_de_productos_a_aprobar__c WHERE Id =:fstQLI.Grupos_de_productos__c FOR UPDATE];
        Savepoint sp = Database.setSavepoint();
        //Add Quote creator as recipient to notfications
        setQuoteCreators.add(groupApprove.Cotizacion__r.CreatedById);
        //Iterate QLI list to determine if has rejected records
        for (SBQQ__QuoteLine__c qli : lstQLIUpdate){
            if (qli.Estado_Aprobacion_Nivel_1__c == 'Rejected' || qli.Estado_Aprobacion_Nivel_2__c == 'Rejected' || qli.Estado_Aprobacion_Nivel_3__c == 'Rejected' || qli.Estado_Aprobacion_Nivel_4__c == 'Rejected' || qli.Estado_Aprobacion_Nivel_5__c == 'Rejected' || qli.Estado_Aprobacion_Nivel_6__c == 'Rejected') {
                // Add the Quote Id to the list if a rejected item is found
                quoteId = qli.SBQQ__Quote__c;
                groupApprove.No_aprobado__c = true;
                if(groupApprove.Descontinuado__c) qliDelete.add(qli);
            }
        }
        /*if(fstQLI.Estado_Aprobacion_Nivel_3__c != null & fstQLI.Aprobador_Nivel_3__c!= currentUserId) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Estado_Aprobacion_Nivel_2__c != null & fstQLI.Aprobador_Nivel_2__c!= currentUserId && fstQLI.Estado_Aprobacion_Nivel_3__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Aprobador_Nivel_1__c!= currentUserId && fstQLI.Estado_Aprobacion_Nivel_2__c == null && fstQLI.Estado_Aprobacion_Nivel_3__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');*/
        // Fill groupApprove fields with datetime and comments data
        groupApprove.Fecha_Ultima_Aprobacion__c = System.now();
        if(String.isBlank(groupApprove.Comentarios_Aprobadores__c)){
            groupApprove.Comentarios_Aprobadores__c = '';
        }
        groupApprove.Comentarios_Aprobadores__c+= '\n'+comments;
        //Group and QLI to be updated
        System.debug(qliDelete);
        Boolean isApproved = sendHelperNotif(fstQLI,quoteId,groupApprove,setQuoteCreators);
        //Send notification to quote owner when approved
        if(isApproved && quoteId == null){
            groupApprove.Aprobado__c = true;
            INT_Utility.sendApprovalNotification(setQuoteCreators,groupApprove.Id,'Grupo de productos aprobado','El grupo de productos número '+groupApprove.Name+' ha sido aprobado, ingresa para mayor detalle');
        }
        //Id qliDelete array has elements, quote owner must be notified to know QLI to be deleted for discontinued records rejected
        if(!qliDelete.isEmpty()){
            //Message to be sent in custom notification
            String message = 'Productos descontinuados rechazados: ';
            //Fill message text
            for (SBQQ__QuoteLine__c qli : lstQLIUpdate) message+= message == 'Productos descontinuados rechazados: '? qli.SBQQ__ProductCode__c:', '+ qli.SBQQ__ProductCode__c;
            //Send notification
            INT_Utility.sendApprovalNotification(setQuoteCreators,groupApprove.Id,'Descontinuados rechazados de cotización '+groupApprove.Cotizacion__r.Name,message);
        }
        try {
            Database.update( groupApprove,true);
            
            Database.update( lstQLIUpdate,true);
            system.debug('update lstQLIUpdate '+lstQLIUpdate[0].Estado_Aprobacion_Nivel_1__c);
            //if(!qliDelete.isEmpty()) Database.delete(qliDelete,true);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
        if(groupApprove.Descontinuado__c){
            SBQQ__QuoteLine__c[] lstQLIUDiscApproved = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c[] lstQLIUDisc = [SELECT Id, IsApproved__c, Confirmar_Aprobacion_Descontinuado__c,INT_Tipo_CPQ__c,Tipo_producto__c,Clasificacion__c,SBQQ__Discount__c,SBQQ__Product__r.INT_Status__c FROM SBQQ__QuoteLine__c WHERE Id IN:lstQLIUpdate];
            for(SBQQ__QuoteLine__c qli : lstQLIUDisc){
                if(qli.IsApproved__c){
                    qli.Confirmar_Aprobacion_Descontinuado__c = true;
                    qli.Estado_Aprobacion_Nivel_1__c = null; 
                    lstQLIUDiscApproved.add(qli);
                }
            }
            if(!lstQLIUDiscApproved.isEmpty()) update lstQLIUDiscApproved;
            //if(!lstQLIUDiscApproved.isEmpty()) ApprovalGrupoHelper.executeApprovalGroupProccess(groupApprove.Cotizacion__c,lstQLIUDiscApproved);
                
        }
    }
    public static Boolean sendHelperNotif(SBQQ__QuoteLine__c fstQLI, Id quoteId, Grupo_de_productos_a_aprobar__c groupApprove,Set<String> setQuoteCreators){
        //Boolean to trigger notification to levels users approval if applies
        Boolean notifySecondLevel = false;
        Boolean notifyThirdLevel = false;
        Boolean notifyFourthLevel = false;
        Boolean notifyFifthLevel = false;
        Boolean notifySixthLevel = false;
        // Get the current user's ID
        Id currentUserId = UserInfo.getUserId();
        //Variable that contolles the approvals
        Boolean isApproved = false;
        //If has all approvals isApproved boolean variable is marked
        if((fstQLI.Estado_Aprobacion_Nivel_1__c == 'Approved' && fstQLI.Aprobador_Nivel_2__c == null) || (fstQLI.Estado_Aprobacion_Nivel_2__c == 'Approved' && fstQLI.Aprobador_Nivel_3__c == null) || (fstQLI.Estado_Aprobacion_Nivel_3__c == 'Approved' && fstQLI.Aprobador_Nivel_4__c == null)|| (fstQLI.Estado_Aprobacion_Nivel_4__c == 'Approved' && fstQLI.Aprobador_Nivel_5__c == null)|| (fstQLI.Estado_Aprobacion_Nivel_5__c == 'Approved' && fstQLI.Aprobador_Nivel_6__c == null)|| (fstQLI.Estado_Aprobacion_Nivel_6__c == 'Approved')) isApproved = true;
        //if first level has been approved an second level is populated mark notifySecondLevel variable as true
        if(fstQLI.Estado_Aprobacion_Nivel_1__c == 'Approved' && fstQLI.Aprobador_Nivel_2__c != null && fstQLI.Estado_Aprobacion_Nivel_2__c == null) notifySecondLevel = true;
        //if second level has been approved an third level is populated mark notifyThirdLevel variable as true
        if(fstQLI.Estado_Aprobacion_Nivel_2__c == 'Approved' && fstQLI.Aprobador_Nivel_3__c != null && fstQLI.Estado_Aprobacion_Nivel_3__c == null) notifyThirdLevel = true;
        //if second level has been approved an fourth level is populated mark notifyFourthLevel variable as true
        if(fstQLI.Estado_Aprobacion_Nivel_3__c == 'Approved' && fstQLI.Aprobador_Nivel_4__c != null && fstQLI.Estado_Aprobacion_Nivel_4__c == null) notifyFourthLevel = true;
        //if second level has been approved an fifth level is populated mark notifyFifthLevel variable as true
        if(fstQLI.Estado_Aprobacion_Nivel_4__c == 'Approved' && fstQLI.Aprobador_Nivel_5__c != null && fstQLI.Estado_Aprobacion_Nivel_5__c == null) notifyFifthLevel = true;
        //if second level has been approved an sixth level is populated mark notifySixthLevel variable as true
        if(fstQLI.Estado_Aprobacion_Nivel_5__c == 'Approved' && fstQLI.Aprobador_Nivel_6__c != null && fstQLI.Estado_Aprobacion_Nivel_6__c == null) notifySixthLevel = true;
        // Controlles if current user is appropiate to approve all current records
        if(fstQLI.Estado_Aprobacion_Nivel_6__c != null & fstQLI.Aprobador_Nivel_6__c!= currentUserId) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Estado_Aprobacion_Nivel_5__c != null & fstQLI.Aprobador_Nivel_5__c != currentUserId && fstQLI.Estado_Aprobacion_Nivel_6__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Estado_Aprobacion_Nivel_4__c != null & fstQLI.Aprobador_Nivel_4__c != currentUserId && fstQLI.Estado_Aprobacion_Nivel_5__c == null && fstQLI.Estado_Aprobacion_Nivel_6__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Estado_Aprobacion_Nivel_3__c != null & fstQLI.Aprobador_Nivel_3__c != currentUserId && fstQLI.Estado_Aprobacion_Nivel_4__c == null && fstQLI.Estado_Aprobacion_Nivel_5__c == null && fstQLI.Estado_Aprobacion_Nivel_6__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Estado_Aprobacion_Nivel_2__c != null & fstQLI.Aprobador_Nivel_2__c != currentUserId && fstQLI.Estado_Aprobacion_Nivel_3__c == null && fstQLI.Estado_Aprobacion_Nivel_4__c == null && fstQLI.Estado_Aprobacion_Nivel_5__c == null && fstQLI.Estado_Aprobacion_Nivel_6__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        else if(fstQLI.Estado_Aprobacion_Nivel_1__c != null & fstQLI.Aprobador_Nivel_1__c != currentUserId && fstQLI.Estado_Aprobacion_Nivel_2__c == null && fstQLI.Estado_Aprobacion_Nivel_3__c == null && fstQLI.Estado_Aprobacion_Nivel_4__c == null && fstQLI.Estado_Aprobacion_Nivel_5__c == null && fstQLI.Estado_Aprobacion_Nivel_6__c == null) throw new AuraHandledException('La aprobación que estás realizando no corresponde a tu usuario');
        if(quoteId != null){
            //Send notification
            INT_Utility.sendApprovalNotification(setQuoteCreators,groupApprove.Id,'Grupo de productos rechazado','El grupo de productos número '+groupApprove.Name+' ha sido rechazado, ingresa para mayor detalle');
        }
        System.debug('notifySecondLevel'+notifySecondLevel);
        System.debug('notifyThirdLevel'+notifyThirdLevel);
        //TemplateId to send emails
        String templateId = Aprobador__mdt.getInstance('TEMPLATE_EMAIL_APPROVAL').Id_Aprobador_Nivel_1__c;
        //Send custom notification to Levels Approver user
        //Se añadio cambio para mandar nro. cotización en la notificación
        string idQuote = fstQLI.SBQQ__Quote__c;
        List<SBQQ__Quote__c> quoteName = [select  name from SBQQ__Quote__c where id =: idQuote];
        if(notifySecondLevel && quoteId == null) distributeNotifications(fstQLI.Aprobador_Nivel_2__c,groupApprove.Id,templateId, quoteName[0].Name);
        if(notifyThirdLevel && quoteId == null) distributeNotifications(fstQLI.Aprobador_Nivel_3__c,groupApprove.Id,templateId, quoteName[0].Name);
        if(notifyFourthLevel && quoteId == null) distributeNotifications(fstQLI.Aprobador_Nivel_4__c,groupApprove.Id,templateId, quoteName[0].Name);
        if(notifyFifthLevel && quoteId == null) distributeNotifications(fstQLI.Aprobador_Nivel_5__c,groupApprove.Id,templateId, quoteName[0].Name);
        if(notifySixthLevel && quoteId == null) distributeNotifications(fstQLI.Aprobador_Nivel_6__c,groupApprove.Id,templateId, quoteName[0].Name);
        return isApproved;
    }
    public static void distributeNotifications(Id levelApproverId, Id groupApproveId,String templateId, string quoteName){
        // Set of user to be notified when lower level is approved and they must approve next level
        Set<String> setLevelApprovers = new Set<String>();
        setLevelApprovers.add(levelApproverId);
        INT_Utility.sendApprovalNotification(setLevelApprovers, groupApproveId, 'Se requiere su aprobación. Cotización '+quoteName, 'Se han asignado registros a aprobar para su usuario');
        INT_Utility.sendApprovalEmail(templateId,groupApproveId, levelApproverId);
    }

}