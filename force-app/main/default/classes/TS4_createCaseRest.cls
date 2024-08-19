@RestResource(urlMapping='/case/*')
global with sharing class TS4_createCaseRest {
    @HttpPost
    global static void createCase() {
        
        Map<String, String> response = new Map<String, String>();
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonResponse = request.requestBody.toString();
        CaseInput input = (CaseInput) JSON.deserialize(jsonResponse, CaseInput.class);
        Contact con;
        Map<String, String> requiredFields = new Map<String, String>{
            'aliasSinter' => input.aliasSinter,
            'idCuentaEmpresa' => input.idCuentaEmpresa
        };
        for (String fieldName : requiredFields.keySet()) {
            if (String.isBlank(requiredFields.get(fieldName))) {
                response.put('message', 'Error: El campo ' + fieldName + ' es obligatorio.');
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 400;
                return;
            }
        }

        if (String.isBlank(input.correo) && String.isBlank(input.telefono)) {
            response.put('message', 'Error: Debe proporcionar al menos un correo o un contacto de registro.');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 400;
            return;
        }
        List<Contact> contactList = [SELECT Id FROM Contact WHERE TS4_Cost_UsuSinter__c = :input.aliasSinter limit 1];
        
        if (contactList.isEmpty()) {
            con = new Contact();
        } else {
            con = contactList[0];
        }
        con.FirstName=input.nombre;
        con.LastName=input.apellidos;
        con.CurrencyIsoCode='MXN';
        con.Email=input.correo;
        con.TS4_Cost_UsuSinter__c=input.aliasSinter;
        con.title='test';
        con.accountId=input.idCuentaEmpresa;
        con.TS4_Cost_Puesto_de_trabajo__c=input.puesto;
        con.TS4_Cont_idSucursal__c=input.sucursal;
        con.phone=input.telefono;
        upsert con TS4_Cost_UsuSinter__c;
        // Crear caso
        Case newCase = new Case();
        newCase.AccountId =input.idCuentaEmpresa; 
        newCase.ContactId = con.Id;
        newCase.TS4_ContactoRegistro__c = input.telefono;
        newCase.TS4_Correo__c = input.correo;
        newCase.Subject = input.asunto; 
        newCase.Description = input.descripcion; 
        newCase.TS4_ID_de_producto__c = input.producto;
        newCase.TS4_Tipo_de_producto__c = input.descProducto;
        newCase.TS4_Empresa__c = input.descEmpresa;
        newCase.TS4_Sucursal__c = input.sucursal;
        newCase.TS4_Categoria__c = input.categoria;
        newCase.TS4_Subcategoria__c = input.subcategoria;
        newCase.TS4_Subsubcategoria__c = input.detalle;
        newCase.Origin = input.origen;
        newCase.TS4_Numero_de_pedido__c =input.numeroPedido;
        newCase.TS4_Codigos_de_producto__c=input.codigosDeProductos;
        
        Database.SaveResult caseResult = Database.insert(newCase, false);
        if (caseResult.isSuccess()) {
            // Insertar enlaces de documentos si la lista de URLs está presente y no está vacía
            if (input.documentos!=null && !input.documentos.isEmpty()) {
                List<TS4_EnlaceDocumentos__c> documentos = new List<TS4_EnlaceDocumentos__c>();
                for (TS4_createCaseRest.docsWrapper link : input.documentos) {
                    TS4_EnlaceDocumentos__c document = new TS4_EnlaceDocumentos__c();
                    document.URL_Documento__c = link.url;
                    document.TS4_IdCaso__c = newCase.Id;
                    documentos.add(document);
                }
                Database.SaveResult[] docResults = Database.insert(documentos, false);
                // Manejar errores de inserción de documentos
                for (Database.SaveResult docResult : docResults) {
                    if (!docResult.isSuccess()) {
                        for (Database.Error err : docResult.getErrors()) {
                            response.put('message', 'Error al insertar documento: ' + err.getMessage());
                            
                        }
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(response));
                        res.statusCode = 400;
                        return;
                    }
                }
            }
            if (input.comentarios!=null && !input.comentarios.isEmpty()) {
                List<TS4_Comentarios__c> comments = new List<TS4_Comentarios__c>();
                for (TS4_createCaseRest.commentsWrapper comm : input.comentarios) {
                    TS4_Comentarios__c comment = new TS4_Comentarios__c();
                    comment.TS4_Comentario__c = comm.comentario;
                    comment.TS4_IdCaso__c = newCase.Id;
                    comments.add(comment);
                }
                Database.SaveResult[] commentResults = Database.insert(comments, false);

                // Manejar errores de inserción de documentos
                for (Database.SaveResult docResult : commentResults) {
                    if (!docResult.isSuccess()) {
                        for (Database.Error err : docResult.getErrors()) {
                            response.put('message', 'Error al insertar el comentario: ' + err.getMessage());
                        }
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(response));
                        res.statusCode = 400;
                        return;
                    }
                }
            }
            // Obtener y retornar la información del caso
            Case c = [SELECT Id, CaseNumber,ContactId FROM Case WHERE Id = :newCase.Id LIMIT 1];
            response.put('Id', c.Id);
            response.put('CaseNumber', c.CaseNumber);
            response.put('ContactId', c.ContactId);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            return;
        } else {
            response.put('message', 'Error al insertar caso: ' + caseResult.getErrors());
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 400;
            return;
        }
    }
    
    

    @HttpGet
    global static void getCase() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String filterNumeroCaso = req.headers.get('numeroCaso');
        List<String> filters = new List<String>();
        String queryBase='Select Id, TS4_Categoria__c, TS4_Subcategoria__c, TS4_Correo__c, TS4_Nombre_completo__c, Subject, Description, TS4_ID_de_producto__c,CaseNumber,createdDate from Case where caseNumber =:filterNumeroCaso';
        List<Case> lstCases=Database.query(queryBase);
        Map<Id, List<EmailMessage>> caseToEmailsMap = new Map<Id, List<EmailMessage>>();
        //Map<Id, List<LiveChatTranscript>> caseToChatsMap = new Map<Id, List<LiveChatTranscript>>();
        Map<Id, List<TS4_EnlaceDocumentos__c>> caseDocsMap = new Map<Id, List<TS4_EnlaceDocumentos__c>>();
        Map<Id, List<TS4_Comentarios__c>> caseCommentsMap = new Map<Id, List<TS4_Comentarios__c>>();
        if(lstCases.size()>0){
            //List<LiveChatTranscript> lstChats=[Select Body,StartTime,EndTime,CaseId from LiveChatTranscript where CaseId IN:lstCases ORDER BY CreatedDate DESC];
            List<EmailMessage> lstEmails=[Select Subject,TextBody,ToAddress,FromAddress,createdDate,ParentId from EmailMessage where ParentId IN:lstCases ORDER BY CreatedDate DESC];
            List<TS4_EnlaceDocumentos__c> lstdocs=[Select URL_Documento__c,TS4_IdCaso__c from TS4_EnlaceDocumentos__c where TS4_IdCaso__c IN:lstCases ORDER BY CreatedDate DESC];
            List<TS4_Comentarios__c> lstComments=[select TS4_Comentario__c,TS4_IdCaso__c from TS4_Comentarios__c where TS4_IdCaso__c in:lstCases ORDER BY CreatedDate DESC];
            /*if(lstChats.size()>0){
                for (LiveChatTranscript chat : lstChats) {
                    if (!caseToChatsMap.containsKey(chat.CaseId)) {
                        caseToChatsMap.put(chat.CaseId, new List<LiveChatTranscript>());
                    }
                    caseToChatsMap.get(chat.CaseId).add(chat);
                }
            }*/
            if(lstEmails.size()>0){
                for (EmailMessage email : lstEmails) {
                    if (!caseToEmailsMap.containsKey(email.ParentId)) {
                        caseToEmailsMap.put(email.ParentId, new List<EmailMessage>());
                    }
                    caseToEmailsMap.get(email.ParentId).add(email);
                }
            }
            if(lstdocs.size()>0){
                for (TS4_EnlaceDocumentos__c doc : lstdocs) {
                    if (!caseDocsMap.containsKey(doc.TS4_IdCaso__c)) {
                        caseDocsMap.put(doc.TS4_IdCaso__c, new List<TS4_EnlaceDocumentos__c>());
                    }
                    caseDocsMap.get(doc.TS4_IdCaso__c).add(doc);
                }
            }
            if(lstComments.size()>0){
                for (TS4_Comentarios__c com : lstComments) {
                    if (!caseCommentsMap.containsKey(com.TS4_IdCaso__c)) {
                        caseCommentsMap.put(com.TS4_IdCaso__c, new List<TS4_Comentarios__c>());
                    }
                    caseCommentsMap.get(com.TS4_IdCaso__c).add(com);
                }
            }
            caseResponseWrapper caseResponse;
            for (Case caso : lstCases) {
                List<EmailMessage> relatedEmails = caseToEmailsMap.containsKey(caso.Id) ? caseToEmailsMap.get(caso.Id) : new List<EmailMessage>();
                //List<LiveChatTranscript> relatedChats = caseToChatsMap.containsKey(caso.Id) ? caseToChatsMap.get(caso.Id) : new List<LiveChatTranscript>();
                List<TS4_EnlaceDocumentos__c> relatedDocs = caseDocsMap.containsKey(caso.Id) ? caseDocsMap.get(caso.Id):new List<TS4_EnlaceDocumentos__c>();
                List<TS4_Comentarios__c> relatedComments = caseCommentsMap.containsKey(caso.Id) ? caseCommentsMap.get(caso.Id):new List<TS4_Comentarios__c>();
                caseResponse = new caseResponseWrapper(relatedEmails, /*relatedChats,*/relatedDocs,relatedComments,caso );
               
            }
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(caseResponse));
            res.statusCode = 200;
        }else{
            Map<String,String> mapRes=new Map<String,String>();
            mapRes.put('message','este caso no existe,favor de verificar los datos');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(mapRes));
            res.statusCode = 404;
        }
    }

    @HttpPatch
    global static void updateCase() {
        Map<String,String> response = new Map<String,String>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String filterNumCase = req.headers.get('numeroCaso');
        String jsonResponse = req.requestBody.toString();
        CaseInputUpdate input = (CaseInputUpdate) JSON.deserialize(jsonResponse, CaseInputUpdate.class);
        
        List<Case> casos = [SELECT Id FROM Case WHERE CaseNumber = :filterNumCase LIMIT 1];
        if (!casos.isEmpty()) {
            Case caso = casos[0];
            
            if (input.documentos != null && !input.documentos.isEmpty()) {
                List<TS4_EnlaceDocumentos__c> documentos = new List<TS4_EnlaceDocumentos__c>();
                for (TS4_createCaseRest.docsWrapper link : input.documentos) {
                    TS4_EnlaceDocumentos__c document = new TS4_EnlaceDocumentos__c();
                    document.URL_Documento__c = link.url;
                    document.TS4_IdCaso__c = caso.Id;
                    documentos.add(document);
                }
                Database.SaveResult[] docResults = Database.insert(documentos, false);
                
                for (Database.SaveResult docResult : docResults) {
                    if (!docResult.isSuccess()) {
                        for (Database.Error err : docResult.getErrors()) {
                            response.put('message', 'Error al insertar documento: ' + err.getMessage());
                        }
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(response));
                        res.statusCode = 400;
                        return;
                    }
                }
            }
            
            if (input.comentarios != null && !input.comentarios.isEmpty()) {
                List<TS4_Comentarios__c> comments = new List<TS4_Comentarios__c>();
                for (TS4_createCaseRest.commentsWrapper comm : input.comentarios) {
                    TS4_Comentarios__c comment = new TS4_Comentarios__c();
                    comment.TS4_Comentario__c = comm.comentario;
                    comment.TS4_IdCaso__c = caso.Id;
                    comments.add(comment);
                }
                Database.SaveResult[] commentResults = Database.insert(comments, false);
                
                for (Database.SaveResult commentResult : commentResults) {
                    if (!commentResult.isSuccess()) {
                        for (Database.Error err : commentResult.getErrors()) {
                            response.put('message', 'Error al insertar el comentario: ' + err.getMessage());
                        }
                        res.addHeader('Content-Type', 'application/json');
                        res.responseBody = Blob.valueOf(JSON.serialize(response));
                        res.statusCode = 400;
                        return;
                    }
                }
            }
            
            response.put('message', 'El registro numero de caso ' + filterNumCase + ' actualizado correctamente');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
        } else {
            response.put('message', 'Número de caso no encontrado favor de validar el dato ingresado');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 404;
        }
    }

    // Clase interna para mapear el JSON de entrada
    global class CaseInput {
        public string idCuentaEmpresa;
        public string aliasSinter;
        public string telefono;
        public string correo;
        public string asunto;
        public string descripcion;
        public String producto;
        public String DescProducto;
        public string descEmpresa;
        public string sucursal;
        public string puesto;
        public string categoria;
        public string subcategoria;
        public string detalle;
        public string origen;
        public string nombre;
        public string apellidos;
        public string numeroPedido;
        public string codigosDeProductos;
        public List<docsWrapper> documentos;
        public List<commentsWrapper> comentarios;
    }
    global class CaseInputUpdate {
        public List<docsWrapper> documentos;
        public List<commentsWrapper> comentarios;
    }
    global class docsWrapper {
        public string url;
    }
    global class commentsWrapper {
        public string comentario;
    }

    public class caseResponseWrapper {
        public Case caso;
        public List<EmailMessage> lstEmail;
        //public List<LiveChatTranscript> lstChat;
        public list<TS4_EnlaceDocumentos__c> lstDocs;
        public list<TS4_Comentarios__c> lstComments;
        // Constructor
        public caseResponseWrapper(List<EmailMessage> lstEmail, /*List<LiveChatTranscript> lstChat,*/list<TS4_EnlaceDocumentos__c> lstDocs,List<TS4_Comentarios__c> lstComments,Case caso) {
            this.caso = caso;
            this.lstEmail = lstEmail;
            //this.lstChat = lstChat;
            this.lstComments = lstComments;
            this.lstDocs=lstDocs;
        }
    }
}