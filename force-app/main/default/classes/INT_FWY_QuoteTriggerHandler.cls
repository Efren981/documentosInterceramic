/* Author: Briseidy Torres - btorres@freewayconsulting.com
 * Last modified: 12/12/2023 
*/
public class INT_FWY_QuoteTriggerHandler {
    
    //Muestra error al tener productos duplicados en cada cotización
    public static void handleTrigger(List<SBQQ__Quote__c> quotes){
        
    Map<Id,List<Id>> products = new Map<Id, List<Id>>();
    
    List<SBQQ__QuoteLine__c> quotelines = [SELECT Id,SBQQ__Quote__c, SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN :quotes limit 5000];
    for(SBQQ__Quote__c quote:quotes ){
        if(quotelines.size() > 0){
            for(SBQQ__QuoteLine__c quoteLine :quotelines  ){
            if(quote.Id == quoteLine.SBQQ__Quote__c ){

                if (!products.containsKey(quote.Id)) {
                    products.put(quote.Id, new List<Id>());
                }
                
                products.get(quote.Id).add(quoteLine.SBQQ__Product__c);
                
            }
        }
    }
        
    }

    for (SBQQ__Quote__c quote :quotes) {
        if (products.containsKey(quote.Id)) {
            List<Id> existingProductIds = products.get(quote.Id);
            
           
            Set<Id> uniqueProductIds = new Set<Id>(existingProductIds);
            
            if (existingProductIds.size() != uniqueProductIds.size()) {
                quote.addError('La cotización contiene productos duplicados.');
            }

        }
    }
    }
}