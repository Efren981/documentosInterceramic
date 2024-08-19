public class PricebookEntries {

    public static void callBatchUpsertPricebookEntries(String PricebookId, String Moneda, List<Object> listProducts){
        String sFields = '';
        String sObjectName = '';
        String sFieldFilter1 = '';
        String sFieldFilter2 = '';
        String sFieldFilter3 = '';
        
        List<String> listArtClave = new List<String>();
        
        for (Object productoObject : listProducts) {
            Map<String, Object> productoMap = (Map<String, Object>) productoObject;
            String artclave = (String) productoMap.get('artclave');
            listArtClave.add(artclave);
        }
        
        sFields = 'Id, INT_External_Id__c';
        sObjectName = 'Product2 ';
        sFieldFilter1 = 'INT_External_Id__c IN :listArtClave';
        
        String sQuery = 'SELECT ' + sFields + ' ' +
                        'FROM ' + sObjectName + ' ' +
                        'WHERE ' + sFieldFilter1;
        
        PricebookEntriesBatch batch = new PricebookEntriesBatch(sQuery, PricebookId, Moneda, listProducts, listArtClave);
        database.executeBatch(batch, 20);
    }
}