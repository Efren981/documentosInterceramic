@RestResource(urlMapping='/createPersonAccounts/*')
global with sharing class TS4_CreatePersonAccountsRest {
    @HttpPost
    global static void createAccount() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        
        Map<String, Object> responseMap = new Map<String, Object>{
            'errors' => new List<Map<String, String>>(),
            'updated' => new List<Map<String, String>>(),
            'created' => new List<Map<String, String>>()
        };
        
        try {
            String jsonResponse = request.requestBody.toString();
            System.debug('Received JSON: ' + jsonResponse);
            
            TS4_ClienteWrapper inputClientes = TS4_ClienteWrapper.deserializeJson(jsonResponse);
            System.debug('Deserialized Clientes: ' + inputClientes);
            
            if (inputClientes == null || inputClientes.Clientes == null || inputClientes.Clientes.isEmpty()) {
                throw new CustomException('No se recibieron datos de clientes válidos');
            }
            
            String rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Cliente Final' LIMIT 1].Id;
            
            List<Account> accountsToUpsert = new List<Account>();
            
            for (TS4_ClienteWrapper.Cliente input : inputClientes.Clientes) {
                Account personAccount = new Account(
                    RecordTypeId = rt,
                    CustomerIdExternal__c = input.customerNumber
                );
                
                try {
                    // Asignar campos uno por uno para capturar errores de tipo específicos
                    personAccount.FirstName = input.Nombres;
                    personAccount.LastName = input.Apellidos;
                    personAccount.INT_email__c = input.Correo;
                    personAccount.INT_CP_Fiscal__pc = input.fiscalCode;
                    personAccount.INT_Calle__pc = input.Calle;
                    personAccount.TS4_Cont_Numero_de_casa__pc = input.Numero_Exterior;
                    personAccount.INT_NumInt__pc = input.Numero_Interior;
                    personAccount.Phone = input.Telefono;
                    personAccount.INT_Entre_Calles__pc = input.Entre_que_calles;
                    personAccount.TS4_Lugar__c = input.Ubicacion?.Lugar;
                    personAccount.TS4_Estacionamiento__c = input.Ubicacion?.Estacionamiento;
                    personAccount.TS4_Distancia_aproximada__c = input.Ubicacion?.Distancia_aproximada;
                    personAccount.TS4_Distancia_entrada__c = input.Ubicacion?.Distancia_entrada;
                    personAccount.TS4_Piso_de_entrega__c = input.Ubicacion?.Piso_de_entrega;
                    personAccount.TS4_Desnivel__c = input.Ubicacion?.Desnivel;
                    personAccount.TS4_Rampa__c = input.Ubicacion?.Rampa;
                    personAccount.TS4_Por_donde_se_subira_el_material__c = input.Ubicacion?.Por_donde_se_subira_el_material;
                    personAccount.TS4_Escaleras__c = input.Ubicacion?.Escaleras;
                    
                    accountsToUpsert.add(personAccount);
                } catch (System.TypeException e) {
                    Map<String, String> errorMap = new Map<String, String>{
                        'customerIdExternal' => input.customerNumber,
                        'message' => 'Error de tipo de datos: ' + e.getMessage()
                    };
                    ((List<Map<String, String>>)responseMap.get('errors')).add(errorMap);
                } catch (Exception e) {
                    Map<String, String> errorMap = new Map<String, String>{
                        'customerIdExternal' => input.customerNumber,
                        'message' => 'Error al preparar cuenta para upsert: ' + e.getMessage()
                    };
                    ((List<Map<String, String>>)responseMap.get('errors')).add(errorMap);
                }
            }
            
            System.debug('Accounts to upsert: ' + accountsToUpsert.size());
            
            if (!accountsToUpsert.isEmpty()) {
                List<Database.UpsertResult> upsertResults = Database.upsert(accountsToUpsert, Account.CustomerIdExternal__c, false);
                
                for (Integer i = 0; i < upsertResults.size(); i++) {
                    Database.UpsertResult result = upsertResults[i];
                    Account account = accountsToUpsert[i];
                    if (result.isSuccess()) {
                        Map<String, String> accountInfo = new Map<String, String>{
                            'customerIdExternal' => account.CustomerIdExternal__c,
                            'salesforceId' => result.getId()
                        };
                        if (result.isCreated()) {
                            ((List<Map<String, String>>)responseMap.get('created')).add(accountInfo);
                        } else {
                            ((List<Map<String, String>>)responseMap.get('updated')).add(accountInfo);
                        }
                    } else {
                        for (Database.Error err : result.getErrors()) {
                            Map<String, String> errorMap = new Map<String, String>{
                                'customerIdExternal' => account.CustomerIdExternal__c,
                                'message' => 'Error al upsert cuenta: ' + err.getMessage()
                            };
                            ((List<Map<String, String>>)responseMap.get('errors')).add(errorMap);
                        }
                    }
                }
            }
            
            System.debug('Response Map: ' + responseMap);
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage() + '\n' + e.getStackTraceString());
            Map<String, String> errorMap = new Map<String, String>{
                'message' => 'Error inesperado: ' + e.getMessage()
            };
            ((List<Map<String, String>>)responseMap.get('errors')).add(errorMap);
        }
        
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        res.statusCode = 200;
    }
    
    public class CustomException extends Exception {}
}