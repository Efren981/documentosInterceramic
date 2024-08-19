public class ContactIdLealtadCalloutBatch implements Database.Batchable<Contact>, Database.AllowsCallouts {
    private List<Contact> contactsToUpdate;
    
    public ContactIdLealtadCalloutBatch(List<Contact> contactToUpdate) {
        this.contactsToUpdate = contactToUpdate;
    }
    
    public Iterable<Contact> start(Database.BatchableContext bc) {
        // Return the list of accounts to be processed
        return contactsToUpdate;
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        Map<String, Contact> mapleadsToUpdateInBatch = new Map<String, Contact>(); // Collect updated Contacts in this list
        List<String> listContactLastName = new List<String>();
        List<Decimal> listContactIdLealtad = new List<Decimal>();
        List<Contact> listToUpdate = new List<Contact>();
        List<Contact> listContacts = new List<Contact>();
        
        for (Contact iContact : scope) {
            System.debug(iContact);
            if(iContact.Id != null){
                listContacts.add(iContact);
            }
            listContactLastName.add(iContact.LastName);
            listContactIdLealtad.add(iContact.INT_Id_Interface__c);
            makeCalloutAndUpdateContact(iContact, mapleadsToUpdateInBatch);
        }
        
        System.debug('mapleadsToUpdateInBatch ' + mapleadsToUpdateInBatch);
        if(listContacts.isEmpty()){
            for(Contact iContact : [SELECT Id, LastName, INT_Id_Interface__c 
                                    FROM Contact 
                                    WHERE LastName IN: listContactLastName 
                                    AND INT_Id_Interface__c IN: listContactIdLealtad])
            {
                iContact.INT_Validez_Id_Lealtad__c = mapleadsToUpdateInBatch.get(iContact.LastName + ' ' + String.ValueOf(iContact.INT_Id_Interface__c)) != null ? mapleadsToUpdateInBatch.get(iContact.LastName + ' ' + String.ValueOf(iContact.INT_Id_Interface__c)).INT_Validez_Id_Lealtad__c : null;
                if(iContact.INT_Validez_Id_Lealtad__c == 'El ID de la Cuenta INTERPASS no es válido'){
                    iContact.INT_Id_Interface__c = null;
                }
                listToUpdate.add(iContact);
            }
        }else{
            for(Contact iContact : listContacts){
                iContact.INT_Validez_Id_Lealtad__c = mapleadsToUpdateInBatch.get(iContact.LastName + ' ' + String.ValueOf(iContact.INT_Id_Interface__c)).INT_Validez_Id_Lealtad__c;
                if(iContact.INT_Validez_Id_Lealtad__c == 'El ID de la Cuenta INTERPASS no es válido'){
                    iContact.INT_Id_Interface__c = null;
                }
                listToUpdate.add(iContact);
            }
        }
        
        // Perform DML operation to update the Contacts in the batch
        if (!listToUpdate.isEmpty()) {
            update listToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing if needed
    }
    
    // Implement your callout logic here
    public void makeCalloutAndUpdateContact(Contact iContact, Map<String, Contact> mapleadsToUpdateInBatch) {
        idLealtad iLealtad = new idLealtad();
        iLealtad.id_lealtad = iContact.INT_Id_Interface__c;
        String requestBody = JSON.serialize(iLealtad);
        
        HttpResponse response = new HttpResponse();
        
        try {
            response = WS_Interceramic.getIdLealtad(requestBody);
            String body = response.getBody();
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(body);
            String sResultado = (String) data.get('RESULTADO');
            String sNombre = (String) data.get('NOMBRE');
            String sApellido = (String) data.get('APELLIDO');
            String sNivel = (String) data.get('NIVEL');
            String sEstatus = (String) data.get('ESTATUS');
            String sMensajeValido = (String) data.get('MENSAJEIDVALIDO');
            String sMensajeIdActualizado = (String) data.get('MENSAJEIDACTUALIZADO');
            
            if(sResultado == 'OK'){
                iContact.INT_Validez_Id_Lealtad__c = sMensajeValido != null ? sMensajeValido : null;
                mapleadsToUpdateInBatch.put(iContact.LastName + ' ' + String.ValueOf(iContact.INT_Id_Interface__c), iContact);
            }else if(sResultado == 'NOT OK'){
                String sError = (String) data.get('ERROR');
                iContact.INT_Validez_Id_Lealtad__c = sError != null ? sError : null;
                mapleadsToUpdateInBatch.put(iContact.LastName + ' ' + String.ValueOf(iContact.INT_Id_Interface__c), iContact);
            }
        } catch (Exception ex) {
            // Handle any exceptions that may occur during the callout
            // For example, log the error or perform appropriate error handling
        }
    }
    
    public class idLealtad {
        public decimal id_lealtad;
    }
}