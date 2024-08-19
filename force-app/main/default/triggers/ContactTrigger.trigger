trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    if(Trigger.isInsert){
        if(Trigger.isBefore){
           ContactTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isAfter){
            
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            ContactTriggerHandler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isAfter){
            
        }
    }
}