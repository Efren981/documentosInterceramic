trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            LeadTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isAfter){
            
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            LeadTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isAfter){
            
        }
    }
}