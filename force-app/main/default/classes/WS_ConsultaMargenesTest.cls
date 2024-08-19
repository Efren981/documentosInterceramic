@isTest
public class WS_ConsultaMargenesTest {

    @isTest
    static void testConsultarMargenes() {
        // Create test data for SBQQ__QuoteLine__c records
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        insert testQuote;
        
        Product2 testProduct = new Product2(
            ProductCode = 'A1',
            Name = 'Test Product',
            UnidadVenta__c = 'Pza',
            INT_TIPOCPQ__c = 'NO'
        );
        insert testProduct;
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Quantity__c = 10,
            SBQQ__Product__c = testProduct.Id
            /* set other required fields */
        );
        insert testQuoteLine;

        // Call the method being tested
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String result = WS_ConsultaMargenes.consultarMargenes(testQuote.Id);
        Test.StopTest();
        // Assert the expected result based on your business logic
        System.assertEquals('OK', result);
    }
    
    @isTest
    static void testConsultarMargenesMB() {
        // Create test data for SBQQ__QuoteLine__c records
        
        Id idPB = Test.getStandardPricebookId();
        Pricebook2 objPB2 = new Pricebook2();
        objPB2.Name = 'TESTPBDos';
        objPB2.Lista_MB__c = true;
        insert objPB2;
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__PriceBook__c = objPB2.Id;
        insert testQuote;
        
        Product2 testProduct2 = new Product2(
            ProductCode = 'A21',
            Name = 'Test Product',
            UnidadVenta__c = 'Pza',
            INT_TIPOCPQ__c = 'MB'
        );
        insert testProduct2;
        
        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Quantity__c = 10,
            SBQQ__Product__c = testProduct2.Id
            /* set other required fields */
        );
        insert testQuoteLine2;

        // Call the method being tested
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String result = WS_ConsultaMargenes.consultarMargenes(testQuote.Id);
		Test.stopTest();
        // Assert the expected result based on your business logic
        System.assertEquals('OK', result);
    }
    
    @isTest
    static void TestCovertest(){
        Test.startTest();
        WS_ConsultaMargenes.coverTest();
		Test.stopTest();
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            
            // Set the response body with the provided JSON data
            response.setBody('{"PRODUCTOS": [{"ARTCLAVE": "A1","CANTIDAD": 10,"METROS": 40.32,"PRECIO_UNITARIO": 867.72,"TIPO_PRECIO": "NR","TIPO_PROMO": "NP","DESCUENTOS": [{"IMPORTE_BRUTO": 24296.16,"IMPORTE_NETO": 28183.55,"PORCENTAJE_DESCUENTO": 2,"PRECIO_DESCUENTO": 850.36,"DESCUENTO": 485.92,"IVA": 3809.64,"NETO_CON_DESCUENTO": 27619.87,"PRECIO_FRANQ_LISTA": 6026.74}],"GASTOS": [{"FLETE_TONELADA": 24296.16,"APOYO_FLETE": 28183.55,"COSTO_REPOSICION": 2,"FLETE": 850.36,"FLETE_APLICADO": 485.92,"COSTO_PUBLICIDAD": 3809.64,"COSTO_FLETE": 27619.87,"PORCENTAJE_APOYO_PLANTA": 6026.74,"APOYO_PLANTA": 8.67}],"MARGEN": [{"FLETE": 455.56,"BONIFICACION": 0,"PUBLICIDAD": 52.13,"FLETE_ENTREGA": 100.8,"APOYO_PLANTA": 242.96,"COSTO_REPOSICION": 17689.24,"PROYECTO": 23810.08,"MARGEN_FRANQUICIA_PORC": 24.13,"MARGEN_FRANQUICIA": 205.23}],"MARGEN_PLANTA": [{"COSTO_PLANTA": 44124,"MARGEN_FRANQUICIA": 205.23,"MARGEN_CONSOLIDADO": 387.39,"MARGEN_PLANTA": 182.16,"MARGEN_FRANQUICIA_PORC": 24.13,"MARGEN_CONSOLIDADO_PORC": 45.56,"MARGEN_PLANTA_PORC": 28.82,"IMPORTE_PROYECTO": 23810.08,"IMPORTE_COSTO_PLANTA": 12354.72,"UTILIDAD_FRANQUICIA": 5746.44,"UTILIDAD_CONSOLIDADA": 10846.92,"UTILIDAD_PLANTA": 5100.48}],"MATERIAL_INSTALACION": [{"TOTAL_ADHESIVO": 998.73,"TOTAL_BOQUILLO": 63.31,"MATERIAL_INSTALACION": [{"ARTCLAVE": "AB.ADHE.GRIS.20KG.FGRP","TIPO": "ADHESIVO","CANTIDAD": 52},{"ARTCLAVE": "AB.BOQU.CHAR.05KG.SIAR","TIPO": "BOQUILLA","CANTIDAD": 6}]}],"MARGEN_PORC": 22,"FLETE_OBRA": 31.22,"PRECIO_PROY_SIN_IVA": 5452.35,"DESCTO_PROY_PORC": 36.67,"TOTAL_PROYECTO": 545235.24,"TOTAL_IVA": 87237.64,"PRECIO_PROY_CON_IVA": 632472.88,"PRECIO_FRANQ_LISTA": 6026.74,"DESCTO_FRANQ_PORC": 20,"PRECIO_BASE": 4218.72,"ARANCEL_PESOS": 0,"FLETE_ELP": 2.89,"LAB_OBRA": 4252.83,"FIANZA": 0,"LAB_OBRA_CON_FIANZA": 4252.83,"TIPO_PRECIO": "MULT","REV": 0,"DROP": 0}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}