@RestResource(urlMapping='/upsertLeads/*')
global class LeadRestResource { 
    
    @HttpPost
    global static void createLeads() {
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        List<ClienteSF> listClientesSF = new List<ClienteSF>();
        
        try {
            RestRequest request = RestContext.request;
            String jsonInput = request.requestBody.toString();
             
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            List<Object> leads = (List<Object>) data.get('Clientes');
            
            List<Lead> leadsToUpsert = new List<Lead>();
            
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
            
            Map<String, String> mapFranquicia = new Map<String, String>();
            for(Franquicia__c iFra : [SELECT Id, INT_EmpNum__c FROM Franquicia__c]){
                mapFranquicia.put(String.valueOf(iFra.INT_EmpNum__c), iFra.Id);
            }
            
            Map<String, String> mapSucursal = new Map<String, String>();
            for(Sucursal__c iSuc : [SELECT Id, INT_SucClave__c FROM Sucursal__c]){
                mapSucursal.put(iSuc.INT_SucClave__c, iSuc.Id);
            }
            
            for (Object obj : leads) {
                Map<String, Object> leadMap = (Map<String, Object>) obj;
                String clienteId = (String) leadMap.get('Cliente_Id');
                
                if (clienteId != null && clienteId != '') {
                    Lead lead = new Lead();
                    lead.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get('Relaciones_Publicas').getRecordTypeId();
                    lead.Email = (String) leadMap.get('Correo');
                    lead.INT_Cliente_Id__c = (String) leadMap.get('Cliente_Id');
                    lead.FirstName = (String) leadMap.get('Nombre');
                    lead.LastName = (String) leadMap.get('Apellido_Paterno'); 
                    lead.LastName += (String) leadMap.get('Apellido_Materno') != null ? ' ' + (String) leadMap.get('Apellido_Materno') : '';
                    //lead.LastName = (String) leadMap.get('Apellido Materno');
                    lead.Phone = (String) leadMap.get('Telefono');
                    lead.MobilePhone = (String) leadMap.get('Celular');
                    lead.LeadSource = (String) leadMap.get('Origen_prospecto');
                    //lead.owner = (String) leadMap.get('Ejecutivo_Asignado'); //picklist
                    //lead.Type = (String) leadMap.get('Tipo cliente');
                    lead.INT_Clasificacion_Venta__c = (String) leadMap.get('Clasificacion_Ventas'); //picklist
                    lead.INT_Clasificacion__c = (String) leadMap.get('Clasificacion');
                    lead.Company = (String) leadMap.get('Compania');
                    lead.Title = (String) leadMap.get('Cargo');
                    lead.INT_Tipo_Persona__c = (String) leadMap.get('Persona');
                    
                    lead.INT_Pais__c = mapPais.get((String) leadMap.get('Pais')) != null ? mapPais.get((String) leadMap.get('Pais')) : null;
                    lead.INT_Estado__c = (mapEstado.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado')) != null) ? mapEstado.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado')) : null;
                    lead.INT_Ciudad__c = (mapCiudad.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Ciudad')) != null) ? mapCiudad.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Ciudad')) : null;
                    lead.INT_Colonia__c = (mapColonia.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Ciudad') + ' ' + (String) leadMap.get('Colonia')) != null) ? mapColonia.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Ciudad') + ' ' + (String) leadMap.get('Colonia')) : null;
                    lead.INT_Franquicia__c = mapFranquicia.get((String) leadMap.get('Franquicia')) != null && lead.INT_Colonia__c != null ? mapFranquicia.get((String) leadMap.get('Franquicia')) : null;
                    lead.INT_Sucursal__c = mapSucursal.get((String) leadMap.get('Sucursal')) != null && lead.INT_Franquicia__c != null ? mapSucursal.get((String) leadMap.get('Sucursal')) : null;
                    
                    
                    lead.INT_Zona__c = (String) leadMap.get('Zona'); //picklist
                    lead.INT_Tipo_Prospecto__c = (String) leadMap.get('Tipo_cliente'); //picklist
                    lead.INT_Canal_Venta__c = (String) leadMap.get('Canal_de_Venta'); //picklist
                    lead.INT_Ubicacion__c = (String) leadMap.get('Ubicacion');
                    lead.Industry = (String) leadMap.get('Industria');
                    lead.INT_Presencia__c = (String) leadMap.get('Presencia');
					                    
                    Map<String, Object> direccionMap = (Map<String, Object>) leadMap.get('Direccion');
                    if (direccionMap != null) {
                        lead.Country = (String) direccionMap.get('Pais');
                        lead.State = (String) direccionMap.get('Estado');
                        lead.City = (String) direccionMap.get('Ciudad');
                        lead.PostalCode = (String) direccionMap.get('Codigo_Postal');
                        lead.INT_CP__c = (String) direccionMap.get('Codigo_Postal');
                        lead.Street = (String) direccionMap.get('Calle');
                        lead.INT_Calle__c = (String) direccionMap.get('Calle');
                        
                        lead.INT_NumExt__c = (String) direccionMap.get('Numero_Exterior');
                        lead.INT_NumInt__c = (String) direccionMap.get('Numero_Interior');
                    }
                    
                    Map<String, Object> datosFiscalesMap = (Map<String, Object>) leadMap.get('Datos_fiscales');
                    if (datosFiscalesMap != null) {
                        lead.INT_RFC__c = (String) datosFiscalesMap.get('RFC');
                        lead.INT_Razon_Social__c = (String) datosFiscalesMap.get('Razon_Social');
                        lead.INT_Uso_CFDI__c = (String) datosFiscalesMap.get('Uso_CFDI');
                        lead.INT_Regimen_Fiscal__c = (String) datosFiscalesMap.get('Regimen_Fiscal');
                        lead.INT_Regimen_Capital__c = (String) datosFiscalesMap.get('Regimen_de_capital');
                        
                        Map<String, Object> direccionFiscalMap = (Map<String, Object>) datosFiscalesMap.get('Direccion_Fiscal');
                        if (direccionFiscalMap != null) {
                            lead.INT_Pais_Fiscal__c = mapPais.get((String) direccionFiscalMap.get('Pais')) != null ? mapPais.get((String) direccionFiscalMap.get('Pais')) : null;
                            lead.INT_Estado_Fiscal__c = (mapEstado.get((String) direccionFiscalMap.get('Pais') + ' ' + (String) direccionFiscalMap.get('Estado')) != null) ? mapEstado.get((String) direccionFiscalMap.get('Pais') + ' ' + (String) direccionFiscalMap.get('Estado')) : null;
                            lead.INT_Ciudad_Fiscal__c = (mapCiudad.get((String) direccionFiscalMap.get('Pais') + ' ' + (String) direccionFiscalMap.get('Estado') + ' ' + (String) direccionFiscalMap.get('Ciudad')) != null) ? mapCiudad.get((String) direccionFiscalMap.get('Pais') + ' ' + (String) direccionFiscalMap.get('Estado') + ' ' + (String) direccionFiscalMap.get('Ciudad')) : null;
                            lead.INT_Colonia_Fiscal__c = (mapColonia.get((String) direccionFiscalMap.get('Pais') + ' ' + (String) direccionFiscalMap.get('Estado') + ' ' + (String) direccionFiscalMap.get('Ciudad') + ' ' + (String) direccionFiscalMap.get('Colonia')) != null) ? mapColonia.get((String) direccionFiscalMap.get('Pais') + ' ' + (String) direccionFiscalMap.get('Estado') + ' ' + (String) direccionFiscalMap.get('Ciudad') + ' ' + (String) direccionFiscalMap.get('Colonia')) : null;
                            
                            lead.INT_CP_Fiscal__c = (String) direccionFiscalMap.get('Codigo_Postal');
                            lead.INT_Calle_Fiscal__c = (String) direccionFiscalMap.get('Calle');
                            
                            lead.INT_NumExt_Fiscal__c = (String) direccionFiscalMap.get('Numero_Exterior');
                            lead.INT_NumInt_Fiscal__c = (String) direccionFiscalMap.get('Numero_Interior');
                        }
                    }
                    leadsToUpsert.add(lead);
                }
            }
            
            System.debug('leadsToUpsert ' + leadsToUpsert);
            System.debug('leadsToUpsert size' + leadsToUpsert.size());
            
            if (!leadsToUpsert.isEmpty()) {
                Database.upsertResult[] upsertResults = Database.upsert(leadsToUpsert, Lead.INT_Cliente_Id__c, false);
                System.debug('leadsToUpsert after upsert ' + leadsToUpsert.size());
                for (Database.UpsertResult upsertResult : upsertResults) {
                    if (upsertResult.isSuccess()) {
                        for(Lead ilead : leadsToUpsert){
                            if(ilead.Id == upsertResult.getId()){
                                ClienteSF cSf = new ClienteSF();
                                cSf.Salesforce_Id = ilead.Id;
                                cSf.Cliente_Id = ilead.INT_Cliente_Id__c;
                                listClientesSF.add(cSf);
                            }
                        }
                        upsertedCount++;
                    }else{
                        failedCount++;
                        Errors += upsertResult.getErrors();
                    }
                }
                
                if(upsertedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(200);
                    log.Endpoint__c = 'RestResource: upsertLeads';
                    log.Error_Message__c = null;
                    log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
                    log.Response__c = ('Leads upserted: ' + upsertedCount + ' ' + listClientesSF).abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
                
                if(failedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(500);
                    log.Endpoint__c = 'RestResource: upsertLeads';
                    log.Error_Message__c = 'Failed to upsert Lead. Errors: ' + failedCount;
                    log.Request__c = String.valueOf(jsonInput).abbreviate(131072);
                    log.Response__c = Errors.abbreviate(131072);
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
                
                response.put('status', 200);
                response.put('message', ('Clientes correctos: ' + upsertedCount + ', ' + 'Errores: ' + failedCount + ' ' + Errors));
                response.put('Correct', listClientesSF);
            }
        } catch (Exception ex) {
            // Handle exception
            RestRequest request = RestContext.request;
            String jsonInput = request.requestBody.toString();
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertLeads';
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
    
    Public class ClienteSF {
        String Salesforce_Id;
        String Cliente_Id;
    }
}