@RestResource(urlMapping='/createOrder')
global with sharing class TS4_CreateOrdersRest {
    @HttpPost
    global static void createOrders(){
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonRequest = request.requestBody.toString();
        orderWrapper input = (orderWrapper) JSON.deserialize(jsonRequest, orderWrapper.class);
        Date orderDateInit = String.isNotEmpty(input.orderStartDate)?Date.valueOf(input.orderStartDate):null;
        Order order=new Order();
        order.AccountId=input.accountId;
        order.EffectiveDate=orderDateInit;
        order.Status='Borrador';

        insert order;
        Map<String,String> responseMap=new Map<String,string>{
            'message' => 'Orden creada con exito',
            'Id' => order.Id
        };

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        res.statusCode = 200;
    }

    public class orderWrapper{
        public string accountId;
        public string orderStartDate;
    }
}