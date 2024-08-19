@isTest
private class OrderCommerceRestResourceTest {
    @TestSetup
    static void makeData(){
            Product2 product = TestDataFactory.createProduct('Test Product', 'Pza', 'PS.3WOD.TAUP.1066.1001.1');  
            PricebookEntry entry = TestDataFactory.createStandardEntry(product, 100);
            Account acc = TestDataFactory.createAccount();
            Lead iLead = TestDataFactory.createLead('First Name Initial', 'Last Name Initial', 'testInitial@test.com', null);
    }

    @isTest
    static void testCreateOrders() {
        // Create a mock HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ecommerceOrders';
        request.httpMethod = 'POST';
        
        // Define the JSON request body
        String jsonRequestBody ='{'+
            '\n  "_v": "22.4",'+
            '\n  "_type": "order",'+
            '\n  "_resource_state": "a041dbfa6881bd14e3c530ff09e85fdabe67dd2600d317ab1360df5c5987cd96",'+
            '\n  "adjusted_merchandize_total_tax": 2.45,'+
            '\n  "adjusted_shipping_total_tax": 0.30,'+
            '\n  "billing_address": {'+
            '\n    "_type": "order_address",'+
            '\n    "address1": "375 hudson street",'+
            '\n    "city": "New York",'+
            '\n    "country_code": "US",'+
            '\n    "first_name": "First Name Initial",'+
            '\n    "full_name": "First Name Initial Last Name Initial",'+
            '\n    "id": "81f6ab02e13ab98dd3cbceae5b",'+
            '\n    "last_name": "Last Name Initial",'+
            '\n    "phone": "9892501455",'+
            '\n    "postal_code": "94089",'+
            '\n    "state_code": "NY"'+
            '\n  },'+
            '\n  "confirmation_status": "confirmed",'+
            '\n  "created_by": "Customer",'+
            '\n  "creation_date": "2023-04-17T18:42:44.000Z",'+
            '\n  "currency": "MXN",'+
            '\n  "customer_info": {'+
            '\n    "_type": "customer_info",'+
            '\n    "customer_id": "987654321",'+
            '\n    "customer_name": "test testq",'+
            '\n    "email": "testInitial@test.com"'+
            '\n  },'+
            '\n  "customer_name": "test testq",'+
            '\n  "export_status": "ready",'+
            '\n  "guest": true,'+
            '\n  "last_modified": "2023-04-24T20:05:44.992Z",'+
            '\n  "merchandize_total_tax": 2.45,'+
            '\n  "notes": {'+
            '\n    "_type": "simple_link",'+
            '\n    "link": "https://bjck-003.dx.commercecloud.salesforce.com/s/RefArch/dw/shop/v22_4/orders/00000001/notes"'+
            '\n  },'+
            '\n  "order_no": "00000001",'+
            '\n  "order_token": "AfOBrUzy51gyLgVbOP42647rhfAW9BcrG-1g3b4KbeE",'+
            '\n  "order_total": 57.74,'+
            '\n  "payment_instruments": ['+
            '\n    {'+
            '\n      "_type": "order_payment_instrument",'+
            '\n      "amount": 57.74,'+
            '\n      "payment_card": {'+
            '\n        "_type": "payment_card",'+
            '\n        "card_type": "Visa",'+
            '\n        "credit_card_expired": false,'+
            '\n        "credit_card_token": "f4qt46icucf",'+
            '\n        "expiration_month": 11,'+
            '\n        "expiration_year": 2026,'+
            '\n        "holder": "test testq",'+
            '\n        "masked_number": "************1111",'+
            '\n        "number_last_digits": "1111"'+
            '\n      },'+
            '\n      "payment_instrument_id": "cdd0b6fc28f2e8320996962f3e",'+
            '\n      "payment_method_id": "CREDIT_CARD"'+
            '\n    }'+
            '\n  ],'+
            '\n  "payment_status": "not_paid",'+
            '\n  "product_items": ['+
            '\n    {'+
            '\n      "artclave": "PS.3WOD.TAUP.1066.1001.1",'+
            '\n      "_type": "product_item",'+
            '\n      "adjusted_tax": 2.45,'+
            '\n      "base_price": 49.00,'+
            '\n      "bonus_product_line_item": false,'+
            '\n      "gift": false,'+
            '\n      "item_id": "2983bf3d4c3add85766da44284",'+
            '\n      "item_text": "Sleeveless Pleated Top.",'+
            '\n      "price": 49.00,'+
            '\n      "price_after_item_discount": 49.00,'+
            '\n      "price_after_order_discount": 49.00,'+
            '\n      "product_id": "701644329396M",'+
            '\n      "product_name": "Sleeveless Pleated Top.",'+
            '\n      "quantity": 1,'+
            '\n      "shipment_id": "me",'+
            '\n      "tax": 2.45,'+
            '\n      "tax_basis": 49.00,'+
            '\n      "tax_class_id": "standard",'+
            '\n      "tax_rate": 0.05'+
            '\n    }'+
            '\n  ],'+
            '\n  "product_sub_total": 49.00,'+
            '\n  "product_total": 49.00,'+
            '\n  "shipments": ['+
            '\n    {'+
            '\n      "_type": "shipment",'+
            '\n      "adjusted_merchandize_total_tax": 2.45,'+
            '\n      "adjusted_shipping_total_tax": 0.30,'+
            '\n      "gift": false,'+
            '\n      "merchandize_total_tax": 2.45,'+
            '\n      "product_sub_total": 49.00,'+
            '\n      "product_total": 49.00,'+
            '\n      "shipment_id": "me",'+
            '\n      "shipment_no": "00000001",'+
            '\n      "shipment_total": 57.74,'+
            '\n      "shipping_address": {'+
            '\n        "_type": "order_address",'+
            '\n        "address1": "375 hudson street",'+
            '\n        "city": "New York",'+
            '\n        "country_code": "US",'+
            '\n        "first_name": "test",'+
            '\n        "full_name": "test testq",'+
            '\n        "id": "d31a6199c19dfed1fb410cbcd4",'+
            '\n        "last_name": "testq",'+
            '\n        "phone": "9892501455",'+
            '\n        "postal_code": "94089",'+
            '\n        "state_code": "NY"'+
            '\n      },'+
            '\n      "shipping_method": {'+
            '\n        "_type": "shipping_method",'+
            '\n        "description": "Order received within 7-10 business days",'+
            '\n        "id": "001",'+
            '\n        "name": "Ground",'+
            '\n        "price": 5.99,'+
            '\n        "c_estimatedArrivalTime": "7-10 Business Days"'+
            '\n      },'+
            '\n      "shipping_status": "not_shipped",'+
            '\n      "shipping_total": 5.99,'+
            '\n      "shipping_total_tax": 0.30,'+
            '\n      "tax_total": 2.75'+
            '\n    }'+
            '\n  ],'+
            '\n  "shipping_items": ['+
            '\n    {'+
            '\n      "_type": "shipping_item",'+
            '\n      "adjusted_tax": 0.30,'+
            '\n      "base_price": 5.99,'+
            '\n      "item_id": "3e818a63ae5b5058ca8b03db97",'+
            '\n      "item_text": "Shipping",'+
            '\n      "price": 5.99,'+
            '\n      "price_after_item_discount": 5.99,'+
            '\n      "shipment_id": "me",'+
            '\n      "tax": 0.30,'+
            '\n      "tax_basis": 5.99,'+
            '\n      "tax_class_id": "standard",'+
            '\n      "tax_rate": 0.05'+
            '\n    }'+
            '\n  ],'+
            '\n  "shipping_status": "not_shipped",'+
            '\n  "shipping_total": 5.99,'+
            '\n  "shipping_total_tax": 0.30,'+
            '\n  "site_id": "RefArch",'+
            '\n  "status": "open",'+
            '\n  "taxation": "net",'+
            '\n  "tax_total": 2.75'+
            '\n}';

        // Set the request body
        request.requestBody = Blob.valueOf(jsonRequestBody);
        
        // Set the mock request
        RestContext.request = request;
        
        // Create a test Lead
        /*Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Email = 'test@test.com';
        // Set other required fields as necessary
        insert testLead;
        
        // Create a test Account
        Account testAccount = new Account();
        testAccount.FirstName = 'Test';
        testAccount.LastName = 'Account';
        testAccount.PersonEmail = 'test@test.com';
        // Set other required fields as necessary
        insert testAccount;
        */
        // Set the mock response for Lead conversion
        Test.setMock(HttpCalloutMock.class, new LeadConvertSuccessMock());
        
        // Invoke the REST resource method
        Test.startTest();
        OrderCommerceRestResource.createOrders();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateOrdersAccount() {
        // Create a mock HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ecommerceOrders';
        request.httpMethod = 'POST';
        
        // Define the JSON request body
        String jsonRequestBody ='{'+
            '\n  "_v": "22.4",'+
            '\n  "_type": "order",'+
            '\n  "_resource_state": "a041dbfa6881bd14e3c530ff09e85fdabe67dd2600d317ab1360df5c5987cd96",'+
            '\n  "adjusted_merchandize_total_tax": 2.45,'+
            '\n  "adjusted_shipping_total_tax": 0.30,'+
            '\n  "billing_address": {'+
            '\n    "_type": "order_address",'+
            '\n    "address1": "375 hudson street",'+
            '\n    "city": "New York",'+
            '\n    "country_code": "US",'+
            '\n    "first_name": "test",'+
            '\n    "full_name": "test testq",'+
            '\n    "id": "81f6ab02e13ab98dd3cbceae5b",'+
            '\n    "last_name": "testq",'+
            '\n    "phone": "9892501455",'+
            '\n    "postal_code": "94089",'+
            '\n    "state_code": "NY"'+
            '\n  },'+
            '\n  "confirmation_status": "confirmed",'+
            '\n  "created_by": "Customer",'+
            '\n  "creation_date": "2023-04-17T18:42:44.000Z",'+
            '\n  "currency": "MXN",'+
            '\n  "customer_info": {'+
            '\n    "_type": "customer_info",'+
            '\n    "customer_id": "987654321",'+
            '\n    "customer_name": "test testq",'+
            '\n    "email": "test@test.com"'+
            '\n  },'+
            '\n  "customer_name": "test testq",'+
            '\n  "export_status": "ready",'+
            '\n  "guest": true,'+
            '\n  "last_modified": "2023-04-24T20:05:44.992Z",'+
            '\n  "merchandize_total_tax": 2.45,'+
            '\n  "notes": {'+
            '\n    "_type": "simple_link",'+
            '\n    "link": "https://bjck-003.dx.commercecloud.salesforce.com/s/RefArch/dw/shop/v22_4/orders/00000001/notes"'+
            '\n  },'+
            '\n  "order_no": "00000001",'+
            '\n  "order_token": "AfOBrUzy51gyLgVbOP42647rhfAW9BcrG-1g3b4KbeE",'+
            '\n  "order_total": 57.74,'+
            '\n  "payment_instruments": ['+
            '\n    {'+
            '\n      "_type": "order_payment_instrument",'+
            '\n      "amount": 57.74,'+
            '\n      "payment_card": {'+
            '\n        "_type": "payment_card",'+
            '\n        "card_type": "Visa",'+
            '\n        "credit_card_expired": false,'+
            '\n        "credit_card_token": "f4qt46icucf",'+
            '\n        "expiration_month": 11,'+
            '\n        "expiration_year": 2026,'+
            '\n        "holder": "test testq",'+
            '\n        "masked_number": "************1111",'+
            '\n        "number_last_digits": "1111"'+
            '\n      },'+
            '\n      "payment_instrument_id": "cdd0b6fc28f2e8320996962f3e",'+
            '\n      "payment_method_id": "CREDIT_CARD"'+
            '\n    }'+
            '\n  ],'+
            '\n  "payment_status": "not_paid",'+
            '\n  "product_items": ['+
            '\n    {'+
            '\n      "artclave": "PS.3WOD.TAUP.1066.1001.1",'+
            '\n      "_type": "product_item",'+
            '\n      "adjusted_tax": 2.45,'+
            '\n      "base_price": 49.00,'+
            '\n      "bonus_product_line_item": false,'+
            '\n      "gift": false,'+
            '\n      "item_id": "2983bf3d4c3add85766da44284",'+
            '\n      "item_text": "Sleeveless Pleated Top.",'+
            '\n      "price": 49.00,'+
            '\n      "price_after_item_discount": 49.00,'+
            '\n      "price_after_order_discount": 49.00,'+
            '\n      "product_id": "701644329396M",'+
            '\n      "product_name": "Sleeveless Pleated Top.",'+
            '\n      "quantity": 1,'+
            '\n      "shipment_id": "me",'+
            '\n      "tax": 2.45,'+
            '\n      "tax_basis": 49.00,'+
            '\n      "tax_class_id": "standard",'+
            '\n      "tax_rate": 0.05'+
            '\n    }'+
            '\n  ],'+
            '\n  "product_sub_total": 49.00,'+
            '\n  "product_total": 49.00,'+
            '\n  "shipments": ['+
            '\n    {'+
            '\n      "_type": "shipment",'+
            '\n      "adjusted_merchandize_total_tax": 2.45,'+
            '\n      "adjusted_shipping_total_tax": 0.30,'+
            '\n      "gift": false,'+
            '\n      "merchandize_total_tax": 2.45,'+
            '\n      "product_sub_total": 49.00,'+
            '\n      "product_total": 49.00,'+
            '\n      "shipment_id": "me",'+
            '\n      "shipment_no": "00000001",'+
            '\n      "shipment_total": 57.74,'+
            '\n      "shipping_address": {'+
            '\n        "_type": "order_address",'+
            '\n        "address1": "375 hudson street",'+
            '\n        "city": "New York",'+
            '\n        "country_code": "US",'+
            '\n        "first_name": "test",'+
            '\n        "full_name": "test testq",'+
            '\n        "id": "d31a6199c19dfed1fb410cbcd4",'+
            '\n        "last_name": "testq",'+
            '\n        "phone": "9892501455",'+
            '\n        "postal_code": "94089",'+
            '\n        "state_code": "NY"'+
            '\n      },'+
            '\n      "shipping_method": {'+
            '\n        "_type": "shipping_method",'+
            '\n        "description": "Order received within 7-10 business days",'+
            '\n        "id": "001",'+
            '\n        "name": "Ground",'+
            '\n        "price": 5.99,'+
            '\n        "c_estimatedArrivalTime": "7-10 Business Days"'+
            '\n      },'+
            '\n      "shipping_status": "not_shipped",'+
            '\n      "shipping_total": 5.99,'+
            '\n      "shipping_total_tax": 0.30,'+
            '\n      "tax_total": 2.75'+
            '\n    }'+
            '\n  ],'+
            '\n  "shipping_items": ['+
            '\n    {'+
            '\n      "_type": "shipping_item",'+
            '\n      "adjusted_tax": 0.30,'+
            '\n      "base_price": 5.99,'+
            '\n      "item_id": "3e818a63ae5b5058ca8b03db97",'+
            '\n      "item_text": "Shipping",'+
            '\n      "price": 5.99,'+
            '\n      "price_after_item_discount": 5.99,'+
            '\n      "shipment_id": "me",'+
            '\n      "tax": 0.30,'+
            '\n      "tax_basis": 5.99,'+
            '\n      "tax_class_id": "standard",'+
            '\n      "tax_rate": 0.05'+
            '\n    }'+
            '\n  ],'+
            '\n  "shipping_status": "not_shipped",'+
            '\n  "shipping_total": 5.99,'+
            '\n  "shipping_total_tax": 0.30,'+
            '\n  "site_id": "RefArch",'+
            '\n  "status": "open",'+
            '\n  "taxation": "net",'+
            '\n  "tax_total": 2.75'+
            '\n}';

        // Set the request body
        request.requestBody = Blob.valueOf(jsonRequestBody);
        
        // Set the mock request
        RestContext.request = request;
        
        // Set the mock response for Lead conversion
        Test.setMock(HttpCalloutMock.class, new LeadConvertSuccessMock());
        
        // Invoke the REST resource method
        Test.startTest();
        OrderCommerceRestResource.createOrders();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateOrdersLead() {
        // Create a mock HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ecommerceOrders';
        request.httpMethod = 'POST';
        
        // Define the JSON request body
        String jsonRequestBody ='{'+
            '\n  "_v": "22.4",'+
            '\n  "_type": "order",'+
            '\n  "_resource_state": "a041dbfa6881bd14e3c530ff09e85fdabe67dd2600d317ab1360df5c5987cd96",'+
            '\n  "adjusted_merchandize_total_tax": 2.45,'+
            '\n  "adjusted_shipping_total_tax": 0.30,'+
            '\n  "billing_address": {'+
            '\n    "_type": "order_address",'+
            '\n    "address1": "375 hudson street",'+
            '\n    "city": "New York",'+
            '\n    "country_code": "US",'+
            '\n    "first_name": "test",'+
            '\n    "full_name": "test testq",'+
            '\n    "id": "81f6ab02e13ab98dd3cbceae5b",'+
            '\n    "last_name": "testq",'+
            '\n    "phone": "9892501455",'+
            '\n    "postal_code": "94089",'+
            '\n    "state_code": "NY"'+
            '\n  },'+
            '\n  "confirmation_status": "confirmed",'+
            '\n  "created_by": "Customer",'+
            '\n  "creation_date": "2023-04-17T18:42:44.000Z",'+
            '\n  "currency": "MXN",'+
            '\n  "customer_info": {'+
            '\n    "_type": "customer_info",'+
            '\n    "customer_id": "987654321",'+
            '\n    "customer_name": "test testq",'+
            '\n    "email": "test@test.com"'+
            '\n  },'+
            '\n  "customer_name": "test testq",'+
            '\n  "export_status": "ready",'+
            '\n  "guest": true,'+
            '\n  "last_modified": "2023-04-24T20:05:44.992Z",'+
            '\n  "merchandize_total_tax": 2.45,'+
            '\n  "notes": {'+
            '\n    "_type": "simple_link",'+
            '\n    "link": "https://bjck-003.dx.commercecloud.salesforce.com/s/RefArch/dw/shop/v22_4/orders/00000001/notes"'+
            '\n  },'+
            '\n  "order_no": "00000001",'+
            '\n  "order_token": "AfOBrUzy51gyLgVbOP42647rhfAW9BcrG-1g3b4KbeE",'+
            '\n  "order_total": 57.74,'+
            '\n  "payment_instruments": ['+
            '\n    {'+
            '\n      "_type": "order_payment_instrument",'+
            '\n      "amount": 57.74,'+
            '\n      "payment_card": {'+
            '\n        "_type": "payment_card",'+
            '\n        "card_type": "Visa",'+
            '\n        "credit_card_expired": false,'+
            '\n        "credit_card_token": "f4qt46icucf",'+
            '\n        "expiration_month": 11,'+
            '\n        "expiration_year": 2026,'+
            '\n        "holder": "test testq",'+
            '\n        "masked_number": "************1111",'+
            '\n        "number_last_digits": "1111"'+
            '\n      },'+
            '\n      "payment_instrument_id": "cdd0b6fc28f2e8320996962f3e",'+
            '\n      "payment_method_id": "CREDIT_CARD"'+
            '\n    }'+
            '\n  ],'+
            '\n  "payment_status": "not_paid",'+
            '\n  "product_items": ['+
            '\n    {'+
            '\n      "artclave": "PS.3WOD.TAUP.1066.1001.1",'+
            '\n      "_type": "product_item",'+
            '\n      "adjusted_tax": 2.45,'+
            '\n      "base_price": 49.00,'+
            '\n      "bonus_product_line_item": false,'+
            '\n      "gift": false,'+
            '\n      "item_id": "2983bf3d4c3add85766da44284",'+
            '\n      "item_text": "Sleeveless Pleated Top.",'+
            '\n      "price": 49.00,'+
            '\n      "price_after_item_discount": 49.00,'+
            '\n      "price_after_order_discount": 49.00,'+
            '\n      "product_id": "701644329396M",'+
            '\n      "product_name": "Sleeveless Pleated Top.",'+
            '\n      "quantity": 1,'+
            '\n      "shipment_id": "me",'+
            '\n      "tax": 2.45,'+
            '\n      "tax_basis": 49.00,'+
            '\n      "tax_class_id": "standard",'+
            '\n      "tax_rate": 0.05'+
            '\n    }'+
            '\n  ],'+
            '\n  "product_sub_total": 49.00,'+
            '\n  "product_total": 49.00,'+
            '\n  "shipments": ['+
            '\n    {'+
            '\n      "_type": "shipment",'+
            '\n      "adjusted_merchandize_total_tax": 2.45,'+
            '\n      "adjusted_shipping_total_tax": 0.30,'+
            '\n      "gift": false,'+
            '\n      "merchandize_total_tax": 2.45,'+
            '\n      "product_sub_total": 49.00,'+
            '\n      "product_total": 49.00,'+
            '\n      "shipment_id": "me",'+
            '\n      "shipment_no": "00000001",'+
            '\n      "shipment_total": 57.74,'+
            '\n      "shipping_address": {'+
            '\n        "_type": "order_address",'+
            '\n        "address1": "375 hudson street",'+
            '\n        "city": "New York",'+
            '\n        "country_code": "US",'+
            '\n        "first_name": "test",'+
            '\n        "full_name": "test testq",'+
            '\n        "id": "d31a6199c19dfed1fb410cbcd4",'+
            '\n        "last_name": "testq",'+
            '\n        "phone": "9892501455",'+
            '\n        "postal_code": "94089",'+
            '\n        "state_code": "NY"'+
            '\n      },'+
            '\n      "shipping_method": {'+
            '\n        "_type": "shipping_method",'+
            '\n        "description": "Order received within 7-10 business days",'+
            '\n        "id": "001",'+
            '\n        "name": "Ground",'+
            '\n        "price": 5.99,'+
            '\n        "c_estimatedArrivalTime": "7-10 Business Days"'+
            '\n      },'+
            '\n      "shipping_status": "not_shipped",'+
            '\n      "shipping_total": 5.99,'+
            '\n      "shipping_total_tax": 0.30,'+
            '\n      "tax_total": 2.75'+
            '\n    }'+
            '\n  ],'+
            '\n  "shipping_items": ['+
            '\n    {'+
            '\n      "_type": "shipping_item",'+
            '\n      "adjusted_tax": 0.30,'+
            '\n      "base_price": 5.99,'+
            '\n      "item_id": "3e818a63ae5b5058ca8b03db97",'+
            '\n      "item_text": "Shipping",'+
            '\n      "price": 5.99,'+
            '\n      "price_after_item_discount": 5.99,'+
            '\n      "shipment_id": "me",'+
            '\n      "tax": 0.30,'+
            '\n      "tax_basis": 5.99,'+
            '\n      "tax_class_id": "standard",'+
            '\n      "tax_rate": 0.05'+
            '\n    }'+
            '\n  ],'+
            '\n  "shipping_status": "not_shipped",'+
            '\n  "shipping_total": 5.99,'+
            '\n  "shipping_total_tax": 0.30,'+
            '\n  "site_id": "RefArch",'+
            '\n  "status": "open",'+
            '\n  "taxation": "net",'+
            '\n  "tax_total": 2.75'+
            '\n}';

        // Set the request body
        request.requestBody = Blob.valueOf(jsonRequestBody);
        
        // Set the mock request
        RestContext.request = request;
        
        // Set the mock response for Lead conversion
        Test.setMock(HttpCalloutMock.class, new LeadConvertSuccessMock());
        
        // Invoke the REST resource method
        Test.startTest();
        OrderCommerceRestResource.createOrders();
        Test.stopTest();
    }
    
    // Implement a mock for successful Lead conversion
    private class LeadConvertSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Create a mock HTTP response for successful Lead conversion
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": true}');
            response.setStatusCode(200);
            return response;
        }
    }
}