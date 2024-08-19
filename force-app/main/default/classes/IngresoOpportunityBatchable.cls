public class IngresoOpportunityBatchable implements Database.Batchable<sObject>{
    public Map<String, Object> requestMap;
    public Map<String, Object> mapOppId;
    public String query;

   public IngresoOpportunityBatchable(Map<String, Object> vRequestMap){
       requestMap = vRequestMap;
       mapOppId = new Map<String, Object>();
       List<Object> oportunidades = (List<Object>) requestMap.get('Oportunidades');
       List<String> listOppIds = new List<String>();
       query = 'select id from opportunity where id in (';
       
       for (Object obj : oportunidades) {
           Map<String, Object> OppMap = (Map<String, Object>) obj;
           String oppId = (String) OppMap.get('ID_OPORTUNIDAD');
           query += '\'' + oppId + '\',';
           mapOppId.put(oppId, obj);
       }
       if(query.charAt(query.length()-1) == 44){
           query = query.left(query.length()-1);
       }
       query += ')';
       System.debug('query: ' + query);
   }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<String> listArtClave = new List<String>();
        List<String> listOppIds = new List<String>();
        Map<String, Id> mapArtClaveOpplineId = new Map<String, Id>();
        Map<String, Id> mapArtClaveProduct2Id = new Map<String, Id>();
        Map<String, Id> mapUserAlias = new Map<String, Id>();
        List<String> lstArtClaveError = new List<String>();
        Map<String, String> mapFactTickId = new Map<String,String>();
        
        List<Object> oportunidades = (List<Object>) requestMap.get('Oportunidades');
        system.debug('oportunidades'+oportunidades);
        List<Ingreso__c> listIngreso = new List<Ingreso__c>();
        Map<Id, List<Factura__c>> mapIdFacturas = new Map<Id, List<Factura__c>>();
        Map<Id, List<Periodo_de_Ingreso__c>> mapIdPeriodos = new Map<Id, List<Periodo_de_Ingreso__c>>();
        List<Factura__c> listFacturas = new List<Factura__c>();
        List<Periodo_de_Ingreso__c> listPeriodoIngreso = new List<Periodo_de_Ingreso__c>();
        
        try{
            String sOpportunityId = '';
            String sArtClave = '';
            system.debug('mapOppId'+ mapOppId);
            system.debug('mapOppId.keySet()'+ mapOppId.keySet());
            for (String oppId : mapOppId.keySet()) {
                Map<String, Object> OppMap = (Map<String, Object>) mapOppId.get(oppId);
                
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
            system.debug('iOppline'+ [SELECT Id, Product2.INT_External_Id__c, Product2Id 
                                                FROM OpportunityLineItem 
                                                WHERE OpportunityId =:sOpportunityId 
                                                AND Product2.INT_External_Id__c IN: listArtClave]);
            
            for(Product2 iProduct : [SELECT Id, INT_External_Id__c FROM Product2 WHERE INT_External_Id__c IN: listArtClave])
            {
                mapArtClaveProduct2Id.put(iProduct.INT_External_Id__c, iProduct.Id);
            }
            
            for(User iUser : [SELECT Id, Alias_Sinter__c FROM User WHERE isActive = true]){
                mapUserAlias.put(iUser.Alias_Sinter__c, iUser.Id);
            }
            
            //Proceso para identificar ingresos existentes
            List<Ingreso__c> ingresosExistentes = [Select Id, INT_Oportunidad__c, INT_OrgProducto__r.INT_External_Id__c, INT_Ejercicio__c, INT_Mes__c From Ingreso__c Where INT_Oportunidad__c in: listOppIds];
            system.debug('ingresosExistentes.size()'+ ingresosExistentes.size());
            
            List<Factura__c> facturasExistentes = [Select Id, INT_Ticket_Venta__c, INT_Cantidad__c, INT_Ingreso__c, INT_Producto__c, INT_Ejercicio__c, INT_Mes__c From Factura__c Where INT_Related_Ingreso__c =: ingresosExistentes];
            List<Periodo_de_Ingreso__c> periodosExistentes = [Select Id, INT_Oportunidad__c, INT_Ejercicio__c, INT_Mes__c From Periodo_de_Ingreso__c Where INT_Oportunidad__c in: listOppIds];
            Map<String,Id> mapConcatIngrId = new Map<String,Id>();
            Map<String,Id> mapPerId = new Map<String,Id>();
            for(Ingreso__c ingre : ingresosExistentes){
                //System.debug(ingre.INT_Oportunidad__c + ingre.INT_OrgProducto__r.INT_External_Id__c);
                mapConcatIngrId.put(ingre.INT_Oportunidad__c + ingre.INT_OrgProducto__r.INT_External_Id__c + ingre.INT_Ejercicio__c + ingre.INT_Mes__c, ingre.Id);                
            	system.debug('mapConcatIngrId'+ mapConcatIngrId);
            }
            for(Factura__c fact : facturasExistentes){
                mapFactTickId.put(fact.INT_Producto__c + fact.INT_Ticket_Venta__c + fact.INT_Ejercicio__c + fact.INT_Mes__c, fact.Id);
            }
            for(Periodo_de_Ingreso__c per : periodosExistentes){
                mapPerId.put(per.INT_Oportunidad__c + String.valueOf(per.INT_Mes__c) + String.valueOf(per.INT_Ejercicio__c),per.Id);
            }
            
            for (Object obj : oportunidades) {
                Map<String, Object> OppMap = (Map<String, Object>) obj;
                sOpportunityId = (String) OppMap.get('ID_OPORTUNIDAD');
                mapIdFacturas.put(sOpportunityId, new List<Factura__c>());
                mapIdPeriodos.put(sOpportunityId, new List<Periodo_de_Ingreso__c>());
                
                List<Object> productos = (List<Object>) OppMap.get('PRODUCTOS');
                for(Object prodObject : productos){
                    Map<String, Object> prodMap = (Map<String, Object>) prodObject;
                    
                    
                    Ingreso__c iIngreso = new Ingreso__c();
                    
                    iIngreso.INT_Oportunidad__c = sOpportunityId;
                    iIngreso.INT_Producto__c = mapArtClaveOpplineId.get((String) prodMap.get('ARTCLAVE'));
                    iIngreso.INT_Metros_Cuadrados__c = (Decimal) prodMap.get('METROS_FACTURADOS');
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
                        system.debug('iFactu'+iFactu);
                        Map<String, Object> factuMap = (Map<String, Object>) iFactu;
                        Factura__c iFact = new Factura__c();
                        
                        system.debug('mapFactTickId'+mapFactTickId);
                        String facturaExistenteId = mapFactTickId.get(iIngreso.INT_OrgProducto__c + (String) factuMap.get('TICKET_VENTA') + String.valueOf((Integer) factuMap.get('EJERCICIO')) + + String.valueOf((Integer) factuMap.get('MES')));
                        system.debug('facturaExistenteId'+facturaExistenteId);
                        
                        if(facturaExistenteId != null){
                            iFact.Id = facturaExistenteId;
                        }
                        
                        iFact.INT_Producto__c = iIngreso.INT_OrgProducto__c;
                        iFact.INT_Ejecutivo_Ventas__c = (String) factuMap.get('EJECUTIVO_VENTAS'); // mapUserAlias.get((String) factuMap.get('EJECUTIVO_VENTAS')) != null? mapUserAlias.get((String) factuMap.get('EJECUTIVO_VENTAS')) : null;
                        iFact.INT_Fecha_Ticket_Venta__c = parseDate((String) factuMap.get('FECHA_TICKET_VENTA'));
                        iFact.INT_Ticket_Venta__c = (String) factuMap.get('TICKET_VENTA');
                        iFact.INT_Ingreso__c = (Decimal) factuMap.get('INGRESO');
                        iFact.INT_Cantidad__c = (Decimal) factuMap.get('CANTIDAD');
                        iFact.INT_Ejercicio__c = (Double) factuMap.get('EJERCICIO');
                        iFact.INT_Mes__c = (Double) factuMap.get('MES');
                        iFact.INT_Metros_Cuadrados__c = (Decimal) factuMap.get('METROS');
                        iFact.INT_Precio_de_venta__c = (Decimal) factuMap.get('PRECIO_VENTA');
                        //iIngreso.INT_Metros_Cuadrados__c = (Decimal) factuMap.get('METROS');
                        system.debug('iIngreso.INT_Ejercicio__c'+iIngreso.INT_Ejercicio__c);
                        system.debug('factuMap.get(EJERCICIO)'+factuMap.get('EJERCICIO'));
                        //linea anterior
                        //iIngreso.INT_Ejercicio__c = (iIngreso.INT_Ejercicio__c == null) ? (Double) factuMap.get('EJERCICIO') : null;
                        iIngreso.INT_Ejercicio__c = (iIngreso.INT_Ejercicio__c == null) ? (Integer) factuMap.get('EJERCICIO') : iIngreso.INT_Ejercicio__c;
                        system.debug('despues iIngreso.INT_Ejercicio__c'+ iIngreso.INT_Ejercicio__c);
                        //linea anterior
                        // iIngreso.INT_Mes__c = (iIngreso.INT_Mes__c == null) ? (Double) factuMap.get('MES') : null;
                        iIngreso.INT_Mes__c = (iIngreso.INT_Mes__c == null) ? (Integer) factuMap.get('MES') : iIngreso.INT_Mes__c ;
                        mapIdFacturas.get(iIngreso.INT_Oportunidad__c).add(iFact);
                    }
                    
                    //Proceso para identificar ingresos existentes
                    system.debug('sOpportunityId'+sOpportunityId);
                    system.debug('ARTCLAVE'+(String) prodMap.get('ARTCLAVE'));
                    system.debug('ejercicio'+iIngreso.INT_Ejercicio__c);
                    system.debug('mes'+ iIngreso.INT_Mes__c);
                    system.debug('ingre.Id'+iIngreso.Id);
                    //linea anterior
                    String ingresoExistenteId = mapConcatIngrId.get(sOpportunityId+(String) prodMap.get('ARTCLAVE') + iIngreso.INT_Ejercicio__c + iIngreso.INT_Mes__c);
                    //cambio de double a integer
                    //String ingresoExistenteId = mapConcatIngrId.get(sOpportunityId+(String) prodMap.get('ARTCLAVE') + (Integer) iIngreso.INT_Ejercicio__c + (Integer) iIngreso.INT_Mes__c);
                    //Proceso para identificar ingresos existentes
                    System.debug('Id de ingreso existente: ' + ingresoExistenteId);
                    if(ingresoExistenteId != null){
                        iIngreso.Id = ingresoExistenteId;
                    }
                    
                    if(iIngreso.INT_OrgProducto__c != null){
                        System.debug('iIngreso ' + iIngreso);
                        listIngreso.add(iIngreso);
                    }
                    
                    List<Object> periodos = (List<Object>) OppMap.get('PERIODOS');
                    for(Object iPeriodo : periodos){
                        Map<String, Object> mapPeriodos = (Map<String, Object>) iPeriodo;
                        Periodo_de_Ingreso__c iPer = new Periodo_de_Ingreso__c();
                        
                        Id periodoExistenteId = mapPerId.get(sOpportunityId + String.valueOf((Decimal)mapPeriodos.get('MES')) + String.valueOf((Integer)mapPeriodos.get('EJERCICIO')));
                        if(periodoExistenteId != null){
                            iPer.Id = periodoExistenteId;
                        }
                        
                        iPer.INT_Oportunidad__c = sOpportunityId;
                        iPer.INT_Ejercicio__c = (Integer) mapPeriodos.get('EJERCICIO');
                        iPer.INT_Mes__c = (Decimal) mapPeriodos.get('MES');
                        iPer.INT_Ingreso__c = (Decimal) mapPeriodos.get('INGRESO');
                        System.debug('adding iPer: ' + iPer);
                        if(!listPeriodoIngreso.contains(iPer)){
                        	listPeriodoIngreso.add(iPer);
                        }
                    }
                }
            }
            
            if(!listIngreso.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(listIngreso, false);
                system.debug('results'+results);
                for(Ingreso__c iIngreso : listIngreso){
                    String idIngresoProduct = '' + iIngreso.INT_OrgProducto__c + iIngreso.INT_Ejercicio__c + iIngreso.INT_Mes__c;
                    system.debug('mapIdFacturas'+mapIdFacturas);
                    for(Factura__c iFac : mapIdFacturas.get(iIngreso.INT_Oportunidad__c)){
                        //linea anterior
                        //String idFac = '' + iFac.INT_Producto__c +  iFac.INT_Ejercicio__c + iFac.INT_Mes__c;
                        String idFac = '' + iFac.INT_Producto__c + (Integer) iFac.INT_Ejercicio__c + (Integer) iFac.INT_Mes__c;
                        system.debug('idFac'+idFac);
                        system.debug('idIngresoProduct'+idIngresoProduct);
                        if(idFac == idIngresoProduct){
                            iFac.INT_Related_Ingreso__c = iIngreso.Id;
                        }
                    }
                    for(Factura__c iFac : mapIdFacturas.get(iIngreso.INT_Oportunidad__c)){
                    	if(!listFacturas.contains(iFac)){
                            System.debug('adding idfact: ' + iFac);
                            listFacturas.add(iFac);
                        }
                    }
                }
            }
            
            System.debug('listFacturas ' + listFacturas);
            if(!listFacturas.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(listFacturas, false);
                system.debug('result facturas'+results);
            }
            
            System.debug('listPeriodoIngreso.size(): ' + listPeriodoIngreso.size());
            for(Periodo_de_Ingreso__c iper : listPeriodoIngreso){
                System.debug('iper: ' + iper);
            }
            if(!listPeriodoIngreso.isEmpty()){
                Database.UpsertResult[] results = Database.upsert(listPeriodoIngreso, false);
            }
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(200);
            log.Endpoint__c = 'RestResource: upsertIngresoOportunidad';
            log.Error_Message__c = null;
            //log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
            //log.Response__c = String.valueOf(response).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            //response.put('status', 200);
            //response.put('message', 'OK');
            if(!lstArtClaveError.isEmpty()){
                //response.put('Error: ', lstArtClaveError);
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertIngresoOportunidad';
            log.Error_Message__c = 'Error: ' + ex.getMessage();
            //log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
            log.Response__c = ('Error: ' + ex.getMessage() + ' ' + ex.getCause()).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            //response.put('status', 500);
            //response.put('message', ('Error: ' + ex.getMessage()));
        }
        insert logs;
        
        //String jsonString = JSON.serialize(response);
        //System.debug('jsonString ' + jsonString);
        if(!test.isRunningTest()){
            //RestContext.response.addHeader('Content-Type', 'application/json');
            //RestContext.response.responseBody = Blob.valueOf(jsonString);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    public static Date parseDate(String sDate){
        String dateString = sDate;
        List<String> dateParts = dateString.split('-');
        Integer day = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        
        Date parsedDate = Date.valueOf(year + '-' + month + '-' + day);
        
        return parsedDate;
    }
}