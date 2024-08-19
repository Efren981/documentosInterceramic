/**
 * @description       : To testi schedule class in order to reassign approvers to quotes items not approved/rejected in 24 hrs after, recommend schedule once at half hour instead o'clock
 * @author            : esalas@freewayconsulting.com
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : esalas@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-09-2023   esalas@freewayconsulting.com   Initial Version
**/

@isTest
private with sharing class ScheduleReassignApproversTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createReassignConfig(24);
    }

    @isTest
    private static void scheduleTest() {
        String cronExp = '0 30 * * * ?';
        Test.startTest();
        String jobId = System.Schedule('Test Schedule', cronExp, new ScheduleReassignApprovers());
        Test.stopTest();
        System.assertEquals(false, String.isBlank(jobId), 'null JobId');
    }      
}