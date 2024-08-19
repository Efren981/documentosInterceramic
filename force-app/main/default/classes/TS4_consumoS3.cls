public with sharing class TS4_consumoS3 {
    @AuraEnabled
    public static String cargaArchivo(String base64,string fileType,String categoria,String nombre) {
        try {
            System.debug(base64);
            System.debug(fileType);
            Blob decodedBlob = EncodingUtil.base64Decode(base64);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint('callout:AWS_S3/'+categoria+'/'+nombre);
            request.setMethod('PUT');
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setHeader('Content-Type', fileType);
            request.setBodyAsBlob(decodedBlob);
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                
                String labelValue = System.Label.S3_URL+'/'+categoria+'/'+nombre;
                System.debug('>>labelValue');
                System.debug(labelValue);
                return labelValue;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
        return null;
    }
}