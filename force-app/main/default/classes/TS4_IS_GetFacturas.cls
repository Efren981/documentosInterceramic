public class TS4_IS_GetFacturas {
    @AuraEnabled
    public static Map<String, Object> createSigntaureRequest(String idCaso){
        Map<String, Object> responseMap = new Map<String, Object>();
        Case caso=[Select Id,TS4_Tipo_Factura__c,TS4_Ticket__c from case where Id=:idCaso limit 1];
        String missingFields = '';
        Map<String, String> requiredFields = new Map<String, String>{
            'Ticket' => caso.TS4_Ticket__c,
            'Tipo Factura' => caso.TS4_Tipo_Factura__c
        };
        for (String fieldName : requiredFields.keySet()) {
            if (String.isBlank(requiredFields.get(fieldName))) {
                missingFields += (String.isBlank(missingFields) ? '' : ', ') + fieldName;
            }
        }
        if (!String.isBlank(missingFields)) {
            responseMap.put('message', 'Error: Los siguientes campos son obligatorios: ' + missingFields);
            responseMap.put('flag', false);
            return responseMap;
        }
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
            request.setEndpoint('callout:AWS_GetFacturas');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('pFolio', caso.TS4_Ticket__c);
            request.setHeader('pTipoFact', caso.TS4_Tipo_Factura__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            
            Http http = new Http();
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                
                String jsonResponse = response.getBody().toString();
                // Check for the "RESULTADO" key in the response to determine the structure
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                if (jsonMap.containsKey('RESULTADO') && String.valueOf(jsonMap.get('RESULTADO')) == 'NOT OK') {
                    responseMap.put('message', String.valueOf(jsonMap.get('ERROR')));
                    responseMap.put('flag', false);
                    return responseMap;
                }else{
                    wrapperFacturas input = (wrapperFacturas) JSON.deserialize(jsonResponse, wrapperFacturas.class);

                    // Paso 1: Consulta los productos existentes en Salesforce
                    Set<String> uniqueKeys = new Set<String>();
                    for(TS4_IS_GetFacturas.wrapperPartidas data : input.PARTIDAS) {
                        uniqueKeys.add(data.ARTCLAVE);
                    }
                    List<TS4_Producto_del_ticket__c> lstProductos=[SELECT Id, TS4_Clave_de_articulo__c FROM TS4_Producto_del_ticket__c WHERE TS4_Clave_de_articulo__c IN :uniqueKeys];
                    Map<String, TS4_Producto_del_ticket__c> existingTicketsMap = new Map<String, TS4_Producto_del_ticket__c>();
                    for(TS4_Producto_del_ticket__c producto:lstProductos){
                        existingTicketsMap.put(producto.TS4_Clave_de_articulo__c,producto);
                    }

                    List<TS4_Producto_del_ticket__c> lstTickets =new List<TS4_Producto_del_ticket__c>();
                    for(TS4_IS_GetFacturas.wrapperPartidas data:input.PARTIDAS){
                        TS4_Producto_del_ticket__c ticket=new TS4_Producto_del_ticket__c();
                        if(existingTicketsMap.containsKey(data.ARTCLAVE)) {
                            ticket = existingTicketsMap.get(data.ARTCLAVE);
                        } else {
                            ticket = new TS4_Producto_del_ticket__c();
                            ticket.TS4_Id_Caso__c =caso.Id;
                        }
                        ticket.ALMCLAVE__c=data.ALMCLAVE;
                        ticket.DESCRIPCION__c=data.DESCRIPCION;
                        ticket.TS4_DESCTOPORCENTAJE__c=data.DESCTOPORCENTAJE!=null ? Decimal.valueOf(data.DESCTOPORCENTAJE):0;
                        ticket.TS4_PRECIOUNITARIO__c=data.PRECIOUNITARIO;
                        ticket.TIPOPRECIO__c=data.TIPOPRECIO;
                        ticket.CANTIDAD__c=data.CANTIDAD;
                        ticket.TS4_Tipo__c=data.TIPO;
                        ticket.METROUVENTA__c=String.valueOf(data.METROUVENTA);
                        ticket.TS4_UNICLAVE__c=data.UNICLAVE;
                        ticket.TS4_Calibre_del_tono__c=data.CALIBRETONO;
                        ticket.TS4_Peso__c=data.PESO;
                        ticket.TS4_Clave_de_articulo__c=data.ARTCLAVE;
                        ticket.TS4_ARTNUM__c=String.valueOf(data.ARTNUM);
                        
                        lstTickets.add(ticket);
                    }
                    Integer createdCount = 0;
                    Integer updatedCount = 0;
                    Integer errorCount = 0;
                    Database.UpsertResult[] ticketResults = Database.upsert(lstTickets, false);
                    // Recorre los resultados del upsert
                    for (Integer i = 0; i < ticketResults.size(); i++) {
                        Database.UpsertResult result = ticketResults[i];
                        TS4_Producto_del_ticket__c ticket = lstTickets[i];
                        if (result.isSuccess()) {
                            if (existingTicketsMap.containsKey(ticket.TS4_Clave_de_articulo__c)) {
                                updatedCount++;
                            } else {
                                createdCount++;
                            }
                        } else {
                            errorCount++;
                        }
                    }
                    String message = 'Proceso completado. ';
                    if (createdCount > 0) message += createdCount + ' registros creados. ';
                    if (updatedCount > 0) message += updatedCount + ' registros actualizados. ';
                    if (errorCount > 0) message += errorCount + ' registros con errores.';
                    responseMap.put('message', message);
                    responseMap.put('flag',true);
                    return responseMap;
                }
                
            } else {
                // Throw a custom exception with the error message
                responseMap.put('statusCode', response.getStatusCode());
                responseMap.put('body',response.getBody());
                System.debug(responseMap);
                return responseMap;
            }
    }
    public class wrapperFacturas{
        public string RESULTADO;
        public string CTEPLANTA;
        public Integer EMPNUM;
        public string SUCCLAVE;
        public string RECLAMACION_BILL_TO;
        public string STATUS;
        public string FECHA;
        public string CTENUM;
        public string NOMBRECOMPLETOCTE;
        public string CALLECTE;
        public Integer ESTADO;
        public Integer MUNICIPIO;
        public string COLONIA;
        public string LOCALIDAD;
        public Integer CPCTE;
        public string TELEFONOCTE;
        public string RFCCTE;
        public string EMAILCTE;
        public Decimal MONTO;
        public Decimal MONTOCOBRADO;
        public Decimal PESOTOTAL;
        public Decimal MONTODESCTO;
        public Integer PORCENTAJEIVA;
        public Decimal DESGLOSARIVA;
        public string FECHALTA;
        public string FECHAAUTO;
        public string UBICACION;
        public string USUCLAVEALTA;
        public Integer RASTREO;
        public Integer EMPACTIVA;
        public string URLPDF;
        public List<wrapperPartidas> PARTIDAS;
    }

    public class wrapperPartidas{
        public Integer ARTNUM;
        public string ARTCLAVE;
        public Decimal PESO;
        public string CALIBRETONO;
        public string UNICLAVE;
        public Decimal METROUVENTA;
        public string TIPO;
        public Integer CANTIDAD;
        public string TIPOPRECIO;
        public string ALMCLAVE;
        public string DESCRIPCION;
        public string DESCTOPORCENTAJE;
        public Decimal PRECIOUNITARIO;
    }
}