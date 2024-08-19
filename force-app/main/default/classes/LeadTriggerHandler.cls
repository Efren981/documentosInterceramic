public class LeadTriggerHandler {
    public static void beforeInsert(List<Lead> newList){
        getIdLealtad(newList);
    }
    public static void beforeUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        getUpdateIdLealtad(newMap, oldMap);
    }
    public static void afterInsert(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        
    }
    public static void afterUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        
    }
    
    public static void getIdLealtad(List<Lead> newList){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead iLead : newList){
            if(iLead.INT_Id_Interface__c != null){
                leadsToUpdate.add(iLead);
            }
        }        
        
        if (!leadsToUpdate.isEmpty()) {
            // Enqueue the Batch Apex job to process individual callouts for each account
            Database.executeBatch(new LeadIdLealtadCalloutBatch(leadsToUpdate), 1);
        }
    }
    
    public static void getUpdateIdLealtad(Map<Id, Lead> newMap, Map<Id, Lead> oldMap){
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead iLead : newMap.values()){
            if(iLead.INT_Id_Interface__c != null && iLead.INT_Id_Interface__c != oldMap.get(iLead.Id).INT_Id_Interface__c)
            {
                leadsToUpdate.add(iLead);
            }
        }        
        
        if (!leadsToUpdate.isEmpty()) {
            // Enqueue the Batch Apex job to process individual callouts for each account
            Database.executeBatch(new LeadIdLealtadCalloutBatch(leadsToUpdate), 1);
        }
    }
}