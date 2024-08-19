/**
 * @description       : 
 * @author            : Jesus Alvarez
 * @group             : 
 * @last modified on  : 12-28-2023
 * @last modified by  : Jesus Alvarez
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-28-2023   Jesus Alvarez   Initial Version
**/
@IsTest
public with sharing class BatchCleanFranquiciasTest {
    @IsTest
    public static void clean() {
        Franquicia__c fran = new Franquicia__c();
        fran.INT_NameCorto__c = 'NOMBRE';
        fran.INT_EmpNum__c = 12;
        fran.INT_UpdateFranquicia__c = true;
        insert fran;

        Franquicia__c fran2 = new Franquicia__c();
        fran2.INT_NameCorto__c = 'NOMBRE';
        fran2.INT_EmpNum__c = 12;
        fran2.INT_UpdateFranquicia__c = true;
        insert fran2;

        Test.startTest();
        String jsonString = '[{"EMPNUM":204,"NOMBRE":"NORTE AMBIENTE DE PRUEBAS","NOMBRECORTO":"NORTE","PAISCLAVE":"1","ENTFEDNUM":15,"MPONUM":126,"LOCALIDAD":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","COLNUM":2,"CP":"54080","CALLE":"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","NUMEXT":"XXXXXXXXXX","NUMINT":"XXXXXXXXXX","TELEFONO":"6144422900","RFC":"DIN971119GG6","SUBSIDIARIA":1,"REGION":"NORTE"}]';
        List<Object> dataList = (List<Object>) JSON.deserializeUntyped(jsonString);
        Database.executeBatch(new BatchCleanFranquicias(dataList), 1000);
        Test.stopTest();
    }
}