/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-11-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-31-2023   emeza@freewayconsulting.com   Initial Version
**/
@isTest (SeeAllData=false)
public with sharing class filePreviewAndDownloadController_Test {
    @TestSetup
    static void makeData(){
        Product2 product = TestDataFactory.createProduct(null, null, null, null);
        TestDataFactory.createContentVersion();
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        TestDataFactory.createDocumentLink(product.Id,document.Id);
    }
    @IsTest
    static void testgetRelatedFilesByRecordId(){
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Test.startTest();
        Map<ID, String> mapFieles = filePreviewAndDownloadController.getRelatedFilesByRecordId(product.Id);
        Test.stopTest();
        Assert.isNotNull(mapFieles);
        Assert.isNotNull(product);
    }
}