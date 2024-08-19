@isTest
public class OrderCommerceQueueableTest {
    @TestSetup
    static void makeData(){
        Account acc =  TestDataFactory.createAccount('Cuenta de Prueba CPQ', '0123456789', 'test@test.com', 'VECJ880326XXX');
        acc.INT_Tipo_Cuenta__c = 'Relaciones Publicas';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relaciones Publicas').getRecordTypeId();
        update acc;
        Product2 product = TestDataFactory.createProduct('Test Producto', 'pza', 'CU.ACRY.UNIC.GALO.40001-2');
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 11);
    }
    
    @isTest
    static void testExecute() {
        /*// Create test data
        Account testAccount = new Account(
            Name = 'Cuenta de Prueba CPQ',
            Phone = '0123456789',
            INT_Clasificacion__c = 'Nacional',
            INT_RFC__c='VECJ880326XXX',
            INT_Tipo_Cuenta__c = 'Relaciones Publicas',
            INT_Presencia__c = 'Nacional',
            INT_Giro_Negocio__c = 'Casas y Residencias',
            INT_Tipo_Persona__c = 'Física',
            INT_Calle__c = 'calle test',
            INT_CP__c = 'cp',
            INT_NumExt__c = 'num ext'
        );
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relaciones Publicas').getRecordTypeId();
        insert testAccount;
        
        Product2 iProducto = new Product2();
        iProducto.Name = 'Test Producto';
        iProducto.INT_External_Id__c = 'CU.ACRY.UNIC.GALO.40001-2';
        iProducto.IsActive = true;
        insert iProducto;
        
        PricebookEntry iPrice = new PricebookEntry();
        iPrice.Product2Id = iProducto.Id;
        iPrice.Pricebook2Id = Test.getStandardPricebookId();
        iPrice.UnitPrice = 11;
        insert iPrice;    */    
        
        String jsonBody = '{'
            + '"_v": "22.4",'
            + '"_type": "order",'
            + '"_resource_state": "a041dbfa6881bd14e3c530ff09e85fdabe67dd2600d317ab1360df5c5987cd96",'
            + '"adjusted_merchandize_total_tax": 2.45,'
            + '"adjusted_shipping_total_tax": 0.30,'
            + '"billing_address": {'
            +     '"_type": "order_address",'
            +     '"address1": "375 hudson street",'
            +     '"city": "New York",'
            +     '"country_code": "US",'
            +     '"first_name": "test",'
            +     '"full_name": "test testq",'
            +     '"id": "81f6ab02e13ab98dd3cbceae5b",'
            +     '"last_name": "testq",'
            +     '"phone": "9892501455",'
            +     '"postal_code": "94089",'
            +     '"state_code": "NY"'
            + '},'
            + '"confirmation_status": "confirmed",'
            + '"created_by": "Customer",'
            + '"creation_date": "2023-04-17T18:42:44.000Z",'
            + '"currency": "MXN",'
            + '"customer_info": {'
            +     '"_type": "customer_info",'
            +     '"customer_id": "987654321",'
            +     '"customer_name": "test testq",'
            +     '"email": "test@test.com"'
            + '},'
            + '"customer_name": "test testq",'
            + '"export_status": "ready",'
            + '"guest": true,'
            + '"last_modified": "2023-04-24T20:05:44.992Z",'
            + '"merchandize_total_tax": 2.45,'
            + '"notes": {'
            +     '"_type": "simple_link",'
            +     '"link": "https://bjck-003.dx.commercecloud.salesforce.com/s/RefArch/dw/shop/v22_4/orders/00000001/notes"'
            + '},'
            + '"order_no": "00000001",'
            + '"order_token": "AfOBrUzy51gyLgVbOP42647rhfAW9BcrG-1g3b4KbeE",'
            + '"order_total": 57.74,'
            + '"payment_instruments": ['
            +     '{'
            +         '"_type": "order_payment_instrument",'
            +         '"amount": 57.74,'
            +         '"payment_card": {'
            +             '"_type": "payment_card",'
            +             '"card_type": "Visa",'
            +             '"credit_card_expired": false,'
            +             '"credit_card_token": "f4qt46icucf",'
            +             '"expiration_month": 11,'
            +             '"expiration_year": 2026,'
            +             '"holder": "test testq",'
            +             '"masked_number": "************1111",'
            +             '"number_last_digits": "1111"'
            +         '},'
            +         '"payment_instrument_id": "cdd0b6fc28f2e8320996962f3e",'
            +         '"payment_method_id": "CREDIT_CARD"'
            +     '}'
            + '],'
            + '"payment_status": "not_paid",'
            + '"product_items": ['
            +     '{'
            +         '"artclave": "CU.ACRY.UNIC.GALO.40001-2",'
            +         '"_type": "product_item",'
            +         '"adjusted_tax": 2.45,'
            +         '"base_price": 49.00,'
            +         '"bonus_product_line_item": false,'
            +         '"gift": false,'
            +         '"item_id": "2983bf3d4c3add85766da44284",'
            +         '"item_text": "Sleeveless Pleated Top.",'
            +         '"price": 49.00,'
            +         '"price_after_item_discount": 49.00,'
            +         '"price_after_order_discount": 49.00,'
            +         '"product_id": "701644329396M",'
            +         '"product_name": "Sleeveless Pleated Top.",'
            +         '"quantity": 1,'
            +         '"shipment_id": "me",'
            +         '"tax": 2.45,'
            +         '"tax_basis": 49.00,'
            +         '"tax_class_id": "standard",'
            +         '"tax_rate": 0.05'
            +     '}'
            + '],'
            + '"product_sub_total": 49.00,'
            + '"product_total": 49.00,'
            + '"shipments": ['
            +     '{'
            +         '"_type": "shipment",'
            +         '"adjusted_merchandize_total_tax": 2.45,'
            +         '"adjusted_shipping_total_tax": 0.30,'
            +         '"gift": false,'
            +         '"merchandize_total_tax": 2.45,'
            +         '"product_sub_total": 49.00,'
            +         '"product_total": 49.00,'
            +         '"shipment_id": "me",'
            +         '"shipment_no": "00000001",'
            +         '"shipment_total": 57.74,'
            +         '"shipping_address": {'
            +             '"_type": "order_address",'
            +             '"address1": "375 hudson street",'
            +             '"city": "New York",'
            +             '"country_code": "US",'
            +             '"first_name": "test",'
            +             '"full_name": "test testq",'
            +             '"id": "d31a6199c19dfed1fb410cbcd4",'
            +             '"last_name": "testq",'
            +             '"phone": "9892501455",'
            +             '"postal_code": "94089",'
            +             '"state_code": "NY"'
            +         '},'
            +         '"shipping_method": {'
            +             '"_type": "shipping_method",'
            +             '"description": "Order received within 7-10 business days",'
            +             '"id": "001",'
            +             '"name": "Ground",'
            +             '"price": 5.99,'
            +             '"c_estimatedArrivalTime": "7-10 Business Days"'
            +         '},'
            +         '"shipping_status": "not_shipped",'
            +         '"shipping_total": 5.99,'
            +         '"shipping_total_tax": 0.30,'
            +         '"tax_total": 2.75'
            +     '}'
            + '],'
            + '"shipping_items": ['
            +     '{'
            +         '"_type": "shipping_item",'
            +         '"adjusted_tax": 0.30,'
            +         '"base_price": 5.99,'
            +         '"item_id": "3e818a63ae5b5058ca8b03db97",'
            +         '"item_text": "Shipping",'
            +         '"price": 5.99,'
            +         '"price_after_item_discount": 5.99,'
            +         '"shipment_id": "me",'
            +         '"tax": 0.30,'
            +         '"tax_basis": 5.99,'
            +         '"tax_class_id": "standard",'
            +         '"tax_rate": 0.05'
            +     '}'
            + '],'
            + '"shipping_status": "not_shipped",'
            + '"shipping_total": 5.99,'
            + '"shipping_total_tax": 0.30,'
            + '"site_id": "RefArch",'
            + '"status": "open",'
            + '"taxation": "net",'
            + '"tax_total": 2.75'
            + '}';
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        // Enqueue the queueable job
        Test.startTest();
        System.enqueueJob(new OrderCommerceQueueable(testAccount.Id, jsonBody));
        Test.stopTest();
    }
    
}