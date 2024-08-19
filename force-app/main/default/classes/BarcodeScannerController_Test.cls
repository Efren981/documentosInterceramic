/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-29-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-29-2023   emeza@freewayconsulting.com   Initial Version
**/
@isTest
public with sharing class BarcodeScannerController_Test {
    @IsTest
    static void testSuccess(){
        Id leadId;
        Test.startTest();
            leadId = BarcodeScannerController.createLeads('Juan','Perez','Freeway','test@mail.com','5512345678','Chihuahua','Chihuahua');
        Test.stopTest();
        Assert.isNotNull(leadId);
    }
    @IsTest
    static void testError(){
        Id leadId;
        Test.startTest();
        try{
            BarcodeScannerController.createLeads('Juan','Perez','Freeway','test@mail.com','5512345678','Chihuahua','Chihuahua');
            leadId = BarcodeScannerController.createLeads('Juan','Perez','Freeway','test@mail.com','5512345678','Chihuahua','Chihuahua');
            Assert.isTrue(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.debug(e.getMessage());
            Assert.isTrue(e.getMessage().contains('DUPLICATES_DETECTED') || e.getMessage().contains('Script-thrown') , 'Exception message was wrong');
        }
            
        Test.stopTest();
        
    }
}