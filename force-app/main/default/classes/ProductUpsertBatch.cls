/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-28-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-20-2023   emeza@freewayconsulting.com   Initial Version
**/
public class ProductUpsertBatch implements Database.Batchable<Product2>, Database.Stateful, Database.AllowsCallouts {
    private String jsonRequestBody;
    private Integer upsertedCount;
    private Integer failedCount;
    private String batchErrors;
    public List<Product> listProduct = new List<Product>();
    
    public ProductUpsertBatch(String jsonRequestBody) {
        this.jsonRequestBody = jsonRequestBody;
        this.upsertedCount = 0;
        this.failedCount = 0;
        this.batchErrors = '';
        listProduct = new List<Product>();
    }
    
    public Iterable<Product2> start(Database.BatchableContext bc) {
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonRequestBody);
        List<Object> products = (List<Object>) parsedJson.get('PRODUCTOS');
        
        List<Product2> productRecords = new List<Product2>();
        for (Object product : products) {
            Map<String, Object> productMap = (Map<String, Object>) product;
            
            Product2 p = new Product2();
            p.ProductCode = (String) productMap.get('ARTCLAVE');
            p.INT_External_Id__c = (String) productMap.get('ARTCLAVE');
            p.ARTNUM_COMPLETO__c = (Decimal) productMap.get('ARTNUM');
            p.Name = (String) productMap.get('DESCRIPCION');
            p.UnidadVenta__c = (String) productMap.get('UOM');
            p.INT_Unidad_de_Venta_por_Metro__c = (Decimal) productMap.get('METRO_UVENTA');
            p.INT_Grupo__c = (String) productMap.get('GRUPO');
            p.INT_Subgrupo__c = (String) productMap.get('SUBGRUPO');
            p.INT_Linea__c = (String) productMap.get('LINEA');
            p.INT_Medida__c = (String) productMap.get('MEDIDA');
            p.INT_Medida_Generica__c = (String) productMap.get('MEDIDA_GENERICA');
            p.INT_Piezas_por_Caja__c = (Integer) productMap.get('PIEZAS_X_CAJA');
            p.INT_Marca__c = (String) productMap.get('MARCA');
            p.INT_Submarca__c = (String) productMap.get('SUBMARCA');
            p.IsActive = ((Boolean) productMap.get('IsActive')) != true ? false : true;
            System.debug('p.IsActive: ' + p.IsActive);
            p.INT_Status__c = (String) productMap.get('ESTATUS');
            p.TipoProducto__c = (String) productMap.get('TIPO');
            p.INT_Clasificacion__c = (String) productMap.get('CLASIFICACION');
            p.INT_Fuente__c = (String) productMap.get('FUENTE');
            p.INT_Cuerpo__c = (String) productMap.get('CUERPO');
            p.INT_Apariencia__c = (String) productMap.get('APARIENCIA');
            p.INT_Color__c = (String) productMap.get('COLOR');
            p.Color_Generico__c = (String) productMap.get('COLOR_GENERICO');
            p.INT_Estilo__c = (String) productMap.get('ESTILO');
            p.INT_Peso__c = (Decimal) productMap.get('PESO');
            p.INT_Tipo_de_Mercado__c = (String) productMap.get('TIPO_MERCADO');
            p.INT_Mostrar__c = (Decimal) productMap.get('MOSTRAR');
            p.INT_Imagen_URL__c = (String) productMap.get('IMAGEN_URL');
            p.INT_Ficha_Tecnica_URL__c = (String) productMap.get('FICHA_TECNICA_URL');
            p.INT_Hoja_de_Catalogo_URL__c = (String) productMap.get('HOJA_CATALOGO_URL');
            p.INT_Manual_de_Instalacion_URL__c = (String) productMap.get('MANUAL_INSTALACION_URL');
            p.INT_TIPOCPQ__c = (String) productMap.get('TIPOCPQ');
            p.SBQQ__PriceEditable__c = (Boolean) productMap.get('SBQQ__PriceEditable__c');
            List<Object> completoList = new List<Object>();
            completoList = (List<Object>) productMap.get('COMPLETO');
            if(completoList != null){
                for (Object completoObj : completoList) {
                    Map<String, Object> completoMap = (Map<String, Object>) completoObj;
                    p.INT_Articulo_Clave__c = (String) completoMap.get('ARCLAVE');
                }
            }
            p.Bandera_Dummy__c = TS4_RestImage2(p.INT_Imagen_URL__c);
            // Add the product record to the list
            System.debug('Bandera ' + p.Bandera_Dummy__c);
            productRecords.add(p);
            
        }
        
