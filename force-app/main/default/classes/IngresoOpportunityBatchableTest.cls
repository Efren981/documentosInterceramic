/* Author: Briseidy Torres - btorres@freewayconsulting.com
 * Created Date: 21/12/2023
*/
@IsTest
public class IngresoOpportunityBatchableTest {
    
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Pais__c pais = TestDataFactory.createPais('1234');
        Estado__c estado = TestDataFactory.createEstado(10.0, '1', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado.INT_EntFedNum__c, pais.INT_PaisClave__c);
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
        Franquicia__c franquicia = TestDataFactory.createFranquicia(colonia, pais.INT_PaisClave__c, estado.INT_EntFedNum__c, ciudad.INT_MpoNum__c, 12);
        Sucursal__c sucursal = TestDataFactory.createSucursal(pais.INT_PaisClave__c, estado.INT_EntFedNum__c, franquicia.INT_EmpNum__c);
        Product2 product = TestDataFactory.createProduct('test product', null, null, null);
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opp', 'Acuerdo / Convenio', pais, ciudad, estado, colonia, franquicia, sucursal);
        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
    }
    
    @IsTest
    public static void IngresoOpportunityBatchable_Test(){
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1]; 
        string jsonInput = '{"Oportunidades":[{"ID_OPORTUNIDAD":"'+testOpportunity.Id+'","PRODUCTOS":[{"ARTCLAVE":"IN.QRTZ.IRON.931.1001.1","INGRESO_FACTURADO":5462.3072,"CANTIDAD_FACTURADA":23,"METROS_FACTURADOS":19.439999999999966,"MONEDA":"MXN","FACTURAS":[{"EJECUTIVO_VENTAS":"ERRAGONZALEZ","FECHA_TICKET_VENTA":"27-11-2023","TICKET_VENTA":"278VCCUCO20481","INGRESO":5462.3072,"CANTIDAD":17,"METROS":19.439999999999966,"EJERCICIO":2023,"MES":12,"PRECIO_VENTA":396.97},{"EJECUTIVO_VENTAS":"ERRAGONZALEZ","FECHA_TICKET_VENTA":"27-11-2023","TICKET_VENTA":"278VCCUCO20482","INGRESO":5462.3072,"CANTIDAD":19,"METROS":19.439999999999966,"EJERCICIO":2023,"MES":12,"PRECIO_VENTA":396.97},{"EJECUTIVO_VENTAS":"ERRAGONZALEZ","FECHA_TICKET_VENTA":"27-11-2023","TICKET_VENTA":"278VCCUCO20483","INGRESO":5462.3072,"CANTIDAD":20,"METROS":19.439999999999966,"EJERCICIO":2023,"MES":12,"PRECIO_VENTA":396.97}]},{"ARTCLAVE":"IN.QRTZ.IRON.931.1001.1","INGRESO_FACTURADO":5462.3072,"CANTIDAD_FACTURADA":24,"METROS_FACTURADOS":19.439999999999966,"MONEDA":"MXN","FACTURAS":[{"EJECUTIVO_VENTAS":"ERRAGONZALEZ","FECHA_TICKET_VENTA":"27-11-2023","TICKET_VENTA":"278VCCUCO20481","INGRESO":5462.3072,"CANTIDAD":25,"METROS":19.439999999999966,"EJERCICIO":2024,"MES":1,"PRECIO_VENTA":396.97},{"EJECUTIVO_VENTAS":"ERRAGONZALEZ","FECHA_TICKET_VENTA":"27-11-2023","TICKET_VENTA":"278VCCUCO20482","INGRESO":5462.3072,"CANTIDAD":24,"METROS":19.439999999999966,"EJERCICIO":2024,"MES":1,"PRECIO_VENTA":396.97}]},{"ARTCLAVE":"KL.VEKO.1189","INGRESO_FACTURADO":94650,"CANTIDAD_FACTURADA":50,"METROS_FACTURADOS":50,"MONEDA":"MXN","FACTURAS":[{"EJECUTIVO_VENTAS":"ASOPO","FECHA_TICKET_VENTA":"26-05-2024","TICKET_VENTA":"278VCCUCO90000","INGRESO":94650,"CANTIDAD":50,"METROS":50,"EJERCICIO":2024,"MES":5,"PRECIO_VENTA":1893}]}],"PERIODOS":[{"EJERCICIO":2023,"MES":12,"INGRESO":5462.3072},{"EJERCICIO":2024,"MES":1,"INGRESO":5462.3072}]}]}';
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
    	Database.executeBatch(new IngresoOpportunityBatchable(data));
    }
}