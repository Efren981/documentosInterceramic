@isTest
public class PricebookRestResourceTest {
    @isTest
    static void testCreateListaPrecios() {
        Product2 iProducto = new Product2();
        iProducto.Name = 'Test Producto';
        iProducto.INT_External_Id__c = 'MB-BT6305-NA';
        iProducto.IsActive = true;
        insert iProducto;
        
        // Create test data for the request
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, Object> listaPreciosMap = new Map<String, Object>();
        listaPreciosMap.put('nombre', 'NORMAL CON IVA');
        listaPreciosMap.put('activo', true);
        listaPreciosMap.put('descripcion', 'Lista de precios normal con IVA 16%');
        listaPreciosMap.put('moneda', 'MXN');
        listaPreciosMap.put('id', '01s7800000050B1AAI');

        List<Object> productosList = new List<Object>();
        Map<String, Object> productoMap = new Map<String, Object>();
        productoMap.put('artclave', 'MB-BT6305-NA');
        productoMap.put('artnum', 312869);
        productoMap.put('precio', 11990);
        productoMap.put('activo', true);
        productosList.add(productoMap);
        
        listaPreciosMap.put('productos', productosList);
        requestMap.put('listaprecios', listaPreciosMap);
        String jsonRequest = JSON.serialize(requestMap);

        // Set up the test context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        RestContext.response = res;

        // Create test Pricebook2 records
        Pricebook2 testPricebook = new Pricebook2(
            Name = 'NORMAL CON IVA',
            IsActive = true,
            Description = 'Lista de precios normal con IVA 16%',
            INT_CurrencyIsoCode__c = 'MXN'
        );
        insert testPricebook;

        // Run the REST resource method
        Test.startTest();
        PricebookRestResource.createListaPrecios();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateListaPreciosCatchBlock() {
        // Create a mock request
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf('{"listaprecios": {"nombre": "TestPricebook"}}');

        // Set up the RestContext for the test
        RestContext.request = mockRequest;
        RestContext.response = new RestResponse();
        
        try {
            Test.startTest();
            PricebookRestResource.createListaPrecios();
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('ExpectedErrorMessageSubstring'));
        }
    }
    
    @isTest
    static void testCreateListaPrecios2() {
        Product2 iProducto = new Product2();
        iProducto.Name = 'Test Producto';
        iProducto.INT_External_Id__c = 'MB-BT6305-NA';
        iProducto.IsActive = true;
        insert iProducto;
        
        PricebookEntry iPrice = new PricebookEntry();
        iPrice.Product2Id = iProducto.Id;
        iPrice.Pricebook2Id = Test.getStandardPricebookId();
        iPrice.UnitPrice = 11;
        iPrice.IsActive = false;
        insert iPrice;
        
        // Create test data for the request
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, Object> listaPreciosMap = new Map<String, Object>();
        listaPreciosMap.put('nombre', 'NORMAL CON IVA');
        listaPreciosMap.put('activo', true);
        listaPreciosMap.put('descripcion', 'Lista de precios normal con IVA 16%');
        listaPreciosMap.put('moneda', 'MXN');
        listaPreciosMap.put('id', '01s7800000050B1AAI');

        List<Object> productosList = new List<Object>();
        Map<String, Object> productoMap = new Map<String, Object>();
        productoMap.put('artclave', 'MB-BT6305-NA');
        productoMap.put('artnum', 312869);
        productoMap.put('precio', 11990);
        productoMap.put('activo', true);
        productosList.add(productoMap);
        
        listaPreciosMap.put('productos', productosList);
        requestMap.put('listaprecios', listaPreciosMap);
        String jsonRequest = JSON.serialize(requestMap);

        // Set up the test context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        RestContext.response = res;

        // Create test Pricebook2 records
        Pricebook2 testPricebook = new Pricebook2(
            Name = 'NORMAL CON IVA',
            IsActive = true,
            Description = 'Lista de precios normal con IVA 16%',
            INT_CurrencyIsoCode__c = 'MXN'
        );
        insert testPricebook;

        // Run the REST resource method
        Test.startTest();
        PricebookRestResource.createListaPrecios();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateListaPrecios3() {
        Product2 iProducto = new Product2();
        iProducto.Name = 'Test Producto';
        iProducto.INT_External_Id__c = 'MB-BT6305-NA';
        iProducto.IsActive = true;
        insert iProducto;
        
        PricebookEntry iPrice = new PricebookEntry();
        iPrice.Product2Id = iProducto.Id;
        iPrice.Pricebook2Id = Test.getStandardPricebookId();
        iPrice.UnitPrice = 11;
        iPrice.IsActive = true;
        insert iPrice;
        
        Pricebook2 testPricebook = new Pricebook2(
            Name = 'NORMAL CON IVA',
            IsActive = true,
            Description = 'Lista de precios normal con IVA 16%',
            INT_CurrencyIsoCode__c = 'MXN'
        );
        insert testPricebook;
        
        PricebookEntry iPrice2 = new PricebookEntry();
        iPrice2.Product2Id = iProducto.Id;
        iPrice2.Pricebook2Id = testPricebook.Id;
        iPrice2.UnitPrice = 11;
        iPrice2.IsActive = true;
        insert iPrice2;
        
        // Create test data for the request
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, Object> listaPreciosMap = new Map<String, Object>();
        listaPreciosMap.put('nombre', 'NORMAL CON IVA');
        listaPreciosMap.put('activo', true);
        listaPreciosMap.put('descripcion', 'Lista de precios normal con IVA 16%');
        listaPreciosMap.put('moneda', 'MXN');
        listaPreciosMap.put('id', String.valueOf(testPricebook.Id));

        List<Object> productosList = new List<Object>();
        Map<String, Object> productoMap = new Map<String, Object>();
        productoMap.put('artclave', 'MB-BT6305-NA');
        productoMap.put('artnum', 312869);
        productoMap.put('precio', 11990);
        productoMap.put('activo', true);
        productosList.add(productoMap);
        
        listaPreciosMap.put('productos', productosList);
        requestMap.put('listaprecios', listaPreciosMap);
        String jsonRequest = JSON.serialize(requestMap);

        // Set up the test context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonRequest);
        RestContext.request = req;
        RestContext.response = res;

        // Run the REST resource method
        Test.startTest();
        PricebookRestResource.createListaPrecios();
        Test.stopTest();
    }
}