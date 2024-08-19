public with sharing class TS4_RestImage{

   
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
   
    @future(callout = true)
    public static void TS4_RestImage(String URL, Id proID){
        if (!isValidUrl(URL)) {
            URL = '';
        }
        Product2 proItem = [SELECT Id, Name, INT_Imagen_URL__c
                            FROM Product2
                            WHERE Id = :proID
                            LIMIT 1];
        proItem.Bandera_Dummy__c = false;
        URL = URL + '';
        if (URL == ''){
            proItem.Bandera_Dummy__c = true;
            update proItem;
            return;
        }else{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            HttpResponse res = null;
            req.setEndpoint(URL); // Reemplaza con tu endpoint
            req.setMethod('GET');
            try{
                res = http.send(req);
                if (res.getStatusCode() == 200){
                    if (res.getHeader('Content-Type') == 'application/json'){
                        proItem.Bandera_Dummy__c = true;
                    }
                } else{
                    System.debug('Failed with status: ' + res.getStatus() + ' and response: ' + res.getBody());
                    proItem.Bandera_Dummy__c = true;
                }
                update proItem;
            } catch (Exception e){
                System.debug('Exceptio: ' + e.getMessage());
            }
        }
    }
}