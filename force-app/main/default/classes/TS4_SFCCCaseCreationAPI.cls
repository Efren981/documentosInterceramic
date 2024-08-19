/************************************************************************
Name: TS4_SFCCCaseCreationAPI
Copyright © 2024 Salesforce
========================================================================
Purpose:
Class used to create the rest service for case creation in B2C.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      jbautista@ts4.mx     18/07/2024     INITIAL    
************************************************************************/

@RestResource(urlMapping='/TS4_SFCCCaseCreationAPI/*')
global with sharing class TS4_SFCCCaseCreationAPI {
    
    @HttpPost
    global static ResponseWrapper createCaseWithAttachments() {
        ResponseWrapper response = new ResponseWrapper();
        RestRequest request = RestContext.request;
        String jsonResponse = request.requestBody.toString();
        BodyWrapper apiRequestFields = (BodyWrapper) JSON.deserialize(jsonResponse, BodyWrapper.class);
        
        if (String.isBlank(apiRequestFields.email) && String.isBlank(apiRequestFields.contactPhone)) {
            response.success = false;
            response.message = 'Error: At least one contact email or phone is required.';
            return response;
        }
        
        try {
            List<Contact> emailContacts = new List<Contact>();
            
            Contact contactIdSf = fetchContactById(apiRequestFields.clientServiceId);
            
            if (contactIdSf == null) emailContacts = fetchContactsByEmail(apiRequestFields.email);
            
            Contact agentContact = fetchContactByAlias(apiRequestFields.aliasSinter);
            RecordType caseRecordType = getRecordType(apiRequestFields.category);
            
            Case newCase = new Case();
            newCase.TS4_Tipo_de_cliente__c = apiRequestFields.clientType;
            newCase.TS4_Nombre_completo__c = apiRequestFields.name;
            newCase.TS4_Correo__c = apiRequestFields.email;
            newCase.TS4_ContactoRegistro__c = apiRequestFields.contactPhone;
            newCase.Subject = apiRequestFields.subject;
            newCase.TS4_Ticket__c = apiRequestFields.ticket;
            newCase.TS4_Categoria__c = apiRequestFields.category;
            newCase.TS4_Subcategoria__c = apiRequestFields.subcategory;
            newCase.Description = apiRequestFields.description;
            newCase.TS4_SFCC_Estado__c = apiRequestFields.state;
            newCase.TS4_SFCC_Municipio__c = apiRequestFields.municipality;
            newCase.Origin = apiRequestFields.origin;
            newCase.RecordTypeId = caseRecordType.Id;
            
            //Asignar el Contacto cuando viene el Id de Salesforce.
            if (contactIdSf != null) newCase.ContactId = contactIdSf.Id; 
            
            //Asignar el Contacto cuando viene el correo y no el Id de Salesforce
            if (emailContacts.size() == 1) newCase.ContactId = emailContacts[0].Id;
            
            //Contacto agente
            if (agentContact != null) newCase.TS4_Agente_Franquicia_Atendio__c = agentContact.Id;
            
            insert newCase;
            
            String caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id LIMIT 1].CaseNumber;
            
            if (apiRequestFields.documents != null && !apiRequestFields.documents.isEmpty()) {
                List<TS4_EnlaceDocumentos__c> documents = new List<TS4_EnlaceDocumentos__c>();
                for (TS4_SFCCCaseCreationAPI.docsWrapper link : apiRequestFields.documents) {
                    TS4_EnlaceDocumentos__c document = new TS4_EnlaceDocumentos__c();
                    document.URL_Documento__c = link.url;
                    document.TS4_IdCaso__c = newCase.Id;
                    documents.add(document);
                }
                
                Database.SaveResult[] saveResults = Database.insert(documents, false);
                
                for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                        System.debug('Documento insertado exitosamente con Id: ' + sr.getId());
                    } else {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error al insertar documento con Id: ' + sr.getId() + ' - ' + err.getMessage());
                        }
                    }
                }
            } else {
                System.debug('No hay documentos para insertar para el caso: ' + newCase.Id);
            }
            
            response.success = true;
            response.caseId = newCase.Id;
            response.caseNumber = caseNumber;
            response.message = 'Case created successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error: ' + e.getMessage();
        }
        
        return response;
    }
    
    /*
* nombre: fetchContactById
* descripcion: Obtener el contacto, dependiendo del Id de SF.
* parametros:
* id -> String
*/
    
    private static Contact fetchContactById(String id) {
        Contact contact = null;
        
        if (String.isNotBlank(id) && id.length() == 15 || id.length() == 18) {
            try {
                contact = [SELECT Id FROM Contact WHERE Id = :id LIMIT 1];
            } catch (QueryException e) {
                System.debug('QueryException: No se encontró un contacto con el ID proporcionado o la consulta falló. ID: ' + id + '. Error: ' + e.getMessage());
            } catch (Exception e) {
                System.debug('Exception: Error al buscar contacto. ID: ' + id + '. Error: ' + e.getMessage());
            }
        } else {
            System.debug('Invalid ID format: ' + id);
        }
        return contact;
    }
    
    /*
* nombre: fetchContactByAlias
* descripcion: Obtener el contacto, dependiendo del alias Sinter.
* parametros:
* aliasSinter -> String
*/
    
    private static Contact fetchContactByAlias(String aliasSinter) {
        Contact contact = null;
        if (String.isNotBlank(aliasSinter)) {
            try {
                contact = [SELECT Id FROM Contact WHERE TS4_Cost_UsuSinter__c = :aliasSinter LIMIT 1];
            } catch (QueryException e) {
                System.debug('QueryException: No se encontró un contacto con el alias Sinter proporcionado o la consulta falló.: ' + aliasSinter + '. Error: ' + e.getMessage());
            } catch (Exception e) {
                System.debug('Exception: Error al buscar contacto : ' + aliasSinter + '. Error: ' + e.getMessage());
            }
        }
        return contact;
    }
    
    /*
* nombre: fetchContactsByEmail
* descripcion: Obtener el contacto, dependiendo del mail.
* parametros:
* email -> String
*/
    private static List<Contact> fetchContactsByEmail(String email) {
        if (String.isNotBlank(email)) {
            return [SELECT Id, Email, AccountId FROM Contact WHERE Email = :email];
        }
        return new List<Contact>();
    }
    
    /*
* nombre: getRecordType
* descripcion: Obtener el recordtype, dependiendo de la categoría.
* parametros:
* category -> String
*/
    
    private static RecordType getRecordType(String category) {
        String recordTypeName = category == 'Garantías' ? 'Garantía' : 'Ventas';
        return [SELECT Id FROM RecordType WHERE Name = :recordTypeName LIMIT 1];
    }
    
    global class ResponseWrapper {
        global Boolean success;
        global Id caseId;
        global String message;
        global String caseNumber;
    }
    
    // Clase interna para mapear el JSON de entrada
    global class BodyWrapper {
        global String clientServiceId;
        global String aliasSinter;
        global String clientType;
        global String name;
        global String email;
        global String contactPhone;
        global String subject;
        global String ticket;
        global String category;
        global String subcategory;
        global String description;
        global String state;
        global String municipality;
        global String origin;
        public List<docsWrapper> documents;
    }
    
    global class docsWrapper {
        public string url;
    }
}