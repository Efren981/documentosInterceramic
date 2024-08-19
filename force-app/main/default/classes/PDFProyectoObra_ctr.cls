public class PDFProyectoObra_ctr{
    
    //Cuerpo del PDF
    public String sName{ get; set; }

    public String sInterceramicData1{ get; set; }

    public String sInterceramicData2{ get; set; }

    public String sInterceramicData3{ get; set; }

    public String sContactoPrincipal{ get; set; }

    public String sEncabezado{ get; set; }

    public String sCondicion1{ get; set; }

    public String sCondicion2{ get; set; }

    public String sCondicion3{ get; set; }

    public String sCondicion4{ get; set; }

    public String sCondicion5{ get; set; }

    public String sCondicion6{ get; set; }

    public String sCondicion7{ get; set; }

    public String sFirmaFecha{ get; set; }

    public String sAnexoA{ get; set; }

    public String sAnexoAContacto{ get; set; }

    public String sAnexoACondiciones{ get; set; }

    public String sAnexoB{ get; set; }

    public String sNombreContactoFirma{ get; set; }

    public String sNombreContactoCargo{ get; set; }

    public String sNombreContactoTelefono{ get; set; }

    public String sNombreContactoCelular{ get; set; }

    public String sNombreContactoCorreo{ get; set; }

    public String sNombreCuenta{ get; set; }

    public String sDireccionCuenta{ get; set; }

    public String sCiudad{ get; set; }

    public String sDireccionOpp{ get; set; }

    public String sConvenioId{ get; set; }

    public String sNombreEjecutivo{ get; set; }

    public String sNombrePerfil{ get; set; }

    public String sEjecutivoTelefono{ get; set; }

    public String sEjecutivoCelular{ get; set; }

    public String sEjecutivoCorreo{ get; set; }

    //Valores de la oportunidad
    public String sNombreOportunidad{ get; set; }

    public Boolean sListaPreciosPenin{ get; set; }

    public String sNombredeCuenta{ get; set; }

    public List<OpportunityLineItem> listOppLineItem{ get; set; }

    public List<SBQQ__QuoteLine__c> listQuoteLineItem{ get; set; }

    public Double dPrecioTotal{ get; set; }
    public Double dPrecioTotalPen{ get; set; }

    public Map<Id, OpportunityLineItem> mapOppLine{ get; set; }

    public Map<String, Map<Id, List<Calendario_de_Consumo__c>>> mapOppCc{ get; set; }

    public Map<String, Map<Id, Decimal>> OppLineTotal{ get; set; }

    public Map<String, Map<Id, Decimal>> OppLineMetrosTotal{ get; set; }

    public Set<String> setEjercicios{ get; set; }

    public List<Calendario_de_Consumo__c> listCalendConsu{ get; set; }

    public Map<Id, Decimal> mapCalendConsCantTotal{ get; set; }

    public Map<Id, Decimal> mapCalendConsMtsTotal{ get; set; }

    public PDFProyectoObra_ctr(){
        try{

            String sRegistroId = ApexPages.currentPage().getParameters().get('id');
            System.debug('sRegistroId ' + sRegistroId);
            String sAccountId;
            List<OpportunityLineItem> listOppLine = new List<OpportunityLineItem>();
            List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();

            Map<Id, OpportunityLineItem> OppLine = new Map<Id, OpportunityLineItem>();
            Map<String, Map<Id, List<Calendario_de_Consumo__c>>> OppCc = new Map<String, Map<Id, List<Calendario_de_Consumo__c>>>();

            Set<String> setEjercicio = new Set<String>();
            Set<Id> setOppline = new Set<Id>();
            Decimal decPrecioTotal = 0;
            Decimal decPrecioTotalPen = 0;
            Map<Id, Decimal> mapCcsCantTotal = new Map<Id, Decimal>();
            Map<Id, Decimal> mapCcsMtsTotal = new Map<Id, Decimal>();
            String sPrimaryQuote;

            for (Carta__c iCarta : [SELECT Id, Name, INT_Encabezado__c, INT_Condicion_1__c, INT_Condicion_2__c, INT_Condicion_3__c, INT_Condicion_4__c, INT_Condicion_5__c, INT_Condicion_6__c, INT_Condicion_7__c, INT_Firma_y_Fecha__c, INT_Anexo_A__c, INT_Anexo_A_contacto__c, INT_Anexo_A_condiciones__c, INT_Anexo_B__c, ContactoPrincipal__c, InterceramicData1__c, InterceramicData2__c, InterceramicData3__c
                                    FROM Carta__c
                                    WHERE Name = 'CARTA DE TÉRMINOS Y CONDICIONES DE DESCUENTOS']){

                sInterceramicData1 = iCarta.InterceramicData1__c;
                sInterceramicData2 = iCarta.InterceramicData2__c;
                sInterceramicData3 = iCarta.InterceramicData3__c;

                sName = iCarta.Name;
                sContactoPrincipal = iCarta.ContactoPrincipal__c;
                sEncabezado = iCarta.INT_Encabezado__c;
                sCondicion1 = iCarta.INT_Condicion_1__c;
                sCondicion1 = sCondicion1.replace('1. MATERIAL.', '<span class="bold-text">1. MATERIAL.</span>');

                sCondicion2 = iCarta.INT_Condicion_2__c;
                sCondicion2 = sCondicion2.replace('2. ENTREGA.', '<p><span class="bold-text">2. ENTREGA.</span>');
                sCondicion2 = sCondicion2.replace('semanas.', 'semanas.<p/>');
                sCondicion2 = sCondicion2.replace('El Cliente', '<p>El Cliente');
                sCondicion2 = sCondicion2.replace('productos.', 'productos.<p/>');
                sCondicion2 = sCondicion2.replace('Todos los', '<p>Todos los');
                sCondicion2 = sCondicion2.replace('la entrega.', 'la entrega.<p/>');
                sCondicion2 = sCondicion2.replace('Para cada', '<p>Para cada');
                sCondicion2 = sCondicion2.replace('de entrega.', 'de entrega.<p/>');

                sCondicion3 = iCarta.INT_Condicion_3__c;
                sCondicion3 = sCondicion3.replace('3. DESCUENTOS.', '<p><span class="bold-text">3. DESCUENTOS.</span>');
                sCondicion3 = sCondicion3.replace('2023.', '2023.</p>');
                sCondicion3 = sCondicion3.replaceAll('Para', '<p>Para');
                sCondicion3 = sCondicion3.replace('consumos.', 'consumos.</p>');
                sCondicion3 = sCondicion3.replace('CONVENIO', '<span class="bold-text">CONVENIO</span>');

                sCondicion4 = iCarta.INT_Condicion_4__c;
                sCondicion4 = sCondicion4.replace('4. PROPUESTA INTEGRAL.', '<span class="bold-text">4. PROPUESTA INTEGRAL.</span>');

                sCondicion5 = iCarta.INT_Condicion_5__c;
                sCondicion5 = sCondicion5.replace('5. VIGENCIA.', '<span class="bold-text">5. VIGENCIA.</span>');

                sCondicion6 = iCarta.INT_Condicion_6__c;
                sCondicion6 = sCondicion6.replace('6. INCUMPLIMIENTO.', '<span class="bold-text">6. INCUMPLIMIENTO.</span>');

                sCondicion7 = iCarta.INT_Condicion_7__c;
                sCondicion7 = sCondicion7.replace('7. CONFIDENCIALIDAD.', '<span class="bold-text">7. CONFIDENCIALIDAD.</span>');

                sFirmaFecha = iCarta.INT_Firma_y_Fecha__c;
                sAnexoA = iCarta.INT_Anexo_A__c;
                sAnexoAContacto = iCarta.INT_Anexo_A_contacto__c;
                sAnexoACondiciones = iCarta.INT_Anexo_A_condiciones__c;
                sAnexoB = iCarta.INT_Anexo_B__c;
            }

            for (Opportunity iOpp : [SELECT Id, Name, Account.Name, AccountId, SBQQ__PrimaryQuote__c, Amount, Account.INT_Calle__c, Account.INT_NumExt__c, Account.INT_Colonia__r.Name, Account.INT_Ciudad__r.Name, Account.INT_Estado__r.Name, INT_Ciudad__r.Name, INT_Estado__r.Name, Owner.Name, Owner.Profile.Name, Owner.Phone, Owner.MobilePhone, Owner.Email, INT_Id_Convenio__c, Pricebook2.Name
                                     FROM Opportunity
                                     WHERE Id = :sRegistroId]){
                sListaPreciosPenin = (iOpp.Pricebook2.Name == 'PENINSULA SIN IVA') ? false : true;
                sNombreEjecutivo = iOpp.Owner.Name;
                sNombrePerfil = iOpp.Owner.Profile.Name;
                sEjecutivoTelefono = iOpp.Owner.Phone;
                sEjecutivoCelular = iOpp.Owner.MobilePhone;
                sEjecutivoCorreo = iOpp.Owner.Email;
                sNombreOportunidad = iOpp.Name;
                sNombredeCuenta = iOpp.Account.Name;
                sNombreCuenta = iOpp.Account.Name;
                String sCalle = iOpp.Account.INT_Calle__c != null ? iOpp.Account.INT_Calle__c : '';
                String sNumeroCalle = iOpp.Account.INT_NumExt__c != null ? iOpp.Account.INT_NumExt__c : '';
                String sColonia = iOpp.Account.INT_Colonia__r.Name != null ? iOpp.Account.INT_Colonia__r.Name : '';
                sCiudad = iOpp.Account.INT_Ciudad__r.Name != null ? iOpp.Account.INT_Ciudad__r.Name : '';
                String sEstado = iOpp.Account.INT_Estado__r.Name != null ? iOpp.Account.INT_Estado__r.Name : '';
                sDireccionCuenta = sCalle + ' ' + sNumeroCalle + ', ' + sColonia + ', ' + sCiudad + ', ' + sEstado + '.';
                sAccountId = iOpp.AccountId;
                sPrimaryQuote = iOpp.SBQQ__PrimaryQuote__c;
                
                sEncabezado = sEncabezado.replace('NOMBRE_CUENTA', '<span class="bold-text">' + sNombredeCuenta + '</span>');
                sEncabezado = sEncabezado.replace('OPORTUNIDAD', '<span class="bold-text">' + sNombreOportunidad + '</span>');
                String sCiudadOpp = iOpp.INT_Ciudad__r.Name != null ? iOpp.INT_Ciudad__r.Name : '';
                String sEstadoOpp = iOpp.INT_Estado__r.Name != null ? iOpp.INT_Estado__r.Name : '';
                sDireccionOpp = sCiudadOpp != '' ? sCiudadOpp + ', ' + sEstadoOpp : sEstadoOpp;
                sConvenioId = iOpp.INT_Id_Convenio__c != null ? iOpp.INT_Id_Convenio__c : '';
                if (sConvenioId != ''){
                    sCondicion3 = sCondicion3.replace('CONVENIO', sConvenioId);
                }
            }

            for (OpportunityContactRole currentOCR : [SELECT Id, OpportunityId, ContactId, Contact.Name, Contact.Title, Contact.Phone, Contact.MobilePhone, Contact.Email, IsPrimary
                                                      FROM OpportunityContactRole
                                                      WHERE OpportunityId = :sRegistroId AND IsPrimary = true
                                                      LIMIT 1]){
                sNombreContactoFirma = currentOCR.Contact.Name;
                sNombreContactoCargo = currentOCR.Contact.Title != null ? currentOCR.Contact.Title : '';
                sNombreContactoTelefono = currentOCR.Contact.Phone;
                sNombreContactoCelular = currentOCR.Contact.MobilePhone;
                sNombreContactoCorreo = currentOCR.Contact.Email;
                sContactoPrincipal = sContactoPrincipal.replace('CONTACTO_PRINCIPAL', currentOCR.Contact.Name);
            }

            //Falta campo descuento
            for (OpportunityLineItem iOppl : [SELECT Id, Product2.Name, Product2.UnidadVenta__c, Quantity, UnitPrice, TotalPrice
                                              FROM OpportunityLineItem
                                              WHERE OpportunityId = :sRegistroId]){
                listOppLine.add(iOppl);
                setOppline.add(iOppl.Id);
                OppLine.put(iOppl.Id, iOppl);
                //OppCc.put(iOppl.Id, new List<Calendario_de_Consumo__c>());
            }

            for (SBQQ__QuoteLine__c iQuoteLine : [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.UnidadVenta__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, SBQQ__ListTotal__c, SBQQ__Discount__c, SBQQ__Quote__r.SBQQ__NetAmount__c, SBQQ__NetTotal__c, INT_Precio_unitario_por_metro__c, SBQQ__NetPrice__c, List_Price_MB__c, Precio_de_Lista_MB__c, Porcentaje_Descuento_MB__c, Precio_Proyecto_Unidad_de_Venta_MB__c, Total_proyecto_MB__c, Precio_unitario_de_lista_sin_Iva__c, Total_neto_peninsula__c, Precio_proyecto_unidad_de_vta_peninsula__c, Precio_unitario_de_lista_peninsula__c, Precio_unitario_por_metro_peninsula__c
                                                  FROM SBQQ__QuoteLine__c
                                                  WHERE SBQQ__Quote__c = :sPrimaryQuote]){
                listQuoteLine.add(iQuoteLine);

                //decPrecioTotal = iQuoteLine.SBQQ__Quote__r.SBQQ__NetAmount__c;
                decPrecioTotal = decPrecioTotal + iQuoteLine.Total_proyecto_MB__c;
                decPrecioTotalPen = decPrecioTotalPen + iQuoteLine.Total_neto_peninsula__c;
                //decPrecioTotal = decPrecioTotal + iQuoteLine.Total_proyecto_MB_flow__c;
            }

            dPrecioTotal = decPrecioTotal;
            dPrecioTotalPen = decPrecioTotalPen;
            listOppLineItem = listOppLine;
            listQuoteLineItem = listQuoteLine;

            Map<String, Map<Id, Decimal>> mapCantidadTotal = new Map<String, Map<Id, Decimal>>();
            Map<String, Map<Id, Decimal>> mapMetrosTotal = new Map<String, Map<Id, Decimal>>();

            for (Calendario_de_Consumo__c iCc : [SELECT Id, INT_Ejercicio__c, INT_Producto__c, INT_Producto__r.Product2.Name, INT_Producto2__c, INT_Nombre_Producto__c, INT_Mes__c, INT_Metros_Cuadrados__c, INT_Cantidad__c, INT_Oportunidad__c
                                                 FROM Calendario_de_Consumo__c
                                                 WHERE INT_Oportunidad__c = :sRegistroId
                                                 ORDER BY INT_Mes__c ASC]){
                OppCc.put(String.valueOf(iCc.INT_Ejercicio__c), new Map<Id, List<Calendario_de_Consumo__c>>());
                mapCantidadTotal.put(String.valueOf(iCc.INT_Ejercicio__c), new Map<Id, Decimal>());
                mapMetrosTotal.put(String.valueOf(iCc.INT_Ejercicio__c), new Map<Id, Decimal>());
            }

            for (Calendario_de_Consumo__c iCc : [SELECT Id, INT_Ejercicio__c, INT_Producto__c, INT_Producto__r.Product2.Name, INT_Producto2__c, INT_Nombre_Producto__c, INT_Mes__c, INT_Metros_Cuadrados__c, INT_Cantidad__c, INT_Oportunidad__c
                                                 FROM Calendario_de_Consumo__c
                                                 WHERE INT_Oportunidad__c = :sRegistroId
                                                 ORDER BY INT_Mes__c ASC]){
                if (iCc.INT_Producto__c != null){
                    OppCc.get(String.valueOf(iCc.INT_Ejercicio__c)).put(iCc.INT_Producto__c, new List<Calendario_de_Consumo__c>());

                    mapCantidadTotal.get(String.valueOf(iCc.INT_Ejercicio__c)).put(iCc.INT_Producto__c, 0);
                    mapMetrosTotal.get(String.valueOf(iCc.INT_Ejercicio__c)).put(iCc.INT_Producto__c, 0);
                }
            }

            for (Calendario_de_Consumo__c iCc : [SELECT Id, INT_Ejercicio__c, INT_Producto__c, INT_Producto__r.Product2.Name, INT_Producto2__c, INT_Nombre_Producto__c, INT_Mes__c, INT_Metros_Cuadrados__c, INT_Cantidad__c, INT_Oportunidad__c
                                                 FROM Calendario_de_Consumo__c
                                                 WHERE INT_Oportunidad__c = :sRegistroId
                                                 ORDER BY INT_Mes__c ASC]){
                if (iCc.INT_Producto__c != null){
                    OppCc.get(String.valueOf(iCc.INT_Ejercicio__c)).get(iCc.INT_Producto__c).add(iCc);

                    Map<Id, Decimal> ejercicioMap = mapCantidadTotal.get(String.valueOf(iCc.INT_Ejercicio__c));
                    Decimal existingTotal = ejercicioMap.containsKey(iCc.INT_Producto__c) ? ejercicioMap.get(iCc.INT_Producto__c) : 0;
                    Decimal newTotal = existingTotal + iCc.INT_Cantidad__c;
                    ejercicioMap.put(iCc.INT_Producto__c, newTotal);
                    mapCantidadTotal.put(String.valueOf(iCc.INT_Ejercicio__c), ejercicioMap);

                    Map<Id, Decimal> ejercicioMetrosMap = mapMetrosTotal.get(String.valueOf(iCc.INT_Ejercicio__c));
                    Decimal existingMetrosTotal = ejercicioMetrosMap.containsKey(iCc.INT_Producto__c) ? ejercicioMetrosMap.get(iCc.INT_Producto__c) : 0;
                    Decimal newMetrosTotal = existingMetrosTotal + iCc.INT_Metros_Cuadrados__c;
                    ejercicioMetrosMap.put(iCc.INT_Producto__c, newMetrosTotal);
                    mapMetrosTotal.put(String.valueOf(iCc.INT_Ejercicio__c), ejercicioMetrosMap);
                }
            }

            OppLineTotal = mapCantidadTotal;
            OppLineMetrosTotal = mapMetrosTotal;

            for (String iEjercicio : OppCc.keySet()){
                System.debug(iEjercicio);
                for (Id iProducto : OppCc.get(iEjercicio).keySet()){
                    System.debug(iProducto);
                    List<Calendario_de_Consumo__c> consumptionList = OppCc.get(iEjercicio).get(iProducto);
                    //Set<Decimal> existingMonths = new Set<Decimal>();
                    Map<Decimal, Calendario_de_Consumo__c> existingMonths = new Map<Decimal, Calendario_de_Consumo__c>();

                    for (Calendario_de_Consumo__c iCc : consumptionList){
                        existingMonths.put(iCc.INT_Mes__c, iCc);
                    }

                    List<Calendario_de_Consumo__c> newMonths = new List<Calendario_de_Consumo__c>();
                    for (Integer month = 1; month <= 12; month++){
                        if (!existingMonths.containsKey(month)){
                            Calendario_de_Consumo__c newConsumption = new Calendario_de_Consumo__c();
                            newConsumption.INT_Ejercicio__c = Decimal.valueOf(iEjercicio);
                            newConsumption.INT_Mes__c = month;
                            newConsumption.INT_Producto__c = iProducto;
                            newConsumption.INT_Cantidad__c = 0;
                            newConsumption.INT_Metros_Cuadrados__c = 0;

                            //OppCc.get(iEjercicio).get(iProducto).add(newConsumption);
                            newMonths.add(newConsumption);
                        } else{
                            newMonths.add(existingMonths.get(month));
                        }
                    }
                    OppCc.get(iEjercicio).get(iProducto).clear();
                    OppCc.get(iEjercicio).get(iProducto).addAll(newMonths);
                }
            }


            mapOppCc = OppCc;
            mapOppLine = OppLine;

        } catch (Exception e){
            System.debug(e);
        }
    }

}