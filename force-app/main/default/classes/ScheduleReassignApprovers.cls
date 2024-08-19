/**
 * @description       : Schedule class in order to reassign approvers to quotes items not approved/rejected in 24 hrs after, recommend schedule once at half hour instead o'clock
 * @author            : esalas@freewayconsulting.com
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : esalas@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-09-2023   esalas@freewayconsulting.com   Initial Version
**/

public with sharing class ScheduleReassignApprovers implements System.Schedulable {
    public void execute(SchedulableContext SC) {
        BatchableReassignApprovers batchClass = new BatchableReassignApprovers();
        String jobId = Database.executeBatch(batchClass);
        System.debug('BATCH APEX JOB ID: ' + jobId);
    }  
}