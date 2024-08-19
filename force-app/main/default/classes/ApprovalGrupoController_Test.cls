/**FREEWAY
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Clase test del controlador ApprovalGrupoController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Abraham Gudiño   <agudino@freewayconsulting.com>
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        10-09-2023
* @modified       
* @systemLayer    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            xxxxxxxxx@xxxxx.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public with sharing class ApprovalGrupoController_Test {
    
    @testSetup
    static void createDate(){
        //TestDataFactory.createBaseDataApprobalProccess();
    }
    
    @isTest public static void executeApprovalGroupProccessWihtoutQuote(){
        Test.startTest();
        ApprovalGrupoHelper.executeApprovalGroupProccess(null, new List<SBQQ__QuoteLine__c>(), false);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowFailUno(){
        TestDataFactory.createBaseDataApprobalProccess();
        SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
        System.debug('objQ:' + objQ);
        
        Test.startTest();
        ApprovalGrupoController.executeApprovalFlow(objQ.Id);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowFailDos(){
        Test.startTest();
        ApprovalGrupoController.executeApprovalFlow(null);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowFailTresDos(){
        TestDataFactory.createBaseDataApprobalProccess();
        List<SBQQ__QuoteLine__c> lstUp = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c obj : [SELECT Id FROM SBQQ__QuoteLine__c]){
            SBQQ__QuoteLine__c updateObj = new SBQQ__QuoteLine__c();
            updateObj.Id = obj.Id;
            updateObj.INT_Margen_color__c = 'VERDE';
            lstUp.add(updateObj);
        }
        System.debug('lstUp:' + lstUp);
        update lstUp;
        
        SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
        System.debug('objQ:' + objQ);
        
        List<Product2> lstP = new List<Product2>();
        
        Product2 p10 = new Product2();
        p10.Name = 'testProductDiez';
        p10.ProductCode = 'CU.COSC.SDBR.300M.SILI10';
        p10.CurrencyIsoCode = 'MXN';
        p10.INT_Clasificacion__c = 'PREMIUM';
        p10.TipoProducto__c = 'MATERIAL DE INSTALACION';
        p10.INT_TIPOCPQ__c = 'MB';
        p10.IsActive = true;
        insert p10;
        
        SBQQ__QuoteLine__c objQL1 = new SBQQ__QuoteLine__c();
        objQL1.SBQQ__Quote__c = objQ.Id;
        objQL1.SBQQ__Product__c = p10.Id;
        objQL1.SBQQ__Number__c = 10;
        objQL1.SBQQ__Quantity__c = 50;
        objQL1.SBQQ__Discount__c = 50.0;
        objQL1.SBQQ__ProratedListPrice__c = 3000;
        objQL1.INT_Margen_color__c = 'VERDE';
        insert objQL1;
        
        Test.startTest();
        //List<SBQQ__QuoteLine__c> lstQLI = [SELECT id,SBQQ__Discount__c,Tipo_producto__c, 	Clasificacion__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, Confirmar_Aprobacion_Descontinuado__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Estado_Aprobacion_Nivel_1__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : objQ.Id AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)];
        //ApprovalGrupoHelper.executeApprovalGroupProccess(objQ.Id, lstQLI, false);
        ApprovalGrupoController.executeApprovalFlow(objQ.Id);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowFailTres(){
        TestDataFactory.createBaseDataApprobalProccess();
        List<SBQQ__QuoteLine__c> lstUp = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c obj : [SELECT Id FROM SBQQ__QuoteLine__c]){
            SBQQ__QuoteLine__c updateObj = new SBQQ__QuoteLine__c();
            updateObj.Id = obj.Id;
            updateObj.INT_Margen_color__c = 'VERDE';
            lstUp.add(updateObj);
        }
        System.debug('lstUp:' + lstUp);
        update lstUp;
        
        SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
        System.debug('objQ:' + objQ);
        
        List<Product2> lstP = new List<Product2>();
        
        Product2 p10 = new Product2();
        p10.Name = 'testProductDiez';
        p10.ProductCode = 'CU.COSC.SDBR.300M.SILI10';
        p10.CurrencyIsoCode = 'MXN';
        p10.INT_Clasificacion__c = 'PREMIUM';
        p10.TipoProducto__c = 'MATERIAL DE INSTALACION';
        p10.INT_TIPOCPQ__c = 'MB';
        p10.IsActive = true;
        insert p10;
        
        SBQQ__QuoteLine__c objQL1 = new SBQQ__QuoteLine__c();
        objQL1.SBQQ__Quote__c = objQ.Id;
        objQL1.SBQQ__Product__c = p10.Id;
        objQL1.SBQQ__Number__c = 10;
        objQL1.SBQQ__Quantity__c = 50;
        objQL1.SBQQ__Discount__c = 50.0;
        objQL1.SBQQ__ProratedListPrice__c = 3000;
        objQL1.INT_Margen_color__c = 'VERDE';
        insert objQL1;
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> lstQLI = [SELECT id,SBQQ__Discount__c,Tipo_producto__c, 	Clasificacion__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, Confirmar_Aprobacion_Descontinuado__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Estado_Aprobacion_Nivel_1__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : objQ.Id AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)];
        ApprovalGrupoHelper.executeApprovalGroupProccess(objQ.Id, lstQLI, false);
        //ApprovalGrupoController.executeApprovalFlow(objQ.Id);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowFailCuatro(){
        TestDataFactory.createBaseDataApprobalProccess();
        List<SBQQ__QuoteLine__c> lstUp = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c obj : [SELECT Id FROM SBQQ__QuoteLine__c]){
            SBQQ__QuoteLine__c updateObj = new SBQQ__QuoteLine__c();
            updateObj.Id = obj.Id;
            updateObj.INT_Margen_color__c = 'VERDE';
            updateObj.SBQQ__Quantity__c = 1;
            updateObj.SBQQ__Discount__c = 13.0; 
            lstUp.add(updateObj);
        }
        System.debug('lstUp:' + lstUp);
        update lstUp;
        
        SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
        System.debug('objQ:' + objQ);
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> lstQLI = [SELECT id,SBQQ__Discount__c,Tipo_producto__c, 	Clasificacion__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, Confirmar_Aprobacion_Descontinuado__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Estado_Aprobacion_Nivel_1__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : objQ.Id AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)];
        ApprovalGrupoHelper.executeApprovalGroupProccess(objQ.Id, lstQLI, false);
        //ApprovalGrupoController.executeApprovalFlow(objQ.Id);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowSuccessEEF(){
        User us = [SELECT Id, UserName, Profile.Name FROM User WHERE Profile.Name = 'Ejecutivo Especificaciones Franquicia' Limit 1];
        System.debug('executeApprovalFlowSuccessEEF:us: ' + us);
        System.debug('executeApprovalFlowSuccessEEF:us: ' + us.Profile.Name);
        
        System.runAs(us){
            TestDataFactory.createBaseDataApprobalProccess();
            List<SBQQ__QuoteLine__c> lstUp = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c obj : [SELECT Id FROM SBQQ__QuoteLine__c]){
                SBQQ__QuoteLine__c updateObj = new SBQQ__QuoteLine__c();
                updateObj.Id = obj.Id;
                updateObj.INT_Margen_color__c = 'VERDE';
                lstUp.add(updateObj);
            }
            System.debug('lstUp:' + lstUp);
            update lstUp;
        }
        
        
        SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
        System.debug('objQ:' + objQ);
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> lstQLI = [SELECT id,SBQQ__Discount__c,Tipo_producto__c, 	Clasificacion__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, Confirmar_Aprobacion_Descontinuado__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Estado_Aprobacion_Nivel_1__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : objQ.Id AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)];
        ApprovalGrupoHelper.executeApprovalGroupProccess(objQ.Id, lstQLI, false);
        //ApprovalGrupoController.executeApprovalFlow(objQ.Id);
        Test.stopTest();
    }
    
    @isTest public static void executeApprovalFlowSuccessEEFChildOpp(){
        User us = [SELECT Id, UserName, Profile.Name FROM User WHERE Profile.Name = 'Ejecutivo Especificaciones Franquicia' Limit 1];
        System.debug('executeApprovalFlowSuccessEEF:us: ' + us);
        System.debug('executeApprovalFlowSuccessEEF:us: ' + us.Profile.Name);
        
        System.runAs(us){
            TestDataFactory.createBaseDataApprobalProccess();
            List<SBQQ__QuoteLine__c> lstUp = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c obj : [SELECT Id FROM SBQQ__QuoteLine__c]){
                SBQQ__QuoteLine__c updateObj = new SBQQ__QuoteLine__c();
                updateObj.Id = obj.Id;
                updateObj.INT_Margen_color__c = 'VERDE';
                lstUp.add(updateObj);
            }
            System.debug('lstUp:' + lstUp);
            update lstUp;
            
            
        }
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, Oportunidad_Relacionada__c FROM Opportunity LIMIT 1];
        
        Opportunity newOpp = new Opportunity();
        newOpp.Name = 'Prueba niveles aprobacion Principal';
        newOpp.StageName = 'Propuesta económica';
        newOpp.AccountId = acc.Id;
        newOpp.CloseDate =  Date.TODAY().addDays(5);
        
        insert newOpp;
        
        opp.Oportunidad_Relacionada__c = newOpp.Id;
        update opp;
        
        SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
        System.debug('objQ:' + objQ);
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> lstQLI = [SELECT id,SBQQ__Discount__c,Tipo_producto__c, 	Clasificacion__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, Confirmar_Aprobacion_Descontinuado__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Estado_Aprobacion_Nivel_1__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : objQ.Id AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)];
        ApprovalGrupoHelper.executeApprovalGroupProccess(objQ.Id, lstQLI, false);
        //ApprovalGrupoController.executeApprovalFlow(objQ.Id);
        Test.stopTest();
    }
    
    /*@isTest public static void executeApprovalFlowSuccessEE(){
User us = [SELECT Id, UserName, Profile.Name FROM User WHERE Profile.Name = 'Ejecutivo Especificaciones' Limit 1];
System.debug('executeApprovalFlowSuccessEE:us: ' + us);
System.debug('executeApprovalFlowSuccessEE:us: ' + us.Profile.Name);

System.runAs(us){
TestDataFactory.createBaseDataApprobalProccess();
List<SBQQ__QuoteLine__c> lstUp = new List<SBQQ__QuoteLine__c>();
for(SBQQ__QuoteLine__c obj : [SELECT Id FROM SBQQ__QuoteLine__c]){
SBQQ__QuoteLine__c updateObj = new SBQQ__QuoteLine__c();
updateObj.Id = obj.Id;
updateObj.INT_Margen_color__c = 'VERDE';
lstUp.add(updateObj);
}
System.debug('lstUp:' + lstUp);
update lstUp;
}


SBQQ__Quote__c objQ = [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 1];
System.debug('objQ:' + objQ);

Test.startTest();
ApprovalGrupoController.executeApprovalFlow(objQ.Id);
Test.stopTest();
}*/
    
}