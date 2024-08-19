public with sharing class AMC_UploadCSVOrderController {
    public static Boolean isExecuting = false;
    /*
    * @method uploadFile()
    * @desc Creates a content version from a given file's base64 and name
    * 
    * @param {String} csvData - JSON formed variable, contains a list of CSVData structure
    * @param {String} opportunityId - Id of opportunity to relate the products
    * 
    * @return void
    */
    @AuraEnabled
    public static void uploadFile(String opportunityId, String csvData) {
        isExecuting = true;
        //OpportunityLineItem list to be inserted accorded to csvData param
        OpportunityLineItem[] oppLines = new OpportunityLineItem[]{};
            try{
                //Convert csvData String param to Wrapper for processing
                csvData[] lstProds = (CSVData[])JSON.deserialize(csvData, CSVData[].class);
                //List iteration for fill the list of records to be inserted
                for(csvData prod : lstProds){
                    //Reference by externalId to relate products
                    Product2 prodReference = new Product2();
                    //Create OpportunityLineItem record to be inserted
                    OpportunityLineItem oppLine = new OpportunityLineItem(
                        OpportunityId = opportunityId,
                        Product2 = prodReference,
                        Quantity = Decimal.valueOf(prod.Cantidad)
                    );
                    //Add records to list
                    oppLines.add(oppLine);
                }
                //If object is creatable insert the list of records
                if (Schema.sObjectType.OpportunityLineItem.isCreateable()) {
                    insert oppLines;
                 }else {//Else return an exception
                    throw new AuraHandledException('No tienes permiso para crear registros de Producto de Oportunidad');
                 }
            }catch(Exception ex){
                throw new AuraHandledException('Error al generar los productos: '+ex.getMessage());
            }
    }
    /**
    * @description Wrapper to read CSV data from the LWC
    * @author emeza@freewayconsulting.com | 03-28-2022
    **/
    public class CSVData{
        @AuraEnabled public String Cantidad;
        @AuraEnabled public String Producto;
    }
}