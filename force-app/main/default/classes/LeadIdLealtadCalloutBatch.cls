public class LeadIdLealtadCalloutBatch implements Database.Batchable<Lead>, Database.AllowsCallouts {
    private List<Lead> leadsToUpdate;

    public LeadIdLealtadCalloutBatch(List<Lead> leadToUpdate) {
        this.leadsToUpdate = leadToUpdate;
    }

    public Iterable<Lead> start(Database.BatchableContext bc) {
        // Return the list of accounts to be processed
        return leadsToUpdate;
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        Map<String, Lead> mapleadsToUpdateInBatch = new Map<String, Lead>(); // Collect updated Leads in this list
        List<String> listLeadLastName = new List<String>();
        List<Decimal> listLeadIdLealtad = new List<Decimal>();
        List<Lead> listToUpdate = new List<Lead>();
        List<Lead> listLeads = new List<Lead>();

        for (Lead iLead : scope) {
            System.debug(iLead);
            if(iLead.Id != null){
                listLeads.add(iLead);
            }
            listLeadLastName.add(iLead.LastName);
            listLeadIdLealtad.add(iLead.INT_Id_Interface__c);
            makeCalloutAndUpdateLead(iLead, mapleadsToUpdateInBatch);
        }
		
        if(listLeads.isEmpty()){
            for(Lead iLead : [SELECT Id, LastName, INT_Id_Interface__c 
                              FROM Lead 
                              WHERE LastName IN: listLeadLastName 
                              AND INT_Id_Interface__c IN: listLeadIdLealtad])
            {
                iLead.INT_Validez_Id_Lealtad__c = mapleadsToUpdateInBatch.get(iLead.LastName + ' ' + String.ValueOf(iLead.INT_Id_Interface__c)) != null ? mapleadsToUpdateInBatch.get(iLead.LastName + ' ' + String.ValueOf(iLead.INT_Id_Interface__c)).INT_Validez_Id_Lealtad__c : null;
                listToUpdate.add(iLead);
            }
        }else{
            for(Lead iLead : listLeads){
                iLead.INT_Validez_Id_Lealtad__c = mapleadsToUpdateInBatch.get(iLead.LastName + ' ' + String.ValueOf(iLead.INT_Id_Interface__c)) != null ? mapleadsToUpdateInBatch.get(iLead.LastName + ' ' + String.ValueOf(iLead.INT_Id_Interface__c)).INT_Validez_Id_Lealtad__c : null;
                listToUpdate.add(iLead);
            }
        }
        
        // Perform DML operation to update the Leads in the batch
        if (!listToUpdate.isEmpty()) {
            update listToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Perform any post-processing if needed
    }
    
    // Implement your callout logic here
    public void makeCalloutAndUpdateLead(Lead iLead, Map<String, Lead> mapleadsToUpdateInBatch) {
        idLealtad iLealtad = new idLealtad();
        iLealtad.id_lealtad = iLead.INT_Id_Interface__c;
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
                iLead.INT_Validez_Id_Lealtad__c = sMensajeValido != null ? sMensajeValido : null;
                mapleadsToUpdateInBatch.put(iLead.LastName + ' ' + String.ValueOf(iLead.INT_Id_Interface__c), iLead);
            }else if(sResultado == 'NOT OK'){
                String sError = (String) data.get('ERROR');
                iLead.INT_Validez_Id_Lealtad__c = sError != null ? sError : null;
                mapleadsToUpdateInBatch.put(iLead.LastName + ' ' + String.ValueOf(iLead.INT_Id_Interface__c), iLead);
            }
        } catch (Exception ex) {
            System.debug('makeCalloutAndUpdateLead:ERROR: ' + ex.getMessage());
            // Handle any exceptions that may occur during the callout
            // For example, log the error or perform appropriate error handling
        }
    }

    public class idLealtad {
        public decimal id_lealtad;
    }
}