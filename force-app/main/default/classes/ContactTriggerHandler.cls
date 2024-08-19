public class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> newList){
        getIdLealtad(newList);
    }
    public static void beforeUpdate(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        getUpdateIdLealtad(newMap, oldMap);
    }
    public static void afterInsert(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        
    }
    public static void afterUpdate(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        
    }
    
    public static void getIdLealtad(List<Contact> newList){
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact iContact : newList){
            if(iContact.INT_Id_Interface__c != null){
                contactsToUpdate.add(iContact);
            }
        }        
        
        if (!contactsToUpdate.isEmpty()) {
            // Enqueue the Batch Apex job to process individual callouts for each account
            Database.executeBatch(new ContactIdLealtadCalloutBatch(contactsToUpdate), 1);
        }
    }
    
    public static void getUpdateIdLealtad(Map<Id, Contact> newMap, Map<Id, Contact> oldMap){
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact iContact : newMap.values()){
            if(iContact.INT_Id_Interface__c != null && iContact.INT_Id_Interface__c != oldMap.get(iContact.Id).INT_Id_Interface__c)
            {
                contactsToUpdate.add(iContact);
            }
        }        
        
        if (!contactsToUpdate.isEmpty()) {
            // Enqueue the Batch Apex job to process individual callouts for each account
            Database.executeBatch(new ContactIdLealtadCalloutBatch(contactsToUpdate), 1);
        }
    }
}