/**
 * @description       : 
 * @author            : emeza@freewayconsulting.com
 * @group             : 
 * @last modified on  : 09-28-2023
 * @last modified by  : emeza@freewayconsulting.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   09-14-2023   emeza@freewayconsulting.com   Initial Version
**/
public class WS_Interceramic {

    // Custom exception for errors related to the external system
    public class ExternalSystemException extends Exception {}
    
    
    public static HttpResponse getFranquicias() {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_Post_Franquicias');

            request.setEndpoint('callout:AWS_Franquicias/');
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map

                return response;
            } else {
                // Throw a custom exception with the error message
                throw new ExternalSystemException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new ExternalSystemException('An error occurred while getting the token.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_Franquicias';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            insert log;
        }
    }
    
    public static HttpResponse getSucursales() {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_Post_Sucursales');

            request.setEndpoint('callout:AWS_Sucursales/');
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map
                return response;
            } else {
                // Throw a custom exception with the error message
                throw new ExternalSystemException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new ExternalSystemException('An error occurred while getting the token.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_Sucursales';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            insert log;
        }
    }
    
    public static HttpResponse getColonias(Integer iPages) {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        String sPages = String.valueOf(iPages);
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_Post_Colonias');

            request.setEndpoint('callout:AWS_Colonias/' + sPages);
            System.debug(request.getEndpoint());
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map
                return response;
            } else {
                // Throw a custom exception with the error message
                throw new ExternalSystemException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new ExternalSystemException('An error occurred while getting the token.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_Sucursales';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            insert log;
        }
    }
    
    public static HttpResponse getMargenesMB(String body){
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_Margenes_MB');

            request.setEndpoint('callout:AWS_Margenes_MB/');
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody(body);
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                system.debug('response mb'+response.getbody());
                // Use JSON.deserializeUntyped to parse the response body as a Map
                return response;
            } else {
                // Throw a custom exception with the error message
                throw new AuraHandledException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new AuraHandledException('Error al consultar lo márgenes, intenta más tarde la consulta.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_Margenes_MB';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            insert log;
        }
    }
    
    public static HttpResponse getMargenesNormal(String body){
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_Margenes_Normal');

            request.setEndpoint('callout:AWS_Margenes_Normal/');
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody(body);
            request.setTimeout(120000);
            
            Http http = new Http();
            response = http.send(request);
          
            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map
                return response;
            } else {
                // Throw a custom exception with the error message
                throw new AuraHandledException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new AuraHandledException('Error al consultar lo márgenes, intenta más tarde la consulta.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_Margenes_Normal';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            insert log;
        }
    }
    
    public static HttpResponse getIdLealtad(String body){
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_IdLealtad');

            request.setEndpoint('callout:AWS_IdLealtad/');
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody(body);
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map
                return response;
            } else {
                // Throw a custom exception with the error message
                throw new ExternalSystemException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new ExternalSystemException('An error occurred while getting the token.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_IdLealtad';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            insert log;
        }
    }

    public static Boolean isOrgSandbox(){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return runningInASandbox;
    }
    
    public static WrapperGetColoniasFullResponse getColoniasFull(Integer iPages) {
        WrapperGetColoniasFullResponse responseFinal = new WrapperGetColoniasFullResponse();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        String sPages = String.valueOf(iPages);
        
        try {
            Integration_Data__mdt mdtWS = Integration_Data__mdt.getInstance('AWS_Post_Colonias');

            request.setEndpoint('callout:AWS_Colonias/' + sPages);
            System.debug(request.getEndpoint());
            request.setMethod(mdtWS.Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', mdtWS.x_api_key__c);
            request.setHeader('clave-modulo', mdtWS.clave_modulo__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map
                //return response;
                responseFinal.response = response;
                responseFinal.success = true;
            } else {
                // Throw a custom exception with the error message
                throw new ExternalSystemException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            throw new ExternalSystemException('An error occurred while getting the token.');
        } finally {
            // Create a log_integration__c record
            Log_Integration__c log = new Log_Integration__c();
            log.Status_Code__c = String.valueOf(response.getStatusCode());
            log.Endpoint__c = 'AWS_Sucursales';
            log.Error_Message__c = response.getStatusCode() == 200 ? '' : response.getStatus() + ' ' + response.getBody();
            log.Request__c = request.getBody().abbreviate(131072);
            log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
            log.Method__c = request.getMethod();
            log.Date__c = Date.today();
            //insert log;
            responseFinal.logSF = log;
        }
        return responseFinal;
    }
    
    public Class WrapperGetColoniasFullResponse {
        public Boolean success = false;
        public HttpResponse response {get;set;}
        public Log_Integration__c logSF {get;set;}
    }
}