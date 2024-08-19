/************************************************************************
Name: TS4_IS_CalloutUtils
Copyright © 2024 Salesforce
========================================================================
Purpose:
Genera un callout dinámico para cualquier tipo de petición rest.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  2.0      dmarcos@ts4.mx    8/07/2024     SECOND       
************************************************************************/
public without sharing class TS4_IS_CalloutUtils {
    public static final String CLASS_NAME = TS4_IS_CalloutUtils.class.getName();
    
    /*
* nombre: generateRequest
* descripcion: usado para generar HttpRequest
* parametros:
* method                 -> GET | POST | DELETE | PUT
* endpoint               -> url
* (opcional) mParams     -> mapa de parametros para endpoint url (valor de parametro opcional)
* (opcional) mHeaders    -> mapa de valores de header (valor de header opcional)
* (opcional) timeout     -> milliseconds 1 a 120000
* (opcional) body        -> texto
*/
    public static HttpRequest generateRequest(String method, String endpoint, Map<String, String> mParams, Map<String, String> mHeaders, Integer timeout, String body)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        if(timeout != null && timeout >= 1 && timeout <= 120000)
            req.setTimeout(timeout);
        if(String.isNotBlank(body)) 
            req.setBody(body);
        system.debug('URL : '+endPoint);
        String endPointFinal = 'callout:' + endPoint;
        if(mParams != null && !mParams.isEmpty())
        {
            boolean isFirst = true;
            for(String param: mParams.keySet())
            {
                String paramValue =  String.isBlank(mParams.get(param)) ? '' : EncodingUtil.urlEncode(mParams.get(param), 'UTF-8');
                endPointFinal += (isFirst ? + param + paramValue : + param + '=' + paramValue);
                isFirst = false;
            }
        }
        req.setEndpoint(endPointFinal);
        if(mHeaders != null && !mHeaders.isEmpty())
        {
            for(String header: mHeaders.keySet())
            {
                req.setHeader(header, String.isBlank(mHeaders.get(header)) ? '' : mHeaders.get(header));
            }
        }
        if(String.isBlank(body) && !mHeaders.containsKey(TS4_IS_CalloutConstants.HEADER_CONTENT_LENGTH))
            req.setHeader(TS4_IS_CalloutConstants.HEADER_CONTENT_LENGTH, '0');
        return req;
    }
    
    /*
* nombre: doRequest
* descripcion: usado para obtener HttpResponse
* parametros:
* req         -> HttpRequest
* retryOnFail -> boolean
*/
    public static HttpResponse doRequest(HttpRequest req, Boolean retryOnFail)
    {
        if(Limits.getDmlStatements() > 0)
        {
            String errorMsg = 'No se permiten callouts luego de operaciones DML';
            throw new CalloutException(errorMsg);
        }
        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
        {
            return res;
        }
        else
        {
            // volver a intentar
            if(retryOnFail)
            {
                return doRequest(req, false);
            }
            // manejar error
            System.debug( LoggingLevel.ERROR,
                         '*** ' + CLASS_NAME +'.doRequest() fallo: ' + res +
                         '\nresBody: ' + res.getBody() +
                         '\nreqEndpoint: ' + req.getEndpoint() +
                         (String.isNotBlank(req.getBody()) ? '\nreqBody: ' + req.getBody() : '') );
            throw new CalloutException(res.getStatusCode() + ',' + res.getStatus());
        }
    }
    
    public class CalloutException extends Exception {}
    
}