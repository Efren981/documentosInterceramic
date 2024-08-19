@RestResource(urlMapping='/getOpportunityEspcMega/*')
global class OpportunityEspcMegaRestResource {

    @HttpPost
    global static void getOpportunity() {
         Map<String, Object> response = new Map<String, Object>();
        
        RestRequest request = RestContext.request;
        String jsonInput = request.requestBody.toString();
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        
        Decimal Empnum = (Decimal) data.get('Empnum');
        String Nombre_Oportunidad = (String) data.get('Nombre_Oportunidad');
        String Ejecutivo = (String) data.get('Ejecutivo');
        String Cuenta = (String) data.get('Cuenta');
        String Paisclave = (String) data.get('Paisclave');
        Decimal Entfednum = (Decimal) data.get('Entfednum');
        Decimal Mponum = (Decimal) data.get('Mponum');
        String IdConvenio = (String) data.get('IdConvenio');
        
        Oportunidades Oportunidad = new Oportunidades();
        //List<Megaproyectos> lstMega = new List<Megaproyectos>();
        List<Espeficicaciones> lstEspc = new List<Espeficicaciones>();
        List<Opportunity> listOpportunityQuery = new List<Opportunity>();
        
        System.debug(Nombre_Oportunidad);
        System.debug(Ejecutivo);
        System.debug(Cuenta);
        
        if(Nombre_Oportunidad != '' && Ejecutivo != '' && Cuenta != ''){
            String sNombreOpp = '%' + Nombre_Oportunidad + '%';
            String sEjecutivo = '%' + Ejecutivo + '%';
            String sCuenta = '%' + Cuenta + '%';
            
            listOpportunityQuery = [SELECT Id, Name, Owner.Name, INT_Pais__r.INT_PaisClave__c, RecordType.DeveloperName,
                                    INT_Estado__r.INT_EntFedNum__c, INT_NumeroMunicipio__c, Account.Name, INT_Id_Convenio__c
                                    FROM Opportunity 
                                    WHERE Name LIKE: sNombreOpp AND Owner.Name LIKE: sEjecutivo
                                    AND Account.Name LIKE: sCuenta AND INT_Pais__r.INT_PaisClave__c =: Paisclave
                                    AND INT_Estado__r.INT_EntFedNum__c =: Entfednum AND INT_NumeroMunicipio__c =: Mponum
                                    AND INT_Numero_Franquicia__c =: Empnum /*AND StageName = 'Acuerdo / Convenio'*/
                                    /*AND (RecordType.DeveloperName = 'Megaproyectos' OR RecordType.DeveloperName = 'Especificaciones')*/];
        }
        
        if(Empnum != null || IdConvenio != null){
            listOpportunityQuery = [SELECT Id, Name, Owner.Name, INT_Pais__r.INT_PaisClave__c, RecordType.DeveloperName,
                                    INT_Estado__r.INT_EntFedNum__c, INT_NumeroMunicipio__c, Account.Name, INT_Id_Convenio__c
                                    FROM Opportunity 
                                    WHERE (INT_Numero_Franquicia__c =: Empnum OR INT_Id_Convenio__c =: IdConvenio)/*AND StageName = 'Acuerdo / Convenio'*/
                                    /*AND (RecordType.DeveloperName = 'Megaproyectos' OR RecordType.DeveloperName = 'Especificaciones')*/];
        }
        
        for(Opportunity iOpp : listOpportunityQuery)
        {
            /*if(iOpp.RecordType.DeveloperName == 'Megaproyectos'){
                Megaproyectos mega = new Megaproyectos();
                mega.id_oportunidad = iOpp.id;
                mega.nombre_oportunidad = iOpp.Name;
                mega.ejecutivo = iOpp.Owner.Name;
                mega.paisclave = iOpp.INT_Pais__r.INT_PaisClave__c;
                mega.entfednum = iOpp.INT_Estado__r.INT_EntFedNum__c;
                mega.mponum = iOpp.INT_NumeroMunicipio__c;
                mega.nombre_cuenta = iOpp.Account.Name;
                lstMega.add(mega);
            }*/
            
            if(iOpp.RecordType.DeveloperName == 'Especificaciones'){
                Espeficicaciones espc = new Espeficicaciones();
                espc.id_oportunidad = iOpp.id;
                espc.nombre_oportunidad = iOpp.Name;
                espc.ejecutivo = iOpp.Owner.Name;
                espc.paisclave = iOpp.INT_Pais__r.INT_PaisClave__c;
                espc.entfednum = iOpp.INT_Estado__r.INT_EntFedNum__c;
                espc.mponum = iOpp.INT_NumeroMunicipio__c;
                espc.nombre_cuenta = iOpp.Account.Name;
                espc.id_convenio = iOpp.INT_Id_Convenio__c;
                lstEspc.add(espc);
            }
        }
        
        //Oportunidad.listMegaproyectos = lstMega;
        Oportunidad.listEspeficicaciones = lstEspc;
        
        response.put('Opportunity', Oportunidad);
        if(/*lstMega.isEmpty() && */ lstEspc.isEmpty()){
            response.put('message', 'No se ha encontrado una oportunidad del tipo Especificaciones o Megaproyectos con los datos proporcionados');
        }
        String jsonString = JSON.serialize(response);
        
        if(!test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonString);
        }
    }
    
    Public Class Oportunidades {
        //List<Megaproyectos> listMegaproyectos;
        List<Espeficicaciones> listEspeficicaciones;
    }
    
    /*Public Class Megaproyectos {
        String id_oportunidad;
       	String nombre_oportunidad;
        String ejecutivo;
        String paisclave;
        Decimal entfednum;
        Decimal mponum;
        String nombre_cuenta;
    }*/
    
     Public Class Espeficicaciones {
        String id_oportunidad;
       	String nombre_oportunidad;
        String ejecutivo;
        String paisclave;
        Decimal entfednum;
        Decimal mponum;
        String nombre_cuenta;
        String id_convenio;
    }
}