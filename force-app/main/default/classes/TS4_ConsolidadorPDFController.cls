/**
 * Descripción: SI-TS4-S2029_ Generar un formato nuevo de cotización y de convenio que sirva para mostrar en un solo documento todos los productos de la oportunidad padre y sus relacionadas
 *
 * Empresa: TS4 Strategy
 * Autor: Juan Antonio Pedraza Guzman
 * Contacto: jpedraza@ts4.mx
 * Fecha: 2024-06-19
 */

public with sharing class TS4_ConsolidadorPDFController{
    public Account account{ get; set; }

    public Contact contact{ get; set; }

    public User user{ get; set; }

    public class consolidado{
        @AuraEnabled
        public String a1Producto_codigo{ get; set; }

        @AuraEnabled
        public String a2Producto{ get; set; }

        @AuraEnabled
        public String a3Unidad_de_medida{ get; set; }

        @AuraEnabled
        public String a4Cantidad{ get; set; }

        @AuraEnabled
        public String a5Precio_de_lista{ get; set; }

        @AuraEnabled
        public String a6Porcentaje_de_descuento{ get; set; }

        @AuraEnabled
        public String a70Precio_proyecto_unidad_de_venta{ get; set; }

        @AuraEnabled
        public String a71Precio_proyecto_por_m2{ get; set; }

        @AuraEnabled
        public String a8Total_proyecto{ get; set; }

        @AuraEnabled
        public String a90Oportunidad{ get; set; }

        @AuraEnabled
        public String a91Nombre_de_Oportunidad{ get; set; }

        @AuraEnabled
        public String a92Fecha_inicio{ get; set; }

        @AuraEnabled
        public String a93Fecha_fin{ get; set; }

        @AuraEnabled
        public String a94Negociacion{ get; set; }

    }

    public String tipo{ get; set; }

    public Opportunity oppunity{ get; set; }

    /*public SBQQ__TemplateContent__c template{ get; set; }*/
    public List<OpportunityLineItem> oppLineItem{ get; set; }

    public TS4_ConsolidadorPDFController(){
        this.user = [SELECT Id, name, Title, phone, Extension, MobilePhone, email
                     FROM User
                     WHERE Id = :UserInfo.getUserId()];
        Integer mb = 0;
        Integer normal = 0;
        String sRegistroId = ApexPages.currentPage().getParameters().get('id');

        this.oppunity = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c
                         FROM Opportunity
                         WHERE Id = :sRegistroId];

        if (!(String.isBlank(oppunity.Oportunidad_Relacionada__c))){
            sRegistroId = oppunity.Oportunidad_Relacionada__c;
            System.debug(sRegistroId);
        }

        this.oppunity = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c, ContactId
                         FROM Opportunity
                         WHERE Id = :sRegistroId];
        if (this.oppunity.ContactId != null){
            this.contact = [SELECT Id, Name
                            FROM Contact
                            where Id = :this.oppunity.ContactId];
        }
        try{
            this.oppLineItem = [SELECT Id, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Status__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c, Name, Opportunity.StageName, OpportunityId, Opportunity.Name, Opportunity.CloseDate, Opportunity.INT_Fecha_inicio__c, ProductCode, SBQQ__QuoteLine__r.METROS__c, SBQQ__QuoteLine__r.SBQQ__Product__r.INT_Imagen_URL__c, SBQQ__QuoteLine__r.SBQQ__Product__r.Bandera_Dummy__c, SBQQ__QuoteLine__r.SBQQ__ProductName__c, SBQQ__QuoteLine__r.INT_Unidad_Medida__c, Quantity, SBQQ__QuoteLine__r.Precio_de_Lista_MB__c, SBQQ__QuoteLine__r.SBQQ__TotalDiscountRate__c, SBQQ__QuoteLine__r.INT_Precio_unitario_por_metro__c, SBQQ__QuoteLine__r.Precio_Proyecto_Unidad_de_Venta_MB__c, SBQQ__QuoteLine__r.Total_proyecto_MB__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Product2.ProductCode
                                FROM OpportunityLineItem
                                WHERE OpportunityId IN (SELECT Id
                                                        FROM Opportunity
                                                        WHERE (Oportunidad_Relacionada__r.Id = :sRegistroId OR Id = :sRegistroId) AND ((StageName = 'Plan de Obra') OR ((StageName = 'Acuerdo / Convenio')))) AND (((Opportunity.StageName = 'Plan de Obra') AND (SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = true)) OR ((Opportunity.StageName = 'Acuerdo / Convenio') AND ( SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = true)))
                                ORDER BY OpportunityId];

        } catch (QueryException e){

        }
        // Lista temporal para almacenar elementos que no coinciden con el ID específico
        List<OpportunityLineItem> listaTemporal = new List<OpportunityLineItem>();

        // Lista ordenada
        List<OpportunityLineItem> listaOrdenada = new List<OpportunityLineItem>();

        // Recorre la lista original y separa los elementos
        for (OpportunityLineItem obj : this.oppLineItem){
            if (obj.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c){
                mb = mb + 1;
            } else{
                normal = normal + 1;
            }
            obj.Product2.ProductCode = addSpacesEveryTenCharacters(obj.Product2.ProductCode);
            if (obj.Id == sRegistroId){

                listaOrdenada.add(obj); // Agrega el elemento con el ID específico al principio
            } else{
                listaTemporal.add(obj); // Agrega los demás elementos a la lista temporal
            }
        }

        // Agrega los elementos restantes a la lista ordenada
        listaOrdenada.addAll(listaTemporal);
        System.debug(mb + ' : ' + normal);

        // Ahora listaOrdenada contiene los elementos ordenados con el ID específico al principio
        this.oppLineItem = listaOrdenada;

        if (normal == 0 && mb != 0){
            this.tipo = 'MB';
        } else if (mb == 0 && normal != 0){
            this.tipo = 'Normal';
        } else if (normal != 0 && mb != 0){
            this.tipo = 'mixta';
        }


        this.account = [SELECT Id, Name
                        FROM Account
                        WHERE Id IN (SELECT AccountId
                                     FROM Opportunity
                                     WHERE Id = :sRegistroId)];

        /*this.template = [SELECT Id,SBQQ__RawMarkup__c from SBQQ__TemplateContent__c where Id = 'a1MVF000000PbVp2AK'];*/
    }

    public static String addSpacesEveryTenCharacters(String input){
        String result = '';
        Integer count = 0;

        for (Integer i = 0; i < input.length(); i++){
            if (count == 10){
                result += ' ';
                count = 0;
            }
            result += input.substring(i, i + 1);
            count++;
        }

        return result;
    }

    @AuraEnabled
    public static String getPdfFileAsBase64String(String recordId){
        PageReference pdfPage = new PageReference('/apex/TS4_ConsolidadorPDFVf');
        pdfPage.getParameters().put('id', recordId);
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
    public static List<consolidado> fetchRecords(Id recordId){
        System.debug(recordId);
        Integer mb = 0;
        Integer normal = 0;
        Opportunity oppRecord = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c
                                 FROM Opportunity
                                 WHERE Id = :recordId];

        if (!(String.isBlank(oppRecord.Oportunidad_Relacionada__c))){
            recordId = oppRecord.Oportunidad_Relacionada__c;
            System.debug(recordId);
        }

        oppRecord = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c, ContactId, AccountId
                     FROM Opportunity
                     WHERE Id = :recordId];

        // Consulta SOQL
        List<OpportunityLineItem> oppLine;
        if (Test.isRunningTest()){
            oppLine = [SELECT Id, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c, Name, OpportunityId, Opportunity.Name, Opportunity.CloseDate, Opportunity.StageName, Opportunity.INT_Fecha_inicio__c, ProductCode, SBQQ__QuoteLine__r.METROS__c, SBQQ__QuoteLine__r.SBQQ__Product__r.INT_Imagen_URL__c, SBQQ__QuoteLine__r.SBQQ__Product__r.Bandera_Dummy__c, SBQQ__QuoteLine__r.SBQQ__ProductName__c, SBQQ__QuoteLine__r.INT_Unidad_Medida__c, Quantity, SBQQ__QuoteLine__r.Precio_de_Lista_MB__c, SBQQ__QuoteLine__r.SBQQ__TotalDiscountRate__c, SBQQ__QuoteLine__r.INT_Precio_unitario_por_metro__c, SBQQ__QuoteLine__r.Precio_Proyecto_Unidad_de_Venta_MB__c, SBQQ__QuoteLine__r.Total_proyecto_MB__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Product2.ProductCode
                       FROM OpportunityLineItem
                       WHERE OpportunityId IN (SELECT Id
                                               FROM Opportunity
                                               WHERE (Oportunidad_Relacionada__r.Id = :recordId OR Id = :recordId) AND ((StageName = 'Plan de Obra')))
                       ORDER BY OpportunityId];
        } else{
            oppLine = [SELECT Id, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Status__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c, Name, Opportunity.StageName, OpportunityId, Opportunity.Name, Opportunity.CloseDate, Opportunity.INT_Fecha_inicio__c, ProductCode, SBQQ__QuoteLine__r.METROS__c, SBQQ__QuoteLine__r.SBQQ__Product__r.INT_Imagen_URL__c, SBQQ__QuoteLine__r.SBQQ__Product__r.Bandera_Dummy__c, SBQQ__QuoteLine__r.SBQQ__ProductName__c, SBQQ__QuoteLine__r.INT_Unidad_Medida__c, Quantity, SBQQ__QuoteLine__r.Precio_de_Lista_MB__c, SBQQ__QuoteLine__r.SBQQ__TotalDiscountRate__c, SBQQ__QuoteLine__r.INT_Precio_unitario_por_metro__c, SBQQ__QuoteLine__r.Precio_Proyecto_Unidad_de_Venta_MB__c, SBQQ__QuoteLine__r.Total_proyecto_MB__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Product2.ProductCode
                       FROM OpportunityLineItem
                       WHERE OpportunityId IN (SELECT Id
                                               FROM Opportunity
                                               WHERE (Oportunidad_Relacionada__r.Id = :recordId OR Id = :recordId) AND ((StageName = 'Plan de Obra') OR ((StageName = 'Acuerdo / Convenio')))) AND (((Opportunity.StageName = 'Plan de Obra') AND (SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = true)) OR ((Opportunity.StageName = 'Acuerdo / Convenio') AND (SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = true)))
                       ORDER BY OpportunityId];
        }


        // Lista temporal para almacenar elementos que no coinciden con el ID específico
        List<OpportunityLineItem> listaTemporal = new List<OpportunityLineItem>();

        // Lista ordenada
        List<OpportunityLineItem> listaOrdenada = new List<OpportunityLineItem>();

        // Recorre la lista original y separa los elementos
        for (OpportunityLineItem obj : oppLine){
            if (obj.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c){
                mb = mb + 1;
            } else{
                normal = normal + 1;
            }
            obj.Product2.ProductCode = addSpacesEveryTenCharacters(obj.Product2.ProductCode);
            if (obj.Id == recordId){

                listaOrdenada.add(obj); // Agrega el elemento con el ID específico al principio
            } else{
                listaTemporal.add(obj); // Agrega los demás elementos a la lista temporal
            }
        }

        // Agrega los elementos restantes a la lista ordenada
        listaOrdenada.addAll(listaTemporal);

        // Ahora listaOrdenada contiene los elementos ordenados con el ID específico al principio
        oppLine = listaOrdenada;

        // Lista para almacenar los resultados
        List<consolidado> consolidadoList = new List<consolidado>();

        // Llenar el wrapper con los resultados de la consulta
        for (OpportunityLineItem ql : oppLine){
            String stageName = '';
            if (ql.Opportunity.StageName == 'Plan de Obra'){
                stageName = 'En convenio';
            } else if (ql.Opportunity.StageName == 'Acuerdo / Convenio'){
                stageName = 'Cotización';
            }
            consolidado producto = new consolidado();
            producto.a1Producto_codigo = (ql.Product2.ProductCode != null) ? ql.Product2.ProductCode : '';
            producto.a2Producto = (ql.SBQQ__QuoteLine__r.SBQQ__ProductName__c != null) ? ql.SBQQ__QuoteLine__r.SBQQ__ProductName__c : '';
            producto.a3Unidad_de_medida = (ql.SBQQ__QuoteLine__r.INT_Unidad_Medida__c != null) ? String.valueOf(ql.SBQQ__QuoteLine__r.INT_Unidad_Medida__c) : '';
            producto.a4Cantidad = ql.Quantity + '';
            producto.a5Precio_de_lista = (ql.SBQQ__QuoteLine__r.Precio_de_Lista_MB__c != null) ? '$' + String.valueOf(ql.SBQQ__QuoteLine__r.Precio_de_Lista_MB__c) : '$ 0';
            producto.a6Porcentaje_de_descuento = (ql.SBQQ__QuoteLine__r.SBQQ__TotalDiscountRate__c != null) ? String.valueOf(ql.SBQQ__QuoteLine__r.SBQQ__TotalDiscountRate__c / 1) + '%' : '';
            producto.a70Precio_proyecto_unidad_de_venta = (ql.SBQQ__QuoteLine__r.Precio_Proyecto_Unidad_de_Venta_MB__c != null) ? '$' + String.valueOf(ql.SBQQ__QuoteLine__r.Precio_Proyecto_Unidad_de_Venta_MB__c) : '';
            producto.a71Precio_proyecto_por_m2 = (ql.SBQQ__QuoteLine__r.INT_Precio_unitario_por_metro__c != null) ? '$' + String.valueOf(ql.SBQQ__QuoteLine__r.INT_Precio_unitario_por_metro__c) : '';
            producto.a8Total_proyecto = (ql.SBQQ__QuoteLine__r.Total_proyecto_MB__c != null) ? '$' + String.valueOf(ql.SBQQ__QuoteLine__r.Total_proyecto_MB__c) : '$ 0';
            producto.a90Oportunidad = (recordId == ql.OpportunityId) ? 'Principal' : 'Relacionada';
            producto.a91Nombre_de_Oportunidad = (ql.Opportunity.Name != null) ? String.valueOf(ql.Opportunity.Name) : '';
            producto.a92Fecha_inicio = (ql.Opportunity.INT_Fecha_inicio__c != null) ? ql.Opportunity.INT_Fecha_inicio__c.format() : '';
            producto.a93Fecha_fin = (ql.Opportunity.CloseDate != null) ? ql.Opportunity.CloseDate.format() : '';
            producto.a94Negociacion = StageName;
            consolidadoList.add(producto);
        }
        return consolidadoList;
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String recordId){
        Opportunity oppItem = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c, ContactId
                               FROM Opportunity
                               WHERE Id = :recordId];

        if (!(String.isBlank(oppItem.Oportunidad_Relacionada__c))){
            recordId = oppItem.Oportunidad_Relacionada__c;
            System.debug(recordId);
        }

        oppItem = [SELECT Id, Name, StageName, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c, Account.Name, ContactId
                   FROM Opportunity
                   WHERE Id = :recordId];
        if (oppItem.ContactId != null){
            Contact contact = [SELECT Id, Name
                               FROM Contact
                               WHERE Id = :oppItem.ContactId];
            oppItem.Description = contact.Name;
        }

        return oppItem;
    }

    @AuraEnabled
    public static String getTipo(String recordId){
        String tipos;
        System.debug(recordId);
        Integer mb = 0;
        Integer normal = 0;
        Opportunity oppRecord = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c
                                 FROM Opportunity
                                 WHERE Id = :recordId];

        if (!(String.isBlank(oppRecord.Oportunidad_Relacionada__c))){
            recordId = oppRecord.Oportunidad_Relacionada__c;
            System.debug(recordId);
        }

        oppRecord = [SELECT Id, Name, INT_Id_Convenio__c, INT_Id_Convenio_migrado__c, CloseDate, INT_Fecha_inicio__c, Oportunidad_Relacionada__c, ContactId, AccountId
                     FROM Opportunity
                     WHERE Id = :recordId];

        // Consulta SOQL
        List<OpportunityLineItem> oppLine = [SELECT Id, Name, OpportunityId, Opportunity.Name, Opportunity.CloseDate, Opportunity.INT_Fecha_inicio__c, ProductCode, SBQQ__QuoteLine__r.SBQQ__Product__r.INT_Imagen_URL__c, SBQQ__QuoteLine__r.SBQQ__ProductName__c, SBQQ__QuoteLine__r.INT_Unidad_Medida__c, Quantity, SBQQ__QuoteLine__r.Precio_de_Lista_MB__c, SBQQ__QuoteLine__r.SBQQ__TotalDiscountRate__c, SBQQ__QuoteLine__r.INT_Precio_unitario_por_metro__c, SBQQ__QuoteLine__r.Precio_Proyecto_Unidad_de_Venta_MB__c, SBQQ__QuoteLine__r.Total_proyecto_MB__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Product2.ProductCode
                                             FROM OpportunityLineItem
                                             WHERE OpportunityId IN (SELECT Id
                                                                     FROM Opportunity
                                                                     WHERE (Oportunidad_Relacionada__r.Id = :recordId OR Id = :recordId) AND StageName = 'Plan de Obra')
                                             ORDER BY OpportunityId];


        // Recorre la lista original y separa los elementos
        for (OpportunityLineItem obj : oppLine){
            if (obj.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c){
                mb = mb + 1;
            } else{
                normal = normal + 1;
            }
        }
        if (normal == 0 && mb != 0){
            tipos = 'MB';
        } else if (mb == 0 && normal != 0){
            tipos = 'Normal';
        } else if (normal != 0 && mb != 0){
            tipos = 'mixta';
        }

        return tipos;
    }

}