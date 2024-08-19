/**
 * @description       : Batch class in order to reassign approvers to quotes items not approved/rejected in 24 hrs after 
 * @author            : esalas@freewayconsulting.com
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : esalas@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-09-2023   esalas@freewayconsulting.com   Initial Version
**/

public with sharing class BatchableReassignApprovers implements Database.Batchable<SObject> {
    public final String TITLE = 'Se requiere su aprobación';
    public final String BODY = 'Se han reasignado registros a aprobar para su Usuario';
    public final String templateId;

    public BatchableReassignApprovers() {
        templateId = Aprobador__mdt.getInstance('TEMPLATE_EMAIL_APPROVAL').Id_Aprobador_Nivel_1__c;
    }
    
    public Database.QueryLocator start(Database.BatchableContext info) {
        Integer hoursToReassign = -Integer.valueOf(Reassign_Config__c.getOrgDefaults().Reassign_after__c);
        String startDateTime = DateTime.now().addHours(hoursToReassign).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss').substring(0,14)+'00:00Z';
        String endDateTime = DateTime.now().addHours(hoursToReassign).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss').substring(0,14)+'59:59Z';
        String queryFields = 'Estado_Aprobacion_Nivel_1__c, Aprobador_Nivel_1__c, Aprobador_Nivel_1__r.DelegatedApproverId, Estado_Aprobacion_Nivel_2__c, Aprobador_Nivel_2__c, Aprobador_Nivel_2__r.DelegatedApproverId, Estado_Aprobacion_Nivel_3__c, Aprobador_Nivel_3__c, Aprobador_Nivel_3__r.DelegatedApproverId, Estado_Aprobacion_Nivel_4__c, Aprobador_Nivel_4__c, Aprobador_Nivel_4__r.DelegatedApproverId, Estado_Aprobacion_Nivel_5__c, Aprobador_Nivel_5__c, Aprobador_Nivel_5__r.DelegatedApproverId, Estado_Aprobacion_Nivel_6__c, Aprobador_Nivel_6__c, Aprobador_Nivel_6__r.DelegatedApproverId, Grupos_de_productos__r.Fecha_Ultima_Aprobacion__c, Grupos_de_productos__c ';
        String queryClause = 'Grupos_de_productos__r.Fecha_Ultima_Aprobacion__c >= '+ startDateTime + ' AND Grupos_de_productos__r.Fecha_Ultima_Aprobacion__c <= ' + endDateTime + ' AND Grupos_de_productos__r.Aprobado__c = false AND Grupos_de_productos__r.No_aprobado__c = false AND (Estado_Aprobacion_Nivel_1__c = null OR Estado_Aprobacion_Nivel_2__c = null OR Estado_Aprobacion_Nivel_3__c = null OR Estado_Aprobacion_Nivel_4__c = null OR Estado_Aprobacion_Nivel_5__c = null OR Estado_Aprobacion_Nivel_6__c = null)';
        String query = 'SELECT ' + queryFields + ' FROM SBQQ__QuoteLine__c WHERE ' + queryClause;
        return Database.getquerylocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> quoteLineItems) {
        System.debug('Scope: '+quoteLineItems);
        Map<String, Set<String>> notifications = new Map<String, Set<String>>();
        for(SBQQ__QuoteLine__c item : quoteLineItems) {
            if(notifications.get(item.Grupos_de_productos__c) == null) {
                notifications.put(item.Grupos_de_productos__c, new Set<String>());
            }
            System.debug('item: ' + item);
            if(String.isBlank(item.Estado_Aprobacion_Nivel_1__c) && item.Aprobador_Nivel_1__r.DelegatedApproverId != null) {
                item.Aprobador_Nivel_1__c = item.Aprobador_Nivel_1__r.DelegatedApproverId;
                notifications.get(item.Grupos_de_productos__c).add(item.Aprobador_Nivel_1__r.DelegatedApproverId);
            } else if(String.isBlank(item.Estado_Aprobacion_Nivel_2__c) && item.Aprobador_Nivel_2__r.DelegatedApproverId != null ) {
                item.Aprobador_Nivel_2__c = item.Aprobador_Nivel_2__r.DelegatedApproverId;
                notifications.get(item.Grupos_de_productos__c).add(item.Aprobador_Nivel_2__r.DelegatedApproverId);
            } else if(String.isBlank(item.Estado_Aprobacion_Nivel_3__c) && item.Aprobador_Nivel_3__r.DelegatedApproverId != null) {
                item.Aprobador_Nivel_3__c = item.Aprobador_Nivel_3__r.DelegatedApproverId;
                notifications.get(item.Grupos_de_productos__c).add(item.Aprobador_Nivel_3__r.DelegatedApproverId);
            } else if(String.isBlank(item.Estado_Aprobacion_Nivel_4__c) && item.Aprobador_Nivel_4__r.DelegatedApproverId != null) {
                item.Aprobador_Nivel_4__c = item.Aprobador_Nivel_4__r.DelegatedApproverId;
                notifications.get(item.Grupos_de_productos__c).add(item.Aprobador_Nivel_4__r.DelegatedApproverId);
            } else if(String.isBlank(item.Estado_Aprobacion_Nivel_5__c) && item.Aprobador_Nivel_5__r.DelegatedApproverId != null) {
                item.Aprobador_Nivel_5__c = item.Aprobador_Nivel_5__r.DelegatedApproverId;
                notifications.get(item.Grupos_de_productos__c).add(item.Aprobador_Nivel_5__r.DelegatedApproverId);
            } else if(String.isBlank(item.Estado_Aprobacion_Nivel_6__c) && item.Aprobador_Nivel_6__r.DelegatedApproverId != null) {
                item.Aprobador_Nivel_6__c = item.Aprobador_Nivel_6__r.DelegatedApproverId;
                notifications.get(item.Grupos_de_productos__c).add(item.Aprobador_Nivel_6__r.DelegatedApproverId);
            }
            System.debug('item new: ' + item);
        }
        update quoteLineItems;
        for(String key : notifications.keySet()) {
            if(notifications.get(key).size() > 0) {
                INT_Utility.sendApprovalNotification(notifications.get(key), key, TITLE, BODY);
                for(String userId : notifications.get(key)) {
                    INT_Utility.sendApprovalEmail(templateId, key, userId);
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.Debug('FINISHED JOB');
    }
}