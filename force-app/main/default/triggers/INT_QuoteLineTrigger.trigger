trigger INT_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, before delete) {
     INT_QuoteLineTriggerHandler.handleTrigger(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.operationType);

}