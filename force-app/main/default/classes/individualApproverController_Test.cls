/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-11-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-11-2023   emeza@freewayconsulting.com   Initial Version
**/
@isTest
public with sharing class individualApproverController_Test {
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='Administrador del sistema']; 
        User initialUser = TestDataFactory.createUser(p, 'username1@mail.com.test', 'username1@mail.com');
        User reassignedUser = TestDataFactory.createUser(p, 'username2@mail.com.test', 'username2@mail.com');
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
        Product2 product = TestDataFactory.createProduct(null, null, null, null);
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        SBQQ__QuoteLine__c lineItem = TestDataFactory.createQuoteLineItem(quote, product, 10, 10, grupo);

        grupo.Fecha_Ultima_Aprobacion__c = DateTime.now().addHours(-24);
        update grupo;
        initialUser.DelegatedApproverId = reassignedUser.Id;
        update initialUser;
        lineItem.Aprobador_Nivel_1__c = initialUser.Id;
        lineItem.Aprobador_Nivel_2__c = initialUser.Id;
        lineItem.Aprobador_Nivel_3__c = initialUser.Id;
        update lineItem;
    }
    @IsTest
    static void sendApproval(){
        SBQQ__Quote__c  quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Grupo_de_productos_a_aprobar__c groupApprove = [SELECT Id FROM Grupo_de_productos_a_aprobar__c LIMIT 1];
        Test.startTest();
        List< SBQQ__QuoteLine__c > lstQuoteLineItems = individualApproverController.fetchQuoteLineItems(quote.Id,groupApprove.Id);
        for (SBQQ__QuoteLine__c qli : lstQuoteLineItems) {
            qli.Estado_Aprobacion_Nivel_1__c = 'Approved';
            qli.Aprobador_Nivel_1__c = UserInfo.getUserId();
        }
        individualApproverController.updateQLI(lstQuoteLineItems, 'Test COmments');
        Test.stopTest();
        
    }
    @IsTest
    static void sendApprovalSecondLevel(){
        SBQQ__Quote__c  quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Grupo_de_productos_a_aprobar__c groupApprove = [SELECT Id FROM Grupo_de_productos_a_aprobar__c LIMIT 1];
        Test.startTest();
        List< SBQQ__QuoteLine__c > lstQuoteLineItems = individualApproverController.fetchQuoteLineItems(quote.Id,groupApprove.Id);
        for (SBQQ__QuoteLine__c qli : lstQuoteLineItems) {
            qli.Estado_Aprobacion_Nivel_1__c = 'Approved';
            qli.Aprobador_Nivel_1__c = UserInfo.getUserId();
            qli.Estado_Aprobacion_Nivel_2__c = 'Approved';
            qli.Aprobador_Nivel_2__c = UserInfo.getUserId();
        }
        individualApproverController.updateQLI(lstQuoteLineItems, 'Test COmments');
        Test.stopTest();
        
    }
    @IsTest
    static void sendApprovalThirdLevel(){
        SBQQ__Quote__c  quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Grupo_de_productos_a_aprobar__c groupApprove = [SELECT Id FROM Grupo_de_productos_a_aprobar__c LIMIT 1];
        Test.startTest();
        List< SBQQ__QuoteLine__c > lstQuoteLineItems = individualApproverController.fetchQuoteLineItems(quote.Id,groupApprove.Id);
        for (SBQQ__QuoteLine__c qli : lstQuoteLineItems) {
            qli.Estado_Aprobacion_Nivel_1__c = 'Approved';
            qli.Aprobador_Nivel_1__c = UserInfo.getUserId();
            qli.Estado_Aprobacion_Nivel_2__c = 'Approved';
            qli.Aprobador_Nivel_2__c = UserInfo.getUserId();
            qli.Estado_Aprobacion_Nivel_3__c = 'Approved';
            qli.Aprobador_Nivel_3__c = UserInfo.getUserId();
        }
        individualApproverController.updateQLI(lstQuoteLineItems, 'Test COmments');
        Test.stopTest();
        
    }
    @IsTest
    static void sendRejected(){
        SBQQ__Quote__c  quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Grupo_de_productos_a_aprobar__c groupApprove = [SELECT Id FROM Grupo_de_productos_a_aprobar__c LIMIT 1];
        Test.startTest();
        List< SBQQ__QuoteLine__c > lstQuoteLineItems = individualApproverController.fetchQuoteLineItems(quote.Id,groupApprove.Id);
        for (SBQQ__QuoteLine__c qli : lstQuoteLineItems) {
            qli.Estado_Aprobacion_Nivel_1__c = 'Rejected';
            qli.Aprobador_Nivel_1__c = UserInfo.getUserId();
        }
        individualApproverController.updateQLI(lstQuoteLineItems, 'Test COmments');
        Test.stopTest();
        
    }
    @IsTest
    static void sendRejectedDiscontinued(){
        SBQQ__Quote__c  quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Grupo_de_productos_a_aprobar__c groupApprove = [SELECT Id,Descontinuado__c FROM Grupo_de_productos_a_aprobar__c LIMIT 1];
        groupApprove.Descontinuado__c = true;
        update groupApprove;
        Test.startTest();
        List< SBQQ__QuoteLine__c > lstQuoteLineItems = individualApproverController.fetchQuoteLineItems(quote.Id,groupApprove.Id);
        for (SBQQ__QuoteLine__c qli : lstQuoteLineItems) {
            qli.Estado_Aprobacion_Nivel_1__c = 'Rejected';
            qli.Aprobador_Nivel_1__c = UserInfo.getUserId();
        }
        individualApproverController.updateQLI(lstQuoteLineItems, 'Test COmments');
        Test.stopTest();
        
    }
}