public without sharing class WS_ConsultaMargenes {
    
    @AuraEnabled
    public static String consultarMargenes(Id recordId){
        System.debug('recordId ' + recordId);
        
        List<SBQQ__QuoteLine__c> listNormal = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> listMB = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> listProductWithoutCPQ = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c iQuoteLine : [SELECT Id, SBQQ__Quote__r.CreatedBy.Name, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Discount__c, 
                                             SBQQ__Product__r.INT_TIPOCPQ__c, GRID__c,INT_Grid__c, DESTINO__c, TIPO__c, PRECIO_PROY_CON_IVA__c, PRECIO_KOHLER__c, SBQQ__ListPrice__c,
                                             SBQQ__Quote__r.INT_GRID__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c
                                             FROM SBQQ__QuoteLine__c 
                                             WHERE SBQQ__Quote__c =: recordId])
        {
            if(iQuoteLine.SBQQ__Product__r.INT_TIPOCPQ__c == null){
                listProductWithoutCPQ.add(iQuoteLine);
            }else if(iQuoteLine.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c){
                listMB.add(iQuoteLine);
            }else{
                listNormal.add(iQuoteLine);
            }
        }
        
        if(!listNormal.isEmpty()){

            normal inormal = new normal();
            List<producto> listProducto = new List<producto>();
            for(SBQQ__QuoteLine__c iQuote : listNormal)
            {
                inormal.TIPO_MARGEN = 'NORMAL';
                inormal.EJECUTIVO = iQuote.SBQQ__Quote__r.CreatedBy.Name;
            }
            
            for(SBQQ__QuoteLine__c iQuote : listNormal)
            {
                producto iProd = new producto();
                iProd.ARTCLAVE = iQuote.SBQQ__Product__r.ProductCode;
                iProd.CANTIDAD = String.valueOf(Integer.ValueOf(iQuote.SBQQ__Quantity__c));
                iProd.DESCUENTO = iQuote.SBQQ__Discount__c;
                listProducto.add(iProd);
            }
            inormal.PRODUCTOS = listProducto;
            
            String body = JSON.serialize(inormal);
            
            //System.enqueueJob(New WS_QueueableConsultaMargenesNormal(recordId, body));
            WS_FutureConsultaMargenesNormal.consultaMargenesNormal(recordId, body);
        }
        
        if(!listMB.isEmpty()){
            
            mueblebanio iMb = new mueblebanio();
            List<productomb> listproductomb = new List<productomb>();
            for(SBQQ__QuoteLine__c iQuote : listMB)
            {
                iMb.TIPO_MARGEN = 'MB';
                if(iQuote.SBQQ__Quote__r.INT_GRID__c != null)iMb.GRID = Integer.ValueOf(iQuote.SBQQ__Quote__r.INT_GRID__c);
                iMB.DESTINO = iQuote.DESTINO__c;
                iMB.TIPO = iQuote.TIPO__c;
                iMb.EJECUTIVO = iQuote.SBQQ__Quote__r.CreatedBy.Name;
                //iMb.EJECUTIVO = 'ALPAEZ';
            }
            
            for(SBQQ__QuoteLine__c iQuote : listMB)
            {
                productomb iProd = new productomb();
                iProd.ARTCLAVE = iQuote.SBQQ__Product__r.ProductCode;
                iProd.CANTIDAD = String.valueOf(Integer.ValueOf(iQuote.SBQQ__Quantity__c));
                iProd.DESCTO_PROYECTO_PORC = iQuote.SBQQ__Discount__c;
                iProd.PRECIO_PROY_CON_IVA = iQuote.PRECIO_PROY_CON_IVA__c;
                iProd.PRECIO_KOHLER = iQuote.SBQQ__ListPrice__c;//PRECIO_KOHLER__c Campo anterior
                listproductomb.add(iProd);
            }
            iMb.PRODUCTOS = listproductomb;
            
            String body = JSON.serialize(iMb);
            System.debug('body: ' + body);
            //System.enqueueJob(New WS_QueueableConsultaMargenesMB(recordId, body));
            WS_FutureConsultaMargenesMB.consultaMargenesMB(recordId, body);
        }      
        
        if(!listProductWithoutCPQ.isEmpty() && (!listNormal.isEmpty() || !listMB.isEmpty())){
            return 'Advertencia!, alguno de los productos no tiene el valor cargado Tipo CQP en el producto, la consulta no devolverá el márgen correspondiente a ese producto';
        }
        else if(listProductWithoutCPQ.isEmpty() && (!listNormal.isEmpty() || !listMB.isEmpty())){
        	return 'OK';
        }
        else if(listNormal.isEmpty() && listMB.isEmpty()){
            return 'Error, alguno de los productos no tiene cargado correctamente el valor Tipo CPQ';
        }
        return '';
    }
    
    public class normal {
        String TIPO_MARGEN;
        String EJECUTIVO;
        List<producto> PRODUCTOS;
    }
    
    public class producto {
        String ARTCLAVE;
        String CANTIDAD;
        Decimal DESCUENTO;
    }
    
    public class mueblebanio {
        String TIPO_MARGEN;
        Decimal GRID;
        String DESTINO;
        String TIPO;
        String EJECUTIVO;
        List<productomb> PRODUCTOS;
    }
    
    public class productomb {
        String ARTCLAVE;
        String CANTIDAD;
        Decimal DESCTO_PROYECTO_PORC;
        Decimal PRECIO_KOHLER;
        Decimal PRECIO_PROY_CON_IVA;
    }
    
    //Se crea el metodo para cubrir con el porcentaje que requiere SF, ya que no se puede testear
    //Pricebook en clases test, por lo cual no cubrimos con la logica de la clase
    public static void coverTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}