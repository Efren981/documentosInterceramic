public class OrderCommerceQueueable implements System.Queueable, Database.AllowsCallouts {
    String sBody = '';
    String sRecordId = '';
    
    public OrderCommerceQueueable (String id, String b) {
        this.sRecordId = id;
        this.sBody = b;
    }
    
    public void execute(QueueableContext ctx){
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(sBody);
        
        List<Object> productItems = (List<Object>) parsedJson.get('product_items');
        List<String> listIdsProducts = new List<String>();
        for(Object iProd : productItems){
            Map<String, Object> prodMap = (Map<String, Object>) iProd;
            listIdsProducts.add((String) prodMap.get('artclave'));
        }
        
        Map<String, String> mapProductId = new Map<String, String>();
        Map<String, String> mapPricebookEntry = new Map<String, String>();
        String PricebookId = '';
        for(PricebookEntry iProd : [SELECT Id, Product2Id, Product2.INT_External_Id__c, Pricebook2Id
                                    FROM PricebookEntry 
                                    WHERE Product2.INT_External_Id__c IN: listIdsProducts])
        {
            mapProductId.put(iProd.Product2.INT_External_Id__c, iProd.Product2Id);
            mapPricebookEntry.put(iProd.Product2.INT_External_Id__c, iProd.Id);
            PricebookId = iProd.Pricebook2Id;
        }
        
        Order nOrder = new Order();
        nOrder.AccountId = sRecordId;
        nOrder.INT_Nombre_Cliente__c = sRecordId;
        
        String dateTimeString = (String) parsedJson.get('creation_date');
        
        Integer year = Integer.valueOf(dateTimeString.substring(0, 4));
        Integer month = Integer.valueOf(dateTimeString.substring(5, 7));
        Integer day = Integer.valueOf(dateTimeString.substring(8, 10));
        Integer hour = Integer.valueOf(dateTimeString.substring(11, 13));
        Integer minute = Integer.valueOf(dateTimeString.substring(14, 16));
        Integer second = Integer.valueOf(dateTimeString.substring(17, 19));
        
        Datetime dateTimeValue = Datetime.newInstanceGMT(year, month, day, hour, minute, second);
        
        //nOrder.ActivatedDate = dateTimeValue;
        nOrder.EffectiveDate = date.valueOf(dateTimeValue);
        nOrder.Status = 'Borrador';
        nOrder.Pricebook2Id = PricebookId;
        nOrder.CurrencyIsoCode = (String) parsedJson.get('currency');
        nOrder.INT_Divisa__c = (String) parsedJson.get('currency');
        //nOrder.INT_Estado__c = (String) parsedJson.get('status');
        nOrder.INT_Estado_Confirmacion__c = (String) parsedJson.get('confirmation_status');
        nOrder.INT_EstadoPago__c = (String) parsedJson.get('payment_status');
        nOrder.Name = (String) parsedJson.get('order_no');
        nOrder.INT_Total_Pedido__c = (Decimal) parsedJson.get('order_total');
        nOrder.INT_Estado_exportacion__c = (String) parsedJson.get('export_status');
        nOrder.INT_Invitado__c = (Boolean) parsedJson.get('guest');
        nOrder.INT_Impuesto_Total__c = (Decimal) parsedJson.get('tax_total');
        nOrder.INT_Numero_Pedido__c = (String) parsedJson.get('order_no');
        nOrder.INT_Token_Pedido__c = (String) parsedJson.get('order_token');

        List<Object> paymentInstruments = (List<Object>) parsedJson.get('payment_instruments');
        for(Object payment : paymentInstruments){
            Map<String, Object> paymentMap = (Map<String, Object>) payment;
            
            Map<String, Object> payMap = (Map<String, Object>) paymentMap.get('payment_card');
            //for(Object pay : paymentList){
                //Map<String, Object> payMap = (Map<String, Object>) pay;
                nOrder.INT_Anio_Expiracion__c = (Decimal) payMap.get('expiration_year');
                nOrder.INT_Mes_Expiracion__c = (Decimal) payMap.get('expiration_month');
                nOrder.INT_TarjetaCreditoCaducada__c = (Boolean) payMap.get('credit_card_expired');
                nOrder.INT_TokenTarjetaCredito__c = (String) payMap.get('credit_card_token');
                nOrder.INT_Tipo_Tarjeta__c = (String) payMap.get('card_type');
                nOrder.INT_Nombre_titular__c = (String) payMap.get('holder');
                nOrder.INT_NumeroTarjeta__c = (String) payMap.get('masked_number');
                nOrder.INT_Ultimos_digitos__c = Decimal.valueOf((String) payMap.get('number_last_digits'));
            //}
            nOrder.INT_Id_MetodoPago__c = (String) paymentMap.get('payment_method_id');
            nOrder.INT_Id_InstrumentoPago__c = (String) paymentMap.get('payment_instrument_id');
        }

        Map<String, Object> billingMap = (Map<String, Object>) parsedJson.get('billing_address');
        //for(Object bill : billingAddress){
            //Map<String, Object> billingMap = (Map<String, Object>) bill;
            nOrder.INT_Calle__c = (String) billingMap.get('address1');
            nOrder.INT_Codigo_Postal__c = Double.valueOf((String) billingMap.get('postal_code'));
            //nOrder.INT_Ciudad__c = (String) billingMap.get('city');
            //nOrder.INT_Pais__c = (String) billingMap.get('country_code');
            //nOrder.INT_Estado__c = (String) billingMap.get('state_code');
        //}
        
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        Database.SaveResult result = Database.insert(nOrder, false);
        if(!result.isSuccess()){
            System.debug('Error ' + result.getErrors());
        }
        if(result.isSuccess()){
            String sOrderId = result.getId();
            
            //List<Object> productItems = (List<Object>) parsedJson.get('product_items');
            for(Object iProd : productItems){
                Map<String, Object> prodMap = (Map<String, Object>) iProd;
                OrderItem iOItem = new OrderItem();
                iOItem.OrderId = sOrderId;
                iOItem.Product2Id = mapProductId.get((String) prodMap.get('artclave'));
                iOItem.INT_Impuesto_Ajustado__c = (Decimal) prodMap.get('adjusted_tax');
                iOItem.INT_Precio_Base__c = (Decimal) prodMap.get('base_price');
                iOItem.UnitPrice = (Decimal) prodMap.get('base_price');
                iOItem.INT_Bonificacion_Producto__c = (Boolean) prodMap.get('bonus_product_line_item');
                iOItem.INT_Regalo__c = (Boolean) prodMap.get('gift');
                iOItem.INT_Texto_Item__c = (String) prodMap.get('item_text');
                iOItem.INT_Precio__c = (Decimal) prodMap.get('price');
                iOItem.INT_Precio_ProductoDescuento__c = (Decimal) prodMap.get('price_after_item_discount');
                iOItem.INT_Precio_PedidoDescuento__c = (Decimal) prodMap.get('price_after_order_discount');
                iOItem.INT_Cantidad__c = (Decimal) prodMap.get('quantity');
                iOItem.Quantity = (Decimal) prodMap.get('quantity');
                iOItem.INT_Impuesto__c = (Decimal) prodMap.get('tax');
                iOItem.INT_Impuesto_base__c = (Decimal) prodMap.get('tax_basis');
                iOItem.INT_Clase_Impuesto__c = (String) prodMap.get('tax_class_id');
                iOItem.INT_Tasa_Impuesto__c = (Decimal) prodMap.get('tax_rate');
                iOItem.PricebookEntryId = mapPricebookEntry.get((String) prodMap.get('artclave'));
                lstOrderItem.add(iOItem);
            }
        }
        
        if(!lstOrderItem.isEmpty()){
            Database.UpsertResult[] results = Database.upsert(lstOrderItem, false);
            for(Database.UpsertResult res : results){
                if(!res.isSuccess()){
                    System.debug('Error ' + res.getErrors());
                }
            }
        }
    }
}