@RestResource(urlMapping='/obtainOpportunityObra/*')
global class OpportunityRestResource {
    
    @HttpPost
    global static void getOpportunity() {
        Map<String, Object> response = new Map<String, Object>();
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        Map<Id, List<OpportunityContactRole>> mapOppContactRole = new Map<Id, List<OpportunityContactRole>>();
        Map<Id, List<OpportunityLineItem>> mapOppLineItem = new Map<Id, List<OpportunityLineItem>>();
        Map<Id, List<Calendario_de_Consumo__c>> mapOppLineCalend = new Map<Id, List<Calendario_de_Consumo__c>>();
        List<Calendario_de_Consumo__c> listCalend = new List<Calendario_de_Consumo__c>();
        List<Oportunidad> listOportunidad = new List<Oportunidad>();

        Set<String> stIdConvenio = new Set<String>();
        Map<String, String> mpChildsOpps = new Map<String, String>();
        
        RestRequest request = RestContext.request;
        String jsonInput = request.requestBody.toString();
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        String opportunityIdString = (String) data.get('OpportunityId');
        String opportunityIdConvenio = (String) data.get('IdConvenio');
        
        System.debug('opportunityIdString ' + opportunityIdString);
        if((String.isBlank(opportunityIdString) || opportunityIdString == '') && (String.isBlank(opportunityIdConvenio) || opportunityIdConvenio == '')){
            response.put('Exception: ', 'OpportunityId or IdConvenio is required.');
        }else{
            List<String> lstRes = OpportunityRestResource.getIdParentOpp(opportunityIdString, opportunityIdConvenio);
            opportunityIdString = lstRes[0];
            opportunityIdConvenio = lstRes[1];
        }
        
        if(opportunityIdString != '' || opportunityIdConvenio != ''){
            String opportunityId = '';//Id.valueOf(opportunityIdString);
			// campo INT_CP__c removido del query            
            for(Opportunity iOpp : [SELECT	Id, Name, INT_Opp_Principal__c, INT_Opp_Principal__r.Name, INT_Ejecutivo_Franquicia__c, Description, INT_Moneda__c,
                                    Account.Name, Account.INT_Tipo_Cuenta__c, Account.INT_Subtipo_Cuenta__c, Account.Phone, INT_Fecha_inicio__c, CloseDate, 
                                    INT_Numero_Franquicia__c, INT_Ejecutivo_Franquicia_Cruzada__c, INT_NumeroMunicipio__c, INT_NumeroMunicipioCruzada__c,
                                    INT_Calle__c, INT_CondicionComercial__c, INT_Comentarios__c, CurrencyIsoCode, Owner.Name, Owner.Alias_Sinter__c, Pricebook2Id,
                                    INT_NumExt__c, INT_NumInt__c, INT_Ubicacion__c, CreatedDate, LastModifiedDate, INT_Id_Convenio__c, Constructora__r.Name, Constructora__r.INT_Subtipo_Cuenta__c, Constructora__r.Phone, Oportunidad_Relacionada__c,
                                        (SELECT Id, Name, INT_Opp_Principal__c, INT_Opp_Principal__r.Name, INT_Ejecutivo_Franquicia__c, Description, INT_Moneda__c,
                                        Account.Name, Account.INT_Tipo_Cuenta__c, Account.INT_Subtipo_Cuenta__c, Account.Phone, INT_Fecha_inicio__c, CloseDate, 
                                        INT_Numero_Franquicia__c, INT_Ejecutivo_Franquicia_Cruzada__c, INT_NumeroMunicipio__c, INT_NumeroMunicipioCruzada__c,
                                        INT_Calle__c, INT_CondicionComercial__c, INT_Comentarios__c, CurrencyIsoCode, Owner.Name, Owner.Alias_Sinter__c, Pricebook2Id,
                                        INT_NumExt__c, INT_NumInt__c, INT_Ubicacion__c, CreatedDate, LastModifiedDate, INT_Id_Convenio__c, Constructora__r.Name, Constructora__r.INT_Subtipo_Cuenta__c, Constructora__r.Phone, Oportunidad_Relacionada__c
                                        FROM OportunidadesRelacionadas__r)
                                    FROM Opportunity 
                                    WHERE (Id =: opportunityIdString OR INT_Id_Convenio__c =: opportunityIdConvenio)
                                    AND StageName = 'Plan de Obra'
                                    /*AND RecordType.DeveloperName = 'Obra_Local'*/])
            {
                mapOpportunity.put(iOpp.Id, iOpp);
                mapOppLineItem.put(iOpp.Id, new List<OpportunityLineItem>());
                mapOppContactRole.put(iOpp.Id, new List<OpportunityContactRole>());
                if(opportunityId == '' || opportunityId == null){
                    opportunityId = iOpp.Id;
                }
                stIdConvenio.add(iOpp.INT_Id_Convenio__c);
                //Agregamos las Opps Hijas a las listas y mapas
                for(Opportunity currentChildOpp : iOpp.OportunidadesRelacionadas__r){
                    mapOpportunity.put(currentChildOpp.Id, currentChildOpp);
                    mapOppLineItem.put(currentChildOpp.Id, new List<OpportunityLineItem>());
                    mapOppContactRole.put(currentChildOpp.Id, new List<OpportunityContactRole>());
                    mpChildsOpps.put(currentChildOpp.Id, currentChildOpp.Oportunidad_Relacionada__c);
                    stIdConvenio.add(currentChildOpp.INT_Id_Convenio__c);
                }
            }
            
            for(OpportunityContactRole iOpp : [SELECT Id, Contact.Name, OpportunityId, Role 
                                               FROM OpportunityContactRole 
                                               WHERE (OpportunityId IN: mapOpportunity.keySet() OR Opportunity.INT_Id_Convenio__c IN: stIdConvenio)])
            {
                if(mapOppContactRole.get(iOpp.OpportunityId) != null){
                    mapOppContactRole.get(iOpp.OpportunityId).add(iOpp);
                }
            }
            
            //traer precio base
            for(OpportunityLineItem iOppLine : [SELECT Id, Product2.ProductCode, Quantity, SBQQ__QuoteLine__r.PRECIO_BASE__c , SBQQ__QuoteLine__r.PRECIO_FRANQ__c , UnitPrice, TotalPrice, Discount, OpportunityId, Product2Id, INT_Descuento__c, Precio_de_venta__c
                                                FROM OpportunityLineItem 
                                                WHERE (OpportunityId IN: mapOpportunity.keySet() OR Opportunity.INT_Id_Convenio__c IN: stIdConvenio)])
            {
                if(mapOppLineItem.get(iOppLine.OpportunityId) != null){
                    mapOppLineItem.get(iOppLine.OpportunityId).add(iOppLine);
                }
                mapOppLineCalend.put(iOppLine.Product2Id, new List<Calendario_de_Consumo__c>());
            }
            
            for(Calendario_de_Consumo__c iCC : [SELECT Id, INT_Cantidad__c, INT_Name_Periodo__c, INT_Ejercicio__c, INT_Mes__c, INT_Producto__c, INT_Producto2__c 
                                                FROM Calendario_de_Consumo__c
                                                WHERE (INT_Oportunidad__c IN: mapOpportunity.keySet() OR INT_Oportunidad__c IN: stIdConvenio) 
                                                AND INT_Producto2__c =: mapOppLineCalend.keySet()])
            {
                if(mapOppLineCalend.get(iCC.INT_Producto2__c) != null){
                    mapOppLineCalend.get(iCC.INT_Producto2__c).add(iCC);
                }
            }
            
            if(mapOpportunity != null && !mapOpportunity.isEmpty()){
                for(String idOpp : mapOpportunity.keySet()){
                    Oportunidad opp = new Oportunidad();
                    opp.id_oportunidad = mapOpportunity.get(idOpp).INT_Opp_Principal__c != null ? mapOpportunity.get(idOpp).INT_Opp_Principal__c : mapOpportunity.get(idOpp).Id;
                    opp.nombre_oportunidad = mapOpportunity.get(idOpp).INT_Opp_Principal__r.Name != null ? mapOpportunity.get(idOpp).INT_Opp_Principal__r.Name : mapOpportunity.get(idOpp).Name;
                    opp.lista_precio = mapOpportunity.get(idOpp).Pricebook2Id;
                    //opp.ejecutivo = mapOpportunity.get(idOpp).INT_Ejecutivo_Franquicia__c;
                    //opp.ejecutivo = mapOpportunity.get(idOpp).Owner.Name;
                    opp.ejecutivo = mapOpportunity.get(idOpp).Owner.Alias_Sinter__c;
                    opp.ejecutivoCruzado = mapOpportunity.get(idOpp).INT_Ejecutivo_Franquicia_Cruzada__c;
                    opp.observaciones = mapOpportunity.get(idOpp).Description;
                    opp.moneda = mapOpportunity.get(idOpp).INT_Moneda__c != null ? mapOpportunity.get(idOpp).INT_Moneda__c : mapOpportunity.get(idOpp).CurrencyIsoCode;
                    
                    opp.fecha_creacion = mapOpportunity.get(idOpp).CreatedDate;
                    opp.fecha_modificacion = mapOpportunity.get(idOpp).LastModifiedDate;
                    opp.id_convenio = mapOpportunity.get(idOpp).INT_Id_Convenio__c;

                    //Añadimos el tipo de Opp y su Id Padre
                    opp.tipo_oportunidad = (mpChildsOpps.containsKey(idOpp)) ? 'Secundaria': 'Principal';
                    opp.id_opp_principal = (mpChildsOpps.containsKey(idOpp)) ? mpChildsOpps.get(idOpp): '';
                    
                    List<Cliente> listCliente = new List<Cliente>();
                    Cliente icliente = new Cliente();
                    System.debug(mapOpportunity.get(idOpp).Account.Name);
                    icliente.nombre = mapOpportunity.get(idOpp).Account.Name;
                    listCliente.add(icliente);
                    opp.cliente = listCliente;
                    
                    List<Constructora> listConstructora = new List<Constructora>();
                    Constructora iconstructora = new Constructora();
                    iconstructora.nombre = mapOpportunity.get(idOpp).Constructora__r.Name;//Tipo de cuenta antes
                    iconstructora.subconstructora = mapOpportunity.get(idOpp).Constructora__r.INT_Subtipo_Cuenta__c;
                    iconstructora.telefono = mapOpportunity.get(idOpp).Constructora__r.Phone;
                    listConstructora.add(iconstructora);
                    opp.constructora = listConstructora;
                    
                    List<Obra> listObra = new List<Obra>();
                    Obra iobra = new Obra();
                    iobra.fecha_inicio = mapOpportunity.get(idOpp).INT_Fecha_inicio__c;
                    iobra.fecha_fin = mapOpportunity.get(idOpp).CloseDate;
                    iobra.domicilio = mapOpportunity.get(idOpp).INT_Ubicacion__c;
                    iobra.mponum = mapOpportunity.get(idOpp).INT_NumeroMunicipio__c;
                    iobra.franquicia = mapOpportunity.get(idOpp).INT_Numero_Franquicia__c;
                    
                    List<Contacto> listContacto = new List<Contacto>();
                    if(mapOppContactRole != null && !mapOppContactRole.isEmpty()){
                        for(OpportunityContactRole iOppRole : mapOppContactRole.get(idOpp)){
                            Contacto icontacto = new Contacto();
                            icontacto.nombre = iOppRole.Contact.Name;
                            icontacto.role = iOppRole.Role;
                            listContacto.add(icontacto);
                        }
                        iobra.contactos = listContacto;
                    }
                    listObra.add(iobra);
                    opp.obra = listObra;
                    
                    List<CondicionComercial> listConCom = new List<CondicionComercial>();
                    CondicionComercial condComercial = new CondicionComercial();
                    condComercial.condicion = mapOpportunity.get(idOpp).INT_CondicionComercial__c;
                    condComercial.comentarios = mapOpportunity.get(idOpp).INT_Comentarios__c;
                    listConCom.add(condComercial);
                    opp.condiciones_comerciales = listConCom;
                    
                    List<Articulo> listArticulo = new List<Articulo>();
                    List<Consumo> listConsumo = new List<Consumo>();
                    if(mapOppLineItem != null && !mapOppLineItem.isEmpty()){
                        for(OpportunityLineItem iOppline : mapOppLineItem.get(idOpp)){
                            Articulo iarticulo = new Articulo();
                            iarticulo.sku = iOppline.Product2.ProductCode;
                            iarticulo.cantidad = iOppline.Quantity;
                            //iarticulo.precio = iOppline.UnitPrice;
                            iarticulo.precio = iOppline.Precio_de_venta__c;
                            iarticulo.precioTotal = iOppline.TotalPrice;
                            //iarticulo.descuento = iOppline.Discount;
                            iarticulo.descuento = iOppline.INT_Descuento__c;
                            //añadir precio base
                            iarticulo.precioBase = iOppline.SBQQ__QuoteLine__r.PRECIO_BASE__c;
                            iarticulo.precioFranquicia = iOppline.SBQQ__QuoteLine__r.PRECIO_FRANQ__c;
                            if(mapOppLineCalend != null && !mapOppLineCalend.isEmpty()){
                                for(Calendario_de_Consumo__c iCC : mapOppLineCalend.get(iOppline.Product2Id)){
                                    if(iCC.INT_Producto2__c == iOppline.Product2Id){
                                        Consumo iconsumo = new Consumo();
                                        iconsumo.cantidad = iCC.INT_Cantidad__c != null ? iCC.INT_Cantidad__c : 0;
                                        iconsumo.ejercicio = iCC.INT_Ejercicio__c != null ? iCC.INT_Ejercicio__c : 0;
                                        iconsumo.mes = iCC.INT_Mes__c != null ? iCC.INT_Mes__c : 0;
                                        listConsumo.add(iconsumo);
                                        iarticulo.consumo = listConsumo;
                                    }
                                }
                            }
                            listArticulo.add(iarticulo);
                            listConsumo = new List<Consumo>();                    
                        }
                        opp.articulos = listArticulo;
                    }
                    listOportunidad.add(opp);
                }
            }
        }
        
        response.put('Opportunity', listOportunidad);
        if(listOportunidad.isEmpty() && opportunityIdString != ''){
            response.put('message', 'No se ha encontrado una oportunidad del tipo Obra con el Id proporcionado');
        }
        String jsonString = JSON.serialize(response);
        System.debug(jsonString);
        if(!test.isRunningTest()){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonString);
        }
    }

    public static List<String> getIdParentOpp(String idOpp, String idConv){
        List<String> response = new List<String>();
        
        try{
            Opportunity objOpp = [SELECT Id, INT_Id_Convenio__c, Oportunidad_Relacionada__c, Oportunidad_Relacionada__r.INT_Id_Convenio__c FROM Opportunity WHERE (Id =: idOpp AND Id != null) OR (INT_Id_Convenio__c =: idConv AND INT_Id_Convenio__c != null) LIMIT 1];
            String idOppFinal = (String.isBlank(objOpp.Oportunidad_Relacionada__c)) ? objOpp.Id : objOpp.Oportunidad_Relacionada__c;
            String idConFinal = (String.isBlank(objOpp.Oportunidad_Relacionada__c)) ? objOpp.INT_Id_Convenio__c : objOpp.Oportunidad_Relacionada__r.INT_Id_Convenio__c;

            response.add(idOppFinal);
            response.add(idConFinal);
        }catch(Exception e){
            response.add(idOpp);
            response.add(idConv);
        }

        return response;
    }
    
    public class Oportunidad {
        public String id_oportunidad;
        public String tipo_oportunidad;
        public String id_opp_principal;
        public String nombre_oportunidad;
        public String lista_precio;
        public String ejecutivo;
        public String ejecutivoCruzado;
        public String observaciones;
        public String moneda;
        public List<Cliente> cliente;
        public List<Constructora> constructora;
        public List<Obra> obra;
        public List<CondicionComercial> condiciones_comerciales;
        public List<Articulo> articulos;
        public DateTime fecha_creacion;
        public DateTime fecha_modificacion;
        public String id_convenio;
    }
    
    public class Cliente {
        public String nombre;
    }
    
    public class Constructora {
        public String nombre;
        public String subconstructora;
        public String telefono;
    }
    
    public class Obra {
        public Date fecha_inicio;
        public Date fecha_fin;
        public String domicilio;
        public List<Contacto> contactos;
        public Decimal mponum;
        public Decimal franquicia;
    }
    
    public class Contacto{
        public String nombre;
        public String role;
    }
    
    public class CondicionComercial {
        public String condicion;
        public String comentarios;
    }
    
    public class Articulo {
        public String sku;
        public Decimal cantidad;
        public Decimal precio;
        public Decimal precioTotal;
        public Decimal descuento;
        public Decimal precioBase;
        public Decimal precioFranquicia;
        public List<Consumo> consumo;
    }
    
    public class Consumo {
        public Decimal cantidad;
        public Decimal ejercicio;
        public Decimal mes;
    }   
}