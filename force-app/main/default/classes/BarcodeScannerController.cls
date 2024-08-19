/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-29-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-26-2023   emeza@freewayconsulting.com   Initial Version
**/
public with sharing class BarcodeScannerController {
    @AuraEnabled
    public static Id createLeads(String firstName, String lastName, String org, String email, String phone, String city,String state){
        try {
            System.debug('body '+firstName+' '+lastName +' \nOrg:'+org+'\n email: '+email+'\n phone: '+phone+'\n state: '+state+'\n city: '+city);
            List<Ciudad__c> ciudad = new List<Ciudad__c>();
            List<Estado__c> estado = new List<Estado__c>();
            Pais__c[] pais = [SELECT Id FROM Pais__c WHERE Name Like 'MEX%' LIMIT 1];
            if(!pais.isEmpty()) estado = [SELECT Id FROM Estado__c WHERE Name LIKE:state AND INT_Pais__c =: pais[0].Id LIMIT 1];
            if(!estado.isEmpty()) ciudad = [SELECT Id FROM Ciudad__c WHERE Name LIKE:city AND INT_Estado__c=:estado[0].Id LIMIT 1];
            System.debug(estado);
            System.debug(ciudad);
            Campaign[] cmp = [SELECT Id FROM Campaign WHERE Name = 'OBRA BLANCA 2023' LIMIT 1];
            Lead ld = new Lead(
                FirstName = firstName,
                LastName = lastName,
                Company = org,
                Email = email,
                MobilePhone = phone,
                INT_Estado__c = !estado.isEmpty()? estado[0].Id: null,
                INT_Ciudad__c = !ciudad.isEmpty()? ciudad[0].Id: null,
                Int_Pais__c = !pais.isEmpty()? pais[0].Id: null,
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Relaciones_Publicas').getRecordTypeId(),
                LeadSource = 'Evento'
            );
            insert ld;
            CampaignMember cm= New CampaignMember(
                CampaignId=!cmp.isEmpty()?cmp[0].Id:null,
                LeadId=ld.Id,
                Status='Asistió'
            );
            System.debug('CM '+cm);
            if(cm.CampaignId != null) insert cm;
            System.debug(ld.Id);
            return ld.Id;
        } catch (Exception e) {
            System.debug('Error '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}