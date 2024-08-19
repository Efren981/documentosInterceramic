/**
 * Descripción: SI-TS4-S2028_ Generar un reporte descargable desde el grupo de productos a aprobar, que adicional a los que ya se muestra en la pantalla
 *
 * Empresa: TS4 Strategy
 * Autor: Juan Antonio Pedraza Guzman
 * Contacto: jpedraza@ts4.mx
 * Fecha: 2024-06-19
 */
public with sharing class TS4_ProductoAprobarController{
    public User user{ get; set; }

    public class productosAprobar{
        @AuraEnabled
        public String a1Producto_codigo{ get; set; }

        @AuraEnabled
        public String a2Producto{ get; set; }

        @AuraEnabled
        public String a30Cantidad_en_metros{ get; set; }

        @AuraEnabled
        public String a31Cantidad{ get; set; }

        @AuraEnabled
        public String a4Clasificacion{ get; set; }

        @AuraEnabled
        public String a5Precio_por_metro{ get; set; }

        @AuraEnabled
        public String a6Precio_de_lista{ get; set; }

        @AuraEnabled
        public String a7Descuento{ get; set; }

        @AuraEnabled
        public String a8Precio_con_descuento{ get; set; }

        @AuraEnabled
        public String a900Importe_bruto{ get; set; }

        @AuraEnabled
        public String a901Margen_franquicia{ get; set; }

        @AuraEnabled
        public String a902Precio_base{ get; set; }

        @AuraEnabled
        public String a903Flete_elp{ get; set; }

        @AuraEnabled
        public String a904Lab_obra{ get; set; }

        @AuraEnabled
        public String a905Lab_obra_con_fianza{ get; set; }

        @AuraEnabled
        public String a906Fianza{ get; set; }

        @AuraEnabled
        public String a907Margen{ get; set; }

        @AuraEnabled
        public String a908Prop_margen{ get; set; }

        @AuraEnabled
        public String a909Prop_margen_porc{ get; set; }

        @AuraEnabled
        public String a910Precio_proy_con_iva{ get; set; }

        @AuraEnabled
        public String a911Precio_proy_sin_iva{ get; set; }

        @AuraEnabled
        public String a912Descto_proy_porc{ get; set; }

    }

    public List<SBQQ__QuoteLine__c> quoteLine{ get; set; }

    public Grupo_de_productos_a_aprobar__c grupoAprobar{ get; set; }

    public TS4_ProductoAprobarController(){
        this.user = [SELECT Id, name, Title, phone, Extension, MobilePhone, email
                     FROM User
                     WHERE Id = :UserInfo.getUserId()];
        String sRegistroId = ApexPages.currentPage().getParameters().get('id');
        this.grupoAprobar = [SELECT Id, Name, Cotizacion__r.SBQQ__Opportunity2__r.Account.Name, Cotizacion__r.SBQQ__Opportunity2__r.Oportunidad_Relacionada__r.Name, Cotizacion__r.SBQQ__PriceBook__r.Name, Cotizacion__r.Name, Cotizacion__r.SBQQ__Opportunity2__r.Name, Cotizacion__r.SBQQ__Opportunity2__r.Oportunidad_Relacionada__c, Descripcion__c, Monto_minimo_cotizado__c
                             from Grupo_de_productos_a_aprobar__c
                             where Id = :sRegistroId];

        this.quoteLine = [SELECT Id, SBQQ__Product__r.Bandera_Dummy__c, SBQQ__Product__r.INT_Imagen_URL__c, SBQQ__Quantity__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.Name, METROS__c, Clasificacion__c, INT_Precio_unitario_por_metro__c, SBQQ__Discount__c, PRECIO_DESCUENTO__c, IMPORTE_BRUTO__c, MARGEN_FRANQUICIA__c, Grupos_de_productos__c, SBQQ__ListPrice__c
                          from SBQQ__QuoteLine__c
                          where Grupos_de_productos__c = :sRegistroId];
    }

    @AuraEnabled
    public static String getPdfFileAsBase64String(Id grupoAprobarId){
        PageReference pdfPage = new PageReference('/apex/TS4_ProductosAprobarVf');
        pdfPage.getParameters().put('id', grupoAprobarId);
        Blob pdfBlob;
        if (Test.isRunningTest()){
            pdfBlob = blob.valueOf('Unit.Test');
        } else{
            pdfBlob = pdfPage.getContent();
        }

        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        //System.debug(base64Pdf);
        return base64Pdf;
    }

    @AuraEnabled(cacheable = true)
    public static List<productosAprobar> fetchRecords(Id grupoAprobarId){
        // Consulta SOQL
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, MARGEN_FRANQUICIA__c, PRECIO_BASE__c, FLETE_ELP__c, LAB_OBRA__c, LAB_OBRA_CON_FIANZA__c, FIANZA__c, MARGEN__c, PROP_MARGEN__c, PROP_MARGEN_PORC__c, PRECIO_PROY_CON_IVA__c, PRECIO_PROY_SIN_IVA__c, DESCTO_PROY_PORC__c, SBQQ__Product__r.ProductCode, SBQQ__Quantity__c, SBQQ__Product__r.Name, METROS__c, Clasificacion__c, INT_Precio_unitario_por_metro__c, SBQQ__Discount__c, PRECIO_DESCUENTO__c, IMPORTE_BRUTO__c, Grupos_de_productos__c, SBQQ__ListPrice__c
                                               FROM SBQQ__QuoteLine__c
                                               WHERE Grupos_de_productos__c = :grupoAprobarId];

        // Lista para almacenar los resultados
        List<productosAprobar> productosAprobarList = new List<productosAprobar>();

        // Llenar el wrapper con los resultados de la consulta
        for (SBQQ__QuoteLine__c ql : quoteLines){
            productosAprobar producto = new productosAprobar();
            producto.a1Producto_codigo = (ql.SBQQ__Product__r.ProductCode != null) ? ql.SBQQ__Product__r.ProductCode : '';
            producto.a2Producto = (ql.SBQQ__Product__r.Name != null) ? ql.SBQQ__Product__r.Name : '';
            producto.a30Cantidad_en_metros = (ql.METROS__c != null) ? String.valueOf(ql.METROS__c) + ' ' : ' ';
            producto.a31Cantidad = (ql.SBQQ__Quantity__c != null) ? String.valueOf(ql.SBQQ__Quantity__c) + ' ' : ' ';
            producto.a4Clasificacion = (ql.Clasificacion__c != null) ? ql.Clasificacion__c : '';
            producto.a5Precio_por_metro = (ql.INT_Precio_unitario_por_metro__c != null) ? '$ ' + String.valueOf(ql.INT_Precio_unitario_por_metro__c) : '$ 0';
            producto.a6Precio_de_lista = (ql.SBQQ__ListPrice__c != null) ? '$ ' + String.valueOf(ql.SBQQ__ListPrice__c) : '$ 0';
            producto.a7Descuento = (ql.SBQQ__Discount__c != null) ? String.valueOf(ql.SBQQ__Discount__c / 1) + ' %' : '';
            producto.a8Precio_con_descuento = (ql.PRECIO_DESCUENTO__c != null) ? '$ ' + String.valueOf(ql.PRECIO_DESCUENTO__c) : '$ 0';
            producto.a900Importe_bruto = (ql.IMPORTE_BRUTO__c != null) ? '$ ' + String.valueOf(ql.IMPORTE_BRUTO__c) : '$ 0';
            producto.a901Margen_franquicia = (ql.MARGEN_FRANQUICIA__c != null) ? '$ ' + String.valueOf(ql.MARGEN_FRANQUICIA__c) : '$ 0';
            producto.a902Precio_base = (ql.PRECIO_BASE__c != null) ? '$ ' + String.valueOf(ql.PRECIO_BASE__c) : '$ 0';
            producto.a903Flete_elp = (ql.FLETE_ELP__c != null) ? '$ ' + String.valueOf(ql.FLETE_ELP__c) : '$ 0';
            producto.a904Lab_obra = (ql.LAB_OBRA__c != null) ? '$ ' + String.valueOf(ql.LAB_OBRA__c) : '$ 0';
            producto.a905Lab_obra_con_fianza = (ql.LAB_OBRA_CON_FIANZA__c != null) ? '$ ' + String.valueOf(ql.LAB_OBRA_CON_FIANZA__c) : '$ 0';
            producto.a906Fianza = (ql.FIANZA__c != null) ? '$ ' + String.valueOf(ql.FIANZA__c) : '$ 0';
            producto.a907Margen = (ql.MARGEN__c != null) ? '$ ' + String.valueOf(ql.MARGEN__c) : '$ 0';
            producto.a908Prop_margen = (ql.PROP_MARGEN__c != null) ? '$ ' + String.valueOf(ql.PROP_MARGEN__c) : '$ 0';
            producto.a909Prop_margen_porc = (ql.PROP_MARGEN_PORC__c != null) ? '$ ' + String.valueOf(ql.PROP_MARGEN_PORC__c) : '$ 0';
            producto.a910Precio_proy_con_iva = (ql.PRECIO_PROY_CON_IVA__c != null) ? '$ ' + String.valueOf(ql.PRECIO_PROY_CON_IVA__c) : '$ 0';
            producto.a911Precio_proy_sin_iva = (ql.PRECIO_PROY_SIN_IVA__c != null) ? '$ ' + String.valueOf(ql.PRECIO_PROY_SIN_IVA__c) : '$ 0';
            producto.a912Descto_proy_porc = (ql.DESCTO_PROY_PORC__c != null) ? String.valueOf(ql.DESCTO_PROY_PORC__c / 1) + ' %' : '';

            productosAprobarList.add(producto);
        }
        System.debug(quoteLines);
        System.debug(productosAprobarList);
        return productosAprobarList;
    }

    @AuraEnabled
    public static Grupo_de_productos_a_aprobar__c getGrupoAprobar(String recordId){
        return [SELECT Id, Name, Cotizacion__r.SBQQ__Opportunity2__r.Account.Name, Cotizacion__r.SBQQ__Opportunity2__r.Oportunidad_Relacionada__r.Name, Cotizacion__r.SBQQ__PriceBook__r.Name, Cotizacion__r.Name, Cotizacion__r.SBQQ__Opportunity2__r.Name, Cotizacion__r.SBQQ__Opportunity2__r.Oportunidad_Relacionada__c, Descripcion__c, Monto_minimo_cotizado__c
                FROM Grupo_de_productos_a_aprobar__c
                WHERE Id = :recordId];
    }

}