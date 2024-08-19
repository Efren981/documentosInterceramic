@RestResource(urlMapping='/updateWarranty')
global with sharing class TS4_EBSDistamenCaso {
    @HttpPut
    global static void updateContact() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonRequest = request.requestBody.toString();
        Warranty input = (Warranty) JSON.deserialize(jsonRequest, Warranty.class);
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Map<String, Object>> updatedMap = new List<Map<String, Object>>();
        //Paso 1 extraer los id de productos y del caso
        //String caseId=input.caso.Id;
        Set<Id> setIdsProductos=new Set<Id>();
        Map<String,TS4_EBSDistamenCaso.productWrapper> mapProductos=new Map<String,TS4_EBSDistamenCaso.productWrapper>();
        for(TS4_EBSDistamenCaso.productWrapper prod:input.caso.productos){
            setIdsProductos.add(prod.id);
            mapProductos.put(prod.Id,prod);
        }
        //Paso 2 consultar los productos
        List<TS4_Producto_del_ticket__c> lstProductsTicket=[Select id,TS4_Dictamen__c,TS4_Comentario_Asesor_Experto__c from TS4_Producto_del_ticket__c where id in:setIdsProductos];
        
        //Paso 3 asignar valores
        for(TS4_Producto_del_ticket__c productTicket:lstProductsTicket){
            productTicket.TS4_Dictamen__c=mapProductos.get(productTicket.Id).dictamen;
            productTicket.TS4_Comentario_Asesor_Experto__c=mapProductos.get(productTicket.Id).comentario_asesor;
        }

        //paso 4 actualizar y enviar res(si es requerido)
        Database.SaveResult[] updateResults = Database.update(lstProductsTicket, false);
        for (Integer i = 0; i < updateResults.size(); i++) {
            Database.SaveResult result = updateResults[i];
            TS4_Producto_del_ticket__c productTicket = lstProductsTicket[i];
            if (result.isSuccess()) {
                Map<String, Object> productInfo = new Map<String, Object>{
                    'Id' => result.getId(),
                    'TS4_Dictamen__c' => productTicket.TS4_Dictamen__c,
                    'TS4_Comentario_Asesor_Experto__c'=>productTicket.TS4_Comentario_Asesor_Experto__c
                };
                updatedMap.add(productInfo);
            } /*else {
                // Maneja los errores y agrega el mensaje a responseMap
                String errorMessage = 'Error al actualizar el contacto: ';
                for (Database.Error err : result.getErrors()) {
                    errorMessage += err.getMessage();
                }
                errors.add(errorMessage);
            }*/
        }

        if (!updatedMap.isEmpty()) {
            responseMap.put('success', updatedMap);
            res.statusCode = 200;
        }
        /*if (!messages.isEmpty()) {
            responseMap.put('success', messages);
            res.statusCode = 200;
        }*/

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }



    public class Warranty {
        public caseWrapper caso;
    }
    
    public class caseWrapper {
        public String Id;
        public List<productWrapper> productos;
        
    }
    public class productWrapper{
        public String Id;
        public String comentario_asesor;
        public String dictamen;
        public String url_pdf_dictamen;
    } 
}