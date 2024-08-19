@RestResource(urlMapping='/upsertCommerceLeads/*')
global class LeadCommerceRestResource {

    @HttpPost
    global static void createCommerceLeads() {
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        
        try{
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
            
             for (Object obj : leads) {
                Map<String, Object> leadMap = (Map<String, Object>) obj;
                 String clienteId = (String) leadMap.get('customerNumber');
                 
                 System.debug('clienteId ' + clienteId);
                 if (clienteId != null && clienteId != '') {
                     Lead lead = new Lead();
                     lead.INT_Cliente_Id__c = clienteId;
                     lead.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get('Relaciones_Publicas').getRecordTypeId();
                     lead.FirstName = (String) leadMap.get('Nombres');
                     lead.LastName = (String) leadMap.get('Apellidos');
                     lead.LeadSource = (String) leadMap.get('Origen');
                     lead.Phone = (String) leadMap.get('Telefono');
                     lead.MobilePhone = (String) leadMap.get('Telefono_Personal');
                     lead.Email = (String) leadMap.get('Correo');
                     lead.INT_Contrasenia__c = (String) leadMap.get('Contrasenia');
                     
                     lead.INT_Pais__c = mapPais.get((String) leadMap.get('Pais')) != null ? mapPais.get((String) leadMap.get('Pais')) : null;
                     lead.INT_Estado__c = (mapEstado.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado')) != null) ? mapEstado.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado')) : null;
                     lead.INT_Ciudad__c = (mapCiudad.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio')) != null) ? mapCiudad.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio')) : null;
                     lead.INT_Colonia__c = (mapColonia.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio') + ' ' + (String) leadMap.get('Colonia')) != null) ? mapColonia.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio') + ' ' + (String) leadMap.get('Colonia')) : null;
                     
                     lead.Street = (String) leadMap.get('Calle');
                     lead.INT_Calle__c = (String) leadMap.get('Calle');
                     lead.INT_NumExt__c = (String) leadMap.get('Numero_Exterior');
                     lead.INT_NumInt__c = (String) leadMap.get('Numero_Interior');
                     lead.INT_Entre_Calles__c = (String) leadMap.get('Entre_que_calles');
                     lead.Company = ((String) leadMap.get('Compania')) != null ? ((String) leadMap.get('Compania')) : '-';
                     
                     Map<String, Object> ubicacionMap = (Map<String, Object>) leadMap.get('Ubicacion');
                     if(ubicacionMap != null){
                         String Depto = ((String) ubicacionMap.get('Lugar') == 'Departamento') ? 'Lugar: ' + (String) ubicacionMap.get('Lugar') : null;
                         String Casa = ((String) ubicacionMap.get('Lugar') != 'Departamento') ? 'Lugar: ' + (String) ubicacionMap.get('Lugar') : null;
                         
                         String Estacio = ((Boolean) ubicacionMap.get('Estacionamiento')) ? 'Sí' : 'No';
                         String Estacionamiento = 'Estacionamiento: ' + Estacio; //ambas
                         String Distancia_aproximada = 'Considerando las opciones anteriores, ¿cuál es la distancia aproximada a la entrada de la casa (metros)? ' + (String) ubicacionMap.get('Distancia_aproximada'); //ambas
                         String Distancia_entrada = ((String) ubicacionMap.get('Lugar') == 'Departamento') ? 'Una vez llegado al piso de entrega, cuál es la distancia aproximada a la puerta del departamento: ' + (String) ubicacionMap.get('Distancia_entrada') : 'Distancia de la entrada a la primera habitación techada: ' + (String) ubicacionMap.get('Distancia_entrada'); //ambas
                         String Piso_de_entrega = ((String) ubicacionMap.get('Lugar') == 'Departamento') ? 'Piso de entrega ' + (String) ubicacionMap.get('Piso_de_entrega') : null; //dpto
                         String Desniv = ((Boolean) ubicacionMap.get('Desnivel')) ? 'Sí' : 'No';
                         String Desnivel = ((String) ubicacionMap.get('Lugar') != 'Departamento') ? 'Existe algún desnivel ' + Desniv : null; //casa
                         String Ramp = ((Boolean) ubicacionMap.get('Rampa')) ? 'Sí' : 'No';
                         String Rampa = ((String) ubicacionMap.get('Lugar') != 'Departamento') ? 'Hay rampa ' + Ramp : null; //casa
                         String Por_donde_se_subira_el_material = ((String) ubicacionMap.get('Lugar') == 'Departamento') ? '¿Por donde se subirá el material? ' + (String) ubicacionMap.get('Por_donde_se_subira_el_material') : null; //dpto
                         String Esca = ((Boolean) ubicacionMap.get('Escaleras')) ? 'Sí' : 'No';
                         String Escaleras = 'Hay escalera(s): ' + Esca; //ambas
                         
                         if(Casa != null){
                             String Hogar = Casa + ', ' + Estacionamiento + ', ' + Distancia_aproximada + ', ' + Distancia_entrada + ', ' + Desnivel + ', ' + Rampa + ', ' + Escaleras;
                             lead.INT_Ubicacion__c = Hogar.abbreviate(131072);
                         }
                         
                         if(Depto != null){
                             String Departamento = Depto + ', ' + Estacionamiento + ', ' + Distancia_aproximada + ', ' + Distancia_entrada + ', ' + Piso_de_entrega + ', ' + Por_donde_se_subira_el_material + ', ' + Escaleras;
                             lead.INT_Ubicacion__c = Departamento.abbreviate(131072);
                         }
                     }
                     System.debug('lead ' + lead);
                     leadsToUpsert.add(lead);
                 }
             }
            
            if (!leadsToUpsert.isEmpty()) {
                Database.upsertResult[] upsertResults = Database.upsert(leadsToUpsert, Lead.INT_Cliente_Id__c, false);
                for (Database.UpsertResult upsertResult : upsertResults) {
                    System.debug('upsertResult '  + upsertResult);
                    if (upsertResult.isSuccess()) {
                        upsertedCount++;
                    }else{
                        failedCount++;
                        Errors += upsertResult.getErrors();
                    }
                }
                
                if(upsertedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(200);
                    log.Endpoint__c = 'RestResource: upsertCommerceLeads';
                    log.Error_Message__c = null;
                    log.Request__c = null;
                    log.Response__c = 'Leads upserted: ' + upsertedCount;
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
                
                if(failedCount > 0){
                    Log_Integration__c log = new Log_Integration__c();
                    log.Status_Code__c = String.valueOf(500);
                    log.Endpoint__c = 'RestResource: upsertCommerceLeads';
                    log.Error_Message__c = 'Failed to upsert Lead. Errors: ' + failedCount;
                    log.Request__c = null;
                    log.Response__c = Errors;
                    log.Method__c = 'POST';
                    log.Date__c = Date.today();
                    logs.add(log);
                }
                
                response.put('status', 200);
                response.put('message', ('Clientes correctos: ' + upsertedCount + ', ' + 'Errores: ' + failedCount + ' ' + Errors));
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(500);
            log.Endpoint__c = 'RestResource: upsertCommerceLeads';
            log.Error_Message__c = 'Error: ' + ex.getMessage();
            log.Request__c = null;
            log.Response__c = 'Error: ' + ex.getMessage();
            log.Method__c = 'POST';
            log.Date__c = Date.today();
            logs.add(log);
            
            response.put('status', 500);
            response.put('message', ('Error: ' + ex.getMessage()));
        }
        insert logs;
        
        String jsonString = JSON.serialize(response);
        System.debug('jsonString ' +  jsonString);
        if(!test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonString);
        }
    }
}