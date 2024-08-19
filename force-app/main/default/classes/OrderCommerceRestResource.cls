@RestResource(urlMapping='/ecommerceOrders/*')
global class OrderCommerceRestResource {
    
    @HttpPost
    global static void createOrders() {
        Integer upsertedCount = 0;
        Integer failedCount = 0;
        String Errors = '';
        Map<String, Object> response = new Map<String, Object>();
        List<Log_Integration__c> logs = new List<Log_Integration__c>();
        
        try{
            RestRequest request = RestContext.request;
            String jsonRequestBody = request.requestBody.toString();
            
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonRequestBody);
            
            Map<String, Object> customerMap = (Map<String, Object>) parsedJson.get('customer_info');
            //Map<String, Object> customerBillAddress = new Map<String, Object>();
            String sEmail = '';
            String sFirstName = '';
            String sLastName = '';
            String sAddress = '';
            String sCity = '';
            String sPostalCode = '';
            String sStateCode = '';
            String sCountryCode = '';
            String sPhone = '';
            String clienteId = '';
            
            /*for (Object custom : customer) {
            Map<String, Object> customMap = (Map<String, Object>) custom;*/
            
            sEmail = (String) customerMap.get('email');
            clienteId = (String) customerMap.get('customer_id');
            Map<String, Object> customerBillAddress = (Map<String, Object>) parsedJson.get('billing_address');
            System.debug('customerBillAddress ' + customerBillAddress);
            //}
            
            //if(customerBillAddress != null){
            /*for(Object customAddress : customerBillAddress){
				Map<String, Object> customMap = (Map<String, Object>) customAddress;*/
            
            sFirstName = (String) customerBillAddress.get('first_name');
            sLastName = (String) customerBillAddress.get('last_name');
            sAddress = (String) customerBillAddress.get('address1');
            sCity = (String) customerBillAddress.get('city');
            sPostalCode = (String) customerBillAddress.get('postal_code');
            sStateCode = (String) customerBillAddress.get('state_code');
            sCountryCode = (String) customerBillAddress.get('country_code');
            sPhone = (String) customerBillAddress.get('phone');
            //}
            //}
            
            Account orderAccount = new Account();
            System.debug(sEmail + ' ' +  sFirstName + ' ' + sLastName);
            if(sEmail != '' && sFirstName != '' && sLastName != '') {
                try{
                    orderAccount = [SELECT Id 
                                    FROM Account 
                                    WHERE (PersonEmail =: sEmail or INT_email__c =: sEmail)
                                    AND FirstName =: sFirstName 
                                    AND LastName =: sLastName];
                }catch(exception e){
                    System.debug(e);
                    orderAccount.Id = null;
                }
                
                System.debug('orderAccount ' + orderAccount);
            }
            
            Lead orderLead = new Lead();
            if(orderAccount.Id == null){
                try{
                    orderLead = [SELECT Id, FirstName, LastName, Email, Phone, Street, City, State, PostalCode 
                                 FROM Lead 
                                 WHERE Email =: sEmail 
                                 AND FirstName =: sFirstName 
                                 AND LastName =: sLastName];
                }catch(exception e){
                    System.debug(e);
                    orderLead.Id = null;
                }
            }
            
            Account convertedAccount = new Account();
            if(orderLead.Id != null){
                // Create a new Account object for the Person Account
                Account personAccount = new Account();
                personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                personAccount.FirstName = orderLead.FirstName;
                personAccount.LastName = orderLead.LastName;
                personAccount.INT_email__c = orderLead.Email;
                personAccount.Phone = orderLead.Phone;
                personAccount.BillingStreet = orderLead.Street;
                personAccount.BillingCity = orderLead.City;
                personAccount.BillingState = orderLead.State;
                personAccount.BillingPostalCode = orderLead.PostalCode;
                
                // Create a new Contact object for the Person Account
                Contact personAccountContact = new Contact();
                personAccountContact.FirstName = orderLead.FirstName;
                personAccountContact.LastName = orderLead.LastName;
                personAccountContact.Email = orderLead.Email;
                personAccountContact.Phone = orderLead.Phone;
                
                // Convert the Lead into a Person Account
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(orderLead.Id);
                leadConvert.convertedstatus = 'Convertido';
                leadConvert.setAccountId(personAccount.Id);
                leadConvert.setContactId(personAccountContact.Id);
                leadConvert.setDoNotCreateOpportunity(true); // Optionally, prevent creating an Opportunity
                Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
                
                // Verify if the conversion was successful
                if (leadConvertResult.isSuccess()) {
                    // Retrieve the converted Account and Contact
                    convertedAccount = [SELECT Id, Name FROM Account WHERE Id = :leadConvertResult.getAccountId()];
                    Contact convertedContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :leadConvertResult.getContactId()];
                    System.debug('Lead converted successfully to Person Account: ' + convertedAccount.Name + ', Contact: ' + convertedContact.FirstName + ' ' + convertedContact.LastName);
                } else {
                    // Handle the conversion error
                    System.debug('Lead conversion failed with the following error: ' + leadConvertResult.getErrors()[0].getMessage());
                }
            }
            
            List<Lead> leadsToUpsert = new List<Lead>();
            if(orderAccount.Id == null && orderLead.Id == null){
                /*
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
                */
                
                Lead lead = new Lead();
                lead.INT_Cliente_Id__c = clienteId;
                lead.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get('Relaciones_Publicas').getRecordTypeId();
                lead.FirstName = sFirstName;
                lead.LastName = sLastName;
                lead.LeadSource = 'Internet';
                lead.Phone = sPhone;
                lead.MobilePhone = sPhone;
                lead.Email = sEmail;
                /*
                lead.INT_Pais__c = mapPais.get((String) leadMap.get('Pais')) != null ? mapPais.get((String) leadMap.get('Pais')) : null;
                lead.INT_Estado__c = (mapEstado.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado')) != null) ? mapEstado.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado')) : null;
                lead.INT_Ciudad__c = (mapCiudad.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio')) != null) ? mapCiudad.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio')) : null;
                lead.INT_Colonia__c = (mapColonia.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio') + ' ' + (String) leadMap.get('Colonia')) != null) ? mapColonia.get((String) leadMap.get('Pais') + ' ' + (String) leadMap.get('Estado') + ' ' + (String) leadMap.get('Municipio') + ' ' + (String) leadMap.get('Colonia')) : null;
                */
                lead.Street = sAddress;
                lead.INT_Calle__c = sAddress;
                leadsToUpsert.add(lead);
            }
            
            System.debug('leadsToUpsert ' + leadsToUpsert);
            
            if (!leadsToUpsert.isEmpty()) {
                String leadId = '';
                Database.upsertResult[] upsertResults = database.upsert(leadsToUpsert, Lead.INT_Cliente_Id__c, false);
                
                for (Database.UpsertResult result : upsertResults) {
                    if (result.isSuccess()) {
                        leadId = result.getId();
                        upsertedCount++;
                    } else {
                        failedCount++;
                        Errors += result.getErrors()[0].getMessage() + '\n';
                        System.debug('Errors ' + Errors);
                    }
                }
                
                System.debug('leadId ' + leadId);
                if(leadId != ''){
                    orderLead = [SELECT Id, FirstName, LastName, Email, Phone, Street, City, State, PostalCode 
                                 FROM Lead 
                                 WHERE Id =: leadId];
                    
                    // Create a new Account object for the Person Account
                    Account personAccount = new Account();
                    personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                    personAccount.FirstName = orderLead.FirstName;
                    personAccount.LastName = orderLead.LastName;
                    personAccount.INT_email__c = orderLead.Email;
                    personAccount.Phone = orderLead.Phone;
                    personAccount.BillingStreet = orderLead.Street;
                    personAccount.BillingCity = orderLead.City;
                    personAccount.BillingState = orderLead.State;
                    personAccount.BillingPostalCode = orderLead.PostalCode;
                    
                    // Create a new Contact object for the Person Account
                    Contact personAccountContact = new Contact();
                    personAccountContact.FirstName = orderLead.FirstName;
                    personAccountContact.LastName = orderLead.LastName;
                    personAccountContact.Email = orderLead.Email;
                    personAccountContact.Phone = orderLead.Phone;
                    
                    // Convert the Lead into a Person Account
                    Database.LeadConvert leadConvert = new Database.LeadConvert();
                    leadConvert.setLeadId(orderLead.Id);
                    leadConvert.convertedstatus = 'Convertido';
                    leadConvert.setAccountId(personAccount.Id);
                    leadConvert.setContactId(personAccountContact.Id);
                    leadConvert.setDoNotCreateOpportunity(true); // Optionally, prevent creating an Opportunity
                    Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
                    
                    // Verify if the conversion was successful
                    if (leadConvertResult.isSuccess()) {
                        // Retrieve the converted Account and Contact
                        convertedAccount = [SELECT Id, Name FROM Account WHERE Id = :leadConvertResult.getAccountId()];
                        Contact convertedContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :leadConvertResult.getContactId()];
                        System.debug('Lead converted successfully to Person Account: ' + convertedAccount.Name + ', Contact: ' + convertedContact.FirstName + ' ' + convertedContact.LastName);
                    } else {
                        // Handle the conversion error
                        System.debug('Lead conversion failed with the following error: ' + leadConvertResult.getErrors()[0].getMessage());
                    }
                }
            }
            
            if(orderAccount.Id != null){
                System.enqueueJob(new OrderCommerceQueueable(orderAccount.Id, jsonRequestBody));
            }else if(convertedAccount.Id != null){
                System.enqueueJob(new OrderCommerceQueueable(convertedAccount.Id, jsonRequestBody));
            }
            
            response.put('status', 200);
            response.put('message', ('Pedidos correctos: ' + upsertedCount + ', ' + 'Errores: ' + failedCount + ' ' + Errors));
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