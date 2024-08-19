/**
 * @description       : 
 * @author            : Jesus Alvarez
 * @group             : 
 * @last modified on  : 12-28-2023
 * @last modified by  : Jesus Alvarez
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-28-2023   Jesus Alvarez   Initial Version
**/
public class BatchCleanFranquicias implements Database.Batchable<sObject>{
    private List<Object> dataFranquicias;

    public BatchCleanFranquicias(List<Object> data){
        this.dataFranquicias = data;
        System.debug('dataFranquicias:: ' + dataFranquicias);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, INT_UpdateFranquicia__c FROM Franquicia__c WHERE INT_UpdateFranquicia__c = TRUE]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Franquicia__c> listFranquicias = new List<Franquicia__c>();
        for (Franquicia__c clean : [SELECT Id, INT_UpdateFranquicia__c FROM Franquicia__c WHERE Id IN: scope]) {
            Franquicia__c franquicia = new Franquicia__c();
            franquicia.Id = clean.Id;
            franquicia.INT_UpdateFranquicia__c = false;
            listFranquicias.add(franquicia);
            System.debug('listFranquicias ' + listFranquicias);
        }
        Database.update(listFranquicias, false);
    }

    public void finish(Database.BatchableContext BC) {
        System.Debug('FINISHED JOB CLEAN');
        Database.executeBatch(new BatchGetFranquicias(dataFranquicias),1000);
    }
}