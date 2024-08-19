/* Author: Briseidy Torres - btorres@freewayconsulting.com
 * Last modified: 12/12/2023 
 * Trigger in Quote (CPQ) object
*/
trigger INT_FWY_QuoteTrigger on SBQQ__Quote__c (before insert,before update) {
    INT_FWY_QuoteTriggerHandler.handleTrigger(Trigger.New);   
}