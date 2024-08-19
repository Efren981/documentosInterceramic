@RestResource(urlMapping='/updateContact')
global with sharing class TS4_UpdateContactRest {
    @HttpPut
    global static void updateContact() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonResponse = request.requestBody.toString();
        Map<String,Object> input =(Map<String,Object>)JSON.deserializeUntyped(jsonResponse);
        List<Object> lstIdSinterObj=(List<Object>) input.get('idSinter');
        List<String> lstIdSinter=new List<String>();
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Map<String, Object>> updatedMap = new List<Map<String, Object>>();
        List<String> errors = new List<String>();
        for (Object idSinter : lstIdSinterObj) {
            lstIdSinter.add((String) idSinter);
        }
        
        List<Contact> lstContact=[Select id,TS4_isActive__c,name from contact where TS4_Cost_UsuSinter__c in:lstIdSinter];
        List<Contact> lstContactUpdate=new List<Contact>();
        List<String> messages = new List<String>();
        for(Contact con:lstContact){
            if(con.TS4_isActive__c){
                con.TS4_isActive__c=false;
                lstContactUpdate.add(con);
            }else{
                messages.add('Contacto con nombre ' + con.name + ' ya está inactivo.');
            }
        }
        if (!lstContactUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(lstContactUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                Contact contact = lstContactUpdate[i];
                if (result.isSuccess()) {
                    Map<String, Object> contactInfo = new Map<String, Object>{
                        'isActive' => contact.TS4_isActive__c,
                        'Id' => result.getId()
                    };
                    updatedMap.add(contactInfo);
                } /*else {
                    // Maneja los errores y agrega el mensaje a responseMap
                    String errorMessage = 'Error al actualizar el contacto: ';
                    for (Database.Error err : result.getErrors()) {
                        errorMessage += err.getMessage();
                    }
                    errors.add(errorMessage);
                }*/
            }
        }
        if (!messages.isEmpty()) {
            responseMap.put('messages', messages);
            res.statusCode = 200;
        }
        if (!updatedMap.isEmpty()) {
            responseMap.put('success', updatedMap);
            res.statusCode = 200;
        }
        /*if (!errors.isEmpty()) {
            responseMap.put('errors', errors);
            res.statusCode = 200;
        }*/
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }
}