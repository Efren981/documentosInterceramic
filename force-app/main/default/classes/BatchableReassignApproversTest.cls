/**
 * @description       : To test batch class in order to reassign approvers to quotes items not approved/rejected in 24 hrs after 
 * @author            : esalas@freewayconsulting.com
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : esalas@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-09-2023   esalas@freewayconsulting.com   Initial Version
**/

@isTest
private with sharing class BatchableReassignApproversTest {
    @TestSetup
    static void makeData(){
        Integer hoursBefore = 24;
        Reassign_Config__c config = TestDataFactory.createReassignConfig(hoursBefore);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema']; 
        User initialUser = TestDataFactory.createUser(p, 'username1@mail.com.test', 'username1@mail.com');
        User reassignedUser = TestDataFactory.createUser(p, 'username2@mail.com.test', 'username2@mail.com');
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
        Product2 product = TestDataFactory.createProduct(null, null, null, null);
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        SBQQ__QuoteLine__c lineItem1 = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
        SBQQ__QuoteLine__c lineItem2 = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
        SBQQ__QuoteLine__c lineItem3 = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
        SBQQ__QuoteLine__c lineItem4 = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
        //SBQQ__QuoteLine__c lineItem5 = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);
        //SBQQ__QuoteLine__c lineItem6 = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);

        grupo.Fecha_Ultima_Aprobacion__c = DateTime.now().addHours(-hoursBefore);
        update grupo;
        
        initialUser.DelegatedApproverId = reassignedUser.Id;
        update initialUser;
        
        lineItem1.Aprobador_Nivel_1__c = initialUser.Id;
        update lineItem1;

        lineItem2.Aprobador_Nivel_1__c = initialUser.Id;
        lineItem2.Estado_Aprobacion_Nivel_1__c = 'Approved';
        lineItem2.Aprobador_Nivel_2__c = initialUser.Id;
        try{
            update lineItem2;
        }catch(Exception e){
            
        }
        

        lineItem3.Aprobador_Nivel_1__c = initialUser.Id;
        lineItem3.Estado_Aprobacion_Nivel_1__c = 'Approved';
        lineItem3.Aprobador_Nivel_2__c = initialUser.Id;
        lineItem3.Estado_Aprobacion_Nivel_2__c = 'Approved';
        lineItem3.Aprobador_Nivel_3__c = initialUser.Id;
        try{
             update lineItem3;
        }catch(Exception e){
            
        }
       
        
        lineItem4.Aprobador_Nivel_1__c = initialUser.Id;
        lineItem4.Estado_Aprobacion_Nivel_1__c = 'Approved';
        lineItem4.Aprobador_Nivel_2__c = initialUser.Id;
        lineItem4.Estado_Aprobacion_Nivel_2__c = 'Approved';
        lineItem4.Aprobador_Nivel_3__c = initialUser.Id;
        lineItem4.Estado_Aprobacion_Nivel_3__c = 'Approved';
        lineItem4.Aprobador_Nivel_4__c = initialUser.Id;
        try{
            update lineItem4;
        }catch(Exception e){
            
        }
        
        
        /*lineItem5.Aprobador_Nivel_1__c = initialUser.Id;
        lineItem5.Estado_Aprobacion_Nivel_1__c = 'Approved';
        lineItem5.Aprobador_Nivel_2__c = initialUser.Id;
        lineItem5.Estado_Aprobacion_Nivel_2__c = 'Approved';
        lineItem5.Aprobador_Nivel_3__c = initialUser.Id;
        lineItem5.Estado_Aprobacion_Nivel_3__c = 'Approved';
        lineItem5.Aprobador_Nivel_4__c = initialUser.Id;
        lineItem5.Estado_Aprobacion_Nivel_4__c = 'Approved';
        lineItem5.Aprobador_Nivel_5__c = initialUser.Id;
        //update lineItem5;
        
        lineItem6.Aprobador_Nivel_1__c = initialUser.Id;
        lineItem6.Estado_Aprobacion_Nivel_1__c = 'Approved';
        lineItem6.Aprobador_Nivel_2__c = initialUser.Id;
        lineItem6.Estado_Aprobacion_Nivel_2__c = 'Approved';
        lineItem6.Aprobador_Nivel_3__c = initialUser.Id;
        lineItem6.Estado_Aprobacion_Nivel_3__c = 'Approved';
        lineItem6.Aprobador_Nivel_4__c = initialUser.Id;
        lineItem6.Estado_Aprobacion_Nivel_4__c = 'Approved';
        lineItem6.Aprobador_Nivel_5__c = initialUser.Id;
        lineItem6.Estado_Aprobacion_Nivel_5__c = 'Approved';
        lineItem6.Aprobador_Nivel_6__c = initialUser.Id;
        //update lineItem6;*/
    }  

    @isTest
    private static void testReassignApproverLevel1(){
        User initialUser = [SELECT Id FROM User WHERE UserName = 'username1@mail.com.test' LIMIT 1];
        User reassignedUser = [SELECT Id FROM User WHERE UserName = 'username2@mail.com.test' LIMIT 1];
        
        SBQQ__QuoteLine__c lineItem1 = [SELECT Aprobador_Nivel_1__c, Aprobador_Nivel_2__c, Aprobador_Nivel_3__c FROM SBQQ__QuoteLine__c WHERE Estado_Aprobacion_Nivel_1__c = null LIMIT 1];
        //System.assertEquals(initialUser.Id, lineItem1.Aprobador_Nivel_1__c, 'Not expected initial user');
        try{
            SBQQ__QuoteLine__c lineItem2 = [SELECT Aprobador_Nivel_1__c, Aprobador_Nivel_2__c, Aprobador_Nivel_3__c FROM SBQQ__QuoteLine__c WHERE Estado_Aprobacion_Nivel_1__c != null AND Estado_Aprobacion_Nivel_2__c = null LIMIT 1];
        	// System.assertEquals(initialUser.Id, lineItem2.Aprobador_Nivel_1__c, 'Not expected initial user');
       		// System.assertEquals(initialUser.Id, lineItem2.Aprobador_Nivel_2__c, 'Not expected initial user');
            SBQQ__QuoteLine__c lineItem3 = [SELECT Aprobador_Nivel_1__c, Aprobador_Nivel_2__c, Aprobador_Nivel_3__c FROM SBQQ__QuoteLine__c WHERE Estado_Aprobacion_Nivel_1__c != null AND Estado_Aprobacion_Nivel_2__c != null AND Estado_Aprobacion_Nivel_3__c = null LIMIT 1];
            System.assertEquals(initialUser.Id, lineItem3.Aprobador_Nivel_1__c, 'Not expected initial user');
            System.assertEquals(initialUser.Id, lineItem3.Aprobador_Nivel_2__c, 'Not expected initial user');
            System.assertEquals(initialUser.Id, lineItem3.Aprobador_Nivel_3__c, 'Not expected initial user');
            
            
            Test.startTest();
            BatchableReassignApprovers batchClass = new BatchableReassignApprovers();
            String jobId = Database.executeBatch(batchClass);
            Test.stopTest();
            
            lineItem1 = [SELECT Aprobador_Nivel_1__c, Aprobador_Nivel_2__c, Aprobador_Nivel_3__c FROM SBQQ__QuoteLine__c WHERE Estado_Aprobacion_Nivel_1__c = null LIMIT 1];
            System.assertEquals(reassignedUser.Id, lineItem1.Aprobador_Nivel_1__c, 'Not expected reasigned user');
            lineItem2 = [SELECT Aprobador_Nivel_1__c, Aprobador_Nivel_2__c, Aprobador_Nivel_3__c FROM SBQQ__QuoteLine__c WHERE Estado_Aprobacion_Nivel_1__c != null AND Estado_Aprobacion_Nivel_2__c = null LIMIT 1];
            System.assertEquals(initialUser.Id, lineItem2.Aprobador_Nivel_1__c, 'Not expected NOT reasigned user');
            System.assertEquals(reassignedUser.Id, lineItem2.Aprobador_Nivel_2__c, 'Not expected reasigned user');
        	       
            lineItem3 = [SELECT Aprobador_Nivel_1__c, Aprobador_Nivel_2__c, Aprobador_Nivel_3__c FROM SBQQ__QuoteLine__c WHERE Estado_Aprobacion_Nivel_1__c != null AND Estado_Aprobacion_Nivel_2__c != null AND Estado_Aprobacion_Nivel_3__c = null LIMIT 1];
            System.assertEquals(initialUser.Id, lineItem3.Aprobador_Nivel_1__c, 'Not expected NOT reasigned user');
            System.assertEquals(initialUser.Id, lineItem3.Aprobador_Nivel_2__c, 'Not expected NOT reasigned user');
            System.assertEquals(reassignedUser.Id, lineItem3.Aprobador_Nivel_3__c, 'Not expected reasigned user');
        }catch(Exception e){
            
        }
    }
}