@RestResource(urlMapping='/upsertIngresos/*')
global class IngresoRestResource {
    
    @HttpPost
    global static void createIngreso() {
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<Ingreso__c> listIngreso = new List<Ingreso__c>();
        final String S_GENERIC_RFC = 'XAXX010101000';
        
        String sNombre;
        String sTelefono;
        String sCelular;
        String sEmail;
        String sRFC;
        String sIdCuenta;
        
        RestRequest request = RestContext.request;
        String jsonString = request.requestBody.toString();
        
        try{
            // Parse the JSON string into a Map<String, Object>
            Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            
            // Get the VENTAS array from the JSON
            List<Object> ventas = (List<Object>)jsonData.get('VENTAS');
            
            for (Object ventaObj : ventas) {
                Map<String, Object> venta = (Map<String, Object>)ventaObj;
                sNombre = (String)venta.get('nombrecte');
                sTelefono = (String)venta.get('telefonocte');
                sCelular = (String)venta.get('celularcte');
                sEmail = (String)venta.get('emailcte');
                sRFC = (String)venta.get('rfccte');
            }
            
            //PRIMERA BUSQUEDA
            /*if(sNombre != '' && sTelefono != '' && sCelular != '' && sEmail != '' && sRFC != ''){
                sIdCuenta = [SELECT Id 
                             FROM Account 
                             WHERE Name =: sNombre 
                             AND (Phone =: sTelefono OR Phone =: sCelular) 
                             AND (INT_email__c =: sEmail OR PersonEmail =: sEmail)
                             AND (INT_RFC__c =: sRFC OR INT_RFC__c !=: sRFC) LIMIT 1].Id;
            }*/
            
            if(sNombre != '' && sTelefono != '' && sCelular != '' && sEmail != '' && sRFC != ''){
                //sIdCuenta
                List<Contact> lstFoundContact = new List<Contact>();
                for(Contact currentCto : [SELECT Id, Name, Phone, MobilePhone, Email, AccountId, Account.INT_RFC__c 
                                          FROM Contact 
                                          WHERE Name =: sNombre AND AccountId != null 
                                          AND (Account.INT_RFC__c =: sRFC 
                                               OR ((Account.INT_RFC__c = null OR Account.INT_RFC__c =: S_GENERIC_RFC) AND MobilePhone =: sCelular) 
                                               OR ((Account.INT_RFC__c = null OR Account.INT_RFC__c =: S_GENERIC_RFC) AND Phone =: sTelefono) 
                                               OR ((Account.INT_RFC__c = null OR Account.INT_RFC__c =: S_GENERIC_RFC) AND Email =: sEmail))]){
                    lstFoundContact.add(currentCto);
                }
                
                if(!lstFoundContact.isEmpty() && lstFoundContact.size() == 1){
                    sIdCuenta = lstFoundContact[0].AccountId;
                }else if(!lstFoundContact.isEmpty() && lstFoundContact.size() > 1){
                    response.put('status', 500);
                	response.put('message', 'Se han encontrado multiples cuentas para asociar a esta factura.');
                }else if(lstFoundContact.isEmpty()){
                    response.put('status', 500);
                	response.put('message', 'No se ha encontrado una cuenta para asociar esta factura.');
                }
            }
                        
            if(sIdCuenta != null){
                response.put('status', 200);
                response.put('message', 'OK');
                
                //Se movio la logica adentro de este if
				Map<String, String> mapPais = new Map<String, String>();
                for(Pais__c iPais : [SELECT Id, INT_PaisClave__c FROM Pais__c]){
                    mapPais.put(iPais.INT_PaisClave__c, iPais.Id);
                }
                
                Map<String, String> mapEstado = new Map<String, String>();
                for(Estado__c iEst : [SELECT Id, INT_External_Id__c FROM Estado__c]){
                    mapEstado.put(iEst.INT_External_Id__c, iEst.Id);
                }
                
                Map<String, String> mapCiudad = new Map<String, String>();
                for(Ciudad__c iCiu : [SELECT Id, INT_External_Id__c FROM Ciudad__c]){
                    mapCiudad.put(iCiu.INT_External_Id__c, iCiu.Id);
                }
            
                Map<String, String> mapColonia = new Map<String, String>();
                for(Colonia__c iCol : [SELECT Id, INT_External_Id__c FROM Colonia__c]){
                    mapColonia.put(iCol.INT_External_Id__c, iCol.Id);
                }
                
                // Iterate over each item in the VENTAS array
                for (Object ventaObj : ventas) {
                    Map<String, Object> venta = (Map<String, Object>)ventaObj;
                    
                    // Create a new Ingreso__c record
                    Ingreso__c ingreso = new Ingreso__c();
                    
                    // Set the field values from the JSON data
                    ingreso.INT_Cuenta__c = sIdCuenta;
                    ingreso.INT_Pais__c = mapPais.get((String)venta.get('pasiclave'));
                    ingreso.INT_Estado__c = mapEstado.get((String)venta.get('pasiclave') + ' ' + String.valueOf((Decimal)venta.get('entfednumcte')));
                    ingreso.INT_Ciudad__c = mapCiudad.get((String)venta.get('pasiclave') + ' ' + String.valueOf((Decimal)venta.get('entfednumcte')) + ' ' + String.valueOf((Decimal)venta.get('mponumcte')));
                    ingreso.INT_Colonia__c = mapCiudad.get((String)venta.get('pasiclave') + ' ' + String.valueOf((Decimal)venta.get('entfednumcte')) + ' ' + String.valueOf((Decimal)venta.get('mponumcte')) + ' ' + String.valueOf((Decimal)venta.get('colnumcte')));
                    //ingreso.INT_Cant_Facturada__c = (Decimal)venta.get('montoventa');
                    ingreso.INT_Ingresos__c = (Decimal)venta.get('montoventa');
                    ingreso.INT_Ejercicio__c = (Integer)venta.get('anio');
                    ingreso.INT_Mes__c = (Integer)venta.get('mes');
                    ingreso.INT_Dia__c = (Integer)venta.get('dia');
                    ingreso.INT_Canal_de_Venta__c = (String)venta.get('canalventa');
                    ingreso.INT_Ticket_venta__c = (String)venta.get('folioTicket');
                    
                    listIngreso.add(ingreso);
                }
                
                Database.UpsertResult[] results = Database.upsert(listIngreso, Ingreso__c.INT_Ticket_venta__c, false);
                
                Log_Integration__c log = new Log_Integration__c();
                log.Status_Code__c = String.valueOf(200);
                log.Endpoint__c = 'RestResource: upsertIngresos';
                log.Error_Message__c = null;
                log.Request__c = String.valueOf(jsonString).abbreviate(131072);
                log.Response__c = String.valueOf(response).abbreviate(131072);
                log.Method__c = 'POST';
                log.Date__c = Date.today();
                logs.add(log);                   
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertIngresos';
            log.Error_Message__c = 'Error: ' + ex.getMessage();
            log.Request__c = String.valueOf(jsonString).abbreviate(131072);
            log.Response__c = ('Error: ' + ex.getMessage() + ' ' + ex.getCause()).abbreviate(131072);
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            response.put('status', 500);
            response.put('message', ('Error: ' + ex.getMessage()));
        }
        insert logs;
        
        String jsonRespString = JSON.serialize(response);
        System.debug('jsonRespString ' + jsonRespString);
        if(!test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonRespString);
        }
    }
}