        return productRecords;
    }
    
    public static Boolean isValidUrl(String url) {
        if (url == null || url == '') {
            return false;
        }
        // Expresión regular para validar URLs que acepten http y https
        String urlRegex = '^(https?://)[\\w.-]+(:\\d+)?(/\\S*)?$';
        Pattern pattern = Pattern.compile(urlRegex);
        Matcher matcher = pattern.matcher(url);
        return matcher.matches();
    }

    public static Boolean TS4_RestImage2(String URL){
        if (!isValidUrl(URL)) {
            URL = '';
        }
        Boolean Bandera_Dummy = false;
        URL = URL + '';
        if (URL == ''){
            Bandera_Dummy = true;
            return Bandera_Dummy;
        }else{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            HttpResponse res = null;
            req.setEndpoint(URL); // Reemplaza con tu endpoint
            req.setMethod('GET');
            try{
                res = http.send(req);
                if (res.getStatusCode() == 200){
                    if (res.getHeader('Content-Type') == 'application/json' || res.getHeader('Content-Length') == '0'){
                        Bandera_Dummy = true;
                        return Bandera_Dummy;
                    }
                } else{
                    System.debug('Failed with status: ' + res.getStatus() + ' and response: ' + res.getBody());
                    Bandera_Dummy = true;
                    return Bandera_Dummy;
                }
                
            } catch (Exception e){
                System.debug('Exceptio: ' + e.getMessage());
            }
        }
        return Bandera_Dummy;
    }

    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        Set<Id> setProductId = new Set<Id>();

        for (Product2 myProduct : scope) {
            myProduct.Bandera_Dummy__c = TS4_RestImage2(myProduct.INT_Imagen_URL__c);
        }
        Database.upsertResult[] upsertResults = Database.upsert(scope, Product2.INT_External_Id__c, false);
        
        for (Database.UpsertResult upsertResult : upsertResults) {
            if (upsertResult.isSuccess()) {
                setProductId.add(upsertResult.getId());
                upsertedCount++;
            } else {
                failedCount++;
                batchErrors += upsertResult.getErrors() + '\n';
            }
        }
        
        for(Product2 iProd : [SELECT Id, INT_External_Id__c 
                              FROM Product2 
                              WHERE Id IN: setProductId])
        {
            Product iProducto = new Product();
            iProducto.Artclave = iProd.INT_External_Id__c;
            iProducto.ProductId = iProd.Id;
            listProduct.add(iProducto);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Products.txt');
        attachment.setBody(Blob.valueOf(JSON.serialize(listProduct)));
        
        // create a new SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // set the recipient email address
       email.setToAddresses(new String[]{'soporte@ts4.mx', 'jesalcido@Interceramic.com', 'dearzate@interceramic.com'});
        // set the email subject
        email.setSubject('Pricebook Rest Resource');
        // set the email body
        String emailBody = 	'Los siguientes productos han sido creados/actualizados en Salesforce: <br>' + listProduct + ', <br>' + 
            				'<br>'+
            				'Los siguientes productos han fallado  <br>' + batchErrors + ', <br>' +
            				'<br>'+
            				'Para mayor información acerca de los productos creados/actualizados descargue el adjunto';
        email.setHtmlBody(emailBody);
        
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        
        // send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        // check if the email was sent successfully
        if (results[0].isSuccess()) {
            System.debug('Email sent successfully.');
        } else {
            System.debug('Email failed to send.');
        }
    }
    
    public class Product {
        String Artclave;
        String ProductId;
    }
}