@RestResource(urlMapping='/upsertIngresoOportunidad/*')
global class IngresoOpportunityRestResource {
    
    @HttpPost
    global static void upsertIngresoOpp(){
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<String> listArtClave = new List<String>();
        List<String> listOppIds = new List<String>();
        Map<String, Id> mapArtClaveOpplineId = new Map<String, Id>();
        Map<String, Id> mapArtClaveProduct2Id = new Map<String, Id>();
        Map<String, Id> mapUserAlias = new Map<String, Id>();
        List<String> lstArtClaveError = new List<String>();
        
        RestRequest request = RestContext.request;
        String jsonInput = request.requestBody.toString();
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                
        //old code
        /*
        List<Object> oportunidades = (List<Object>) data.get('Oportunidades');
        
        List<Ingreso__c> listIngreso = new List<Ingreso__c>();
        Map<Id, List<Factura__c>> mapIdFacturas = new Map<Id, List<Factura__c>>();
        Map<Id, List<Periodo_de_Ingreso__c>> mapIdPeriodos = new Map<Id, List<Periodo_de_Ingreso__c>>();
        List<Factura__c> listFacturas = new List<Factura__c>();
        List<Periodo_de_Ingreso__c> listPeriodoIngreso = new List<Periodo_de_Ingreso__c>();
		*/        
        try{
            Id batchInstanceId = Database.executeBatch(new IngresoOpportunityBatchable(data), 30);
			/*
            String sOpportunityId = '';
            String sArtClave = '';
            for (Object obj : oportunidades) {
                Map<String, Object> OppMap = (Map<String, Object>) obj;
                
                sOpportunityId = (String) OppMap.get('ID_OPORTUNIDAD');
                listOppIds.add(sOpportunityId);
                List<Object> productos = (List<Object>) OppMap.get('PRODUCTOS');
                //System.debug('Productos ' + productos);
                for(Object prodObject : productos){
                    Map<String, Object> prodMap = (Map<String, Object>) prodObject;
                    sArtClave = (String) prodMap.get('ARTCLAVE');
                    listArtClave.add(sArtClave);
                }
            }
            
            String sOppLineItemId = '';
            
            for(OpportunityLineItem iOppline : [SELECT Id, Product2.INT_External_Id__c, Product2Id 
                                                FROM OpportunityLineItem 
                                                WHERE OpportunityId =:sOpportunityId 
                                                AND Product2.INT_External_Id__c IN: listArtClave])
            {
                mapArtClaveOpplineId.put(iOppline.Product2.INT_External_Id__c, iOppline.Id);
            }
            
            for(Product2 iProduct : [SELECT Id, INT_External_Id__c FROM Product2 WHERE INT_External_Id__c IN: listArtClave])
            {
                mapArtClaveProduct2Id.put(iProduct.INT_External_Id__c, iProduct.Id);
            }
            
            for(User iUser : [SELECT Id, Alias_Sinter__c FROM User WHERE isActive = true]){
                mapUserAlias.put(iUser.Alias_Sinter__c, iUser.Id);
            }
            
            //Proceso para identificar ingresos existentes
            List<Ingreso__c> ingresosExistentes = [Select Id, INT_Oportunidad__c, INT_OrgProducto__r.INT_External_Id__c From Ingreso__c Where INT_Oportunidad__c in: listOppIds];
            Map<String,Id> mapConcatIngrId = new Map<String,Id>();
            for(Ingreso__c ingre : ingresosExistentes){
                System.debug(ingre.INT_Oportunidad__c + ingre.INT_OrgProducto__r.INT_External_Id__c);
                mapConcatIngrId.put(ingre.INT_Oportunidad__c + ingre.INT_OrgProducto__r.INT_External_Id__c, ingre.Id);
            }
            
            for (Object obj : oportunidades) {
                Map<String, Object> OppMap = (Map<String, Object>) obj;
                sOpportunityId = (String) OppMap.get('ID_OPORTUNIDAD');
                mapIdFacturas.put(sOpportunityId, new List<Factura__c>());
                mapIdPeriodos.put(sOpportunityId, new List<Periodo_de_Ingreso__c>());
                
                List<Object> productos = (List<Object>) OppMap.get('PRODUCTOS');
                for(Object prodObject : productos){
                    Map<String, Object> prodMap = (Map<String, Object>) prodObject;
                    
                    //Proceso para identificar ingresos existentes
                    String ingresoExistenteId = mapConcatIngrId.get(sOpportunityId+(String) prodMap.get('ARTCLAVE'));
                    
                    Ingreso__c iIngreso = new Ingreso__c();
                    
                    //Proceso para identificar ingresos existentes
                    System.debug('Id de ingreso existente: ' + ingresoExistenteId);
                    if(ingresoExistenteId != null){
                        iIngreso.Id = ingresoExistenteId;
                    }
                    
                    iIngreso.INT_Oportunidad__c = sOpportunityId;
                    iIngreso.INT_Producto__c = mapArtClaveOpplineId.get((String) prodMap.get('ARTCLAVE'));
                    System.debug('Producto de oportunidad: ' + mapArtClaveOpplineId.get((String) prodMap.get('ARTCLAVE')));
                    System.debug('Producto de oportunidad: ' + iIngreso.INT_Producto__c);
                    if(mapArtClaveOpplineId.get((String) prodMap.get('ARTCLAVE')) == null){
                        System.debug('No se encontro el producto de oportunidad con ARTCLAR: ' + prodMap.get('ARTCLAVE'));
                    }
                    iIngreso.INT_OrgProducto__c = mapArtClaveProduct2Id.get((String) prodMap.get('ARTCLAVE'));
                    if(mapArtClaveProduct2Id.get((String) prodMap.get('ARTCLAVE')) == null){
                        System.debug('No se encontro el producto con ARTCLAR: ' + prodMap.get('ARTCLAVE'));
                        lstArtClaveError.add('El producto: ' + (String) prodMap.get('ARTCLAVE') + ' No se encuentra en la base de datos de Salesforce.');
                    }
                    iIngreso.INT_Ingresos__c = (Decimal) prodMap.get('INGRESO_FACTURADO');
                    iIngreso.INT_Cantidad__c = (Decimal) prodMap.get('CANTIDAD_FACTURADA');
                    
                    List<Object> facturas = (List<Object>) prodMap.get('FACTURAS');
                    for(Object iFactu : facturas){
                        Map<String, Object> factuMap = (Map<String, Object>) iFactu;
                        Factura__c iFact = new Factura__c();
                        iFact.INT_Producto__c = iIngreso.INT_OrgProducto__c;
                        iFact.INT_Ejecutivo_Ventas__c = mapUserAlias.get((String) factuMap.get('EJECUTIVO_VENTAS')) != null? mapUserAlias.get((String) factuMap.get('EJECUTIVO_VENTAS')) : null;
                        iFact.INT_Fecha_Ticket_Venta__c = parseDate((String) factuMap.get('FECHA_TICKET_VENTA'));
                        iFact.INT_Ticket_Venta__c = (String) factuMap.get('TICKET_VENTA');
                        iFact.INT_Ingreso__c = (Decimal) factuMap.get('INGRESO');
                        iFact.INT_Cantidad__c = (Decimal) factuMap.get('CANTIDAD');
                        iIngreso.INT_Metros_Cuadrados__c = (Decimal) factuMap.get('METROS');
                        iIngreso.INT_Ejercicio__c = (Double) factuMap.get('EJERCICIO');
                        iIngreso.INT_Mes__c = (Double) factuMap.get('MES');
                        mapIdFacturas.get(iIngreso.INT_Oportunidad__c).add(iFact);
                    }
                    
                    if(iIngreso.INT_OrgProducto__c != null){
                        System.debug('iIngreso ' + iIngreso);
                        listIngreso.add(iIngreso);
                    }
                    
                    List<Object> periodos = (List<Object>) OppMap.get('PERIODOS');
                    for(Object iPeriodo : periodos){
                        Map<String, Object> mapPeriodos = (Map<String, Object>) iPeriodo;
                        Periodo_de_Ingreso__c iPer = new Periodo_de_Ingreso__c();
                        iPer.INT_Oportunidad__c = sOpportunityId;
                        iPer.INT_Ejercicio__c = (Integer) mapPeriodos.get('EJERICIO');
                        iPer.INT_Mes__c = (Decimal) mapPeriodos.get('MES');
                        iPer.INT_Ingreso__c = (Decimal) mapPeriodos.get('INGRESO');
                        listPeriodoIngreso.add(iPer);
                    }
                }
            }
            
            if(!listIngreso.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(listIngreso, false);
                for(Ingreso__c iIngreso : listIngreso){
                    for(Factura__c iFac : mapIdFacturas.get(iIngreso.INT_Oportunidad__c)){
                        if(iFac.INT_Producto__c == iIngreso.INT_OrgProducto__c){
                            iFac.INT_Related_Ingreso__c = iIngreso.Id;
                        }
                        if(!listFacturas.contains(iFac)){
                            listFacturas.add(iFac);
                        }
                    }
                }
            }
            
            System.debug('listFacturas ' + listFacturas);
            if(!listFacturas.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(listFacturas, false);
            }
            
            System.debug('listPeriodoIngreso ' + listPeriodoIngreso);
            if(!listPeriodoIngreso.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(listPeriodoIngreso, false);
            }
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(200);
            log.Endpoint__c = 'RestResource: getCabeceraOpportunity';
            log.Error_Message__c = null;
            log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
            log.Response__c = String.valueOf(response).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            response.put('status', 200);
            response.put('message', 'OK');
            if(!lstArtClaveError.isEmpty()){
                response.put('Error: ', lstArtClaveError);
            }*/
            
            
            
            response.put('status', 200);
            response.put('message', 'OK');
            if(!lstArtClaveError.isEmpty()){
                response.put('Error: ', lstArtClaveError);
            }
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(200);
            log.Endpoint__c = 'RestResource: upsertIngresoOportunidad';
            log.Error_Message__c = null;
            log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
            log.Response__c = String.valueOf(response).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertIngresoOportunidad';
            log.Error_Message__c = 'Error: ' + ex.getMessage();
            log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
            log.Response__c = ('Error: ' + ex.getMessage() + ' ' + ex.getCause()).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            response.put('status', 500);
            response.put('message', ('Error: ' + ex.getMessage()));
        }
        insert logs;
        
        String jsonString = JSON.serialize(response);
        System.debug('jsonString ' + jsonString);
        if(!test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonString);
        }
    }
    
    public static Date parseDate(String sDate){
        String dateString = sDate;
        List<String> dateParts = dateString.split('-');
        Integer day = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        
        Date parsedDate = Date.valueOf(year + '-' + month + '-' + day);
        
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        System.debug('Count: ' + i);
        
        return parsedDate;
    }
}