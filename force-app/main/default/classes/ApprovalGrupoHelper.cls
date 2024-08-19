/**FREEWAY
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Clase Helper que contiene el proceso de agrupar las partidas por nivel y tipo.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Abraham Gudiño   <agudino@freewayconsulting.com>
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        20-09-2023
* @modified       
* @systemLayer    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            xxxxxxxxx@xxxxx.com
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class ApprovalGrupoHelper {
    static Map<String, Map<Double, Grupo_de_productos_a_aprobar__c>> mpGrupoProductosAprobarMB = new Map<String, Map<Double, Grupo_de_productos_a_aprobar__c>>();
    static Map<String, Map<Double, Grupo_de_productos_a_aprobar__c>> mpGrupoProductosAprobarNO = new Map<String, Map<Double, Grupo_de_productos_a_aprobar__c>>();
    static List<wrapperPartidas> lstAllWrapQuoteLine = new List<wrapperPartidas>();
    static List<Grupo_de_productos_a_aprobar__c> lstNuevoGruposProductosAprobar = new List<Grupo_de_productos_a_aprobar__c>();
    
    
    public static List<String> executeApprovalGroupProccess(String idQuote, List<SBQQ__QuoteLine__c> quoteLineItems, Boolean flagDiscontinuedFirstApproved){
        System.debug('ApprovalGrupoHelper:executeApprovalGroupProccess:INCIO');
        List<String> response = new List<String>();
        Boolean childOpp = false;
        Boolean errorProccess = false;
        Integer errorCode = 0;
        Map<String, List<Descuentos__mdt>> mpDescuentos  = new Map<String, List<Descuentos__mdt>>();
        Set<SBQQ__QuoteLine__c> stProductMBMixedNotPermited = new Set<SBQQ__QuoteLine__c>();
        Set<SBQQ__QuoteLine__c> stProductNotMeetMinimalAmount = new Set<SBQQ__QuoteLine__c>();
        Set<SBQQ__QuoteLine__c> stProductNOinQuoteMB = new Set<SBQQ__QuoteLine__c>();

        try{
            SBQQ__Quote__c quote = [SELECT id, name, SBQQ__ListAmount__c, Excepcion__c, SBQQ__PriceBook__r.Lista_MB__c, CreatedById, SBQQ__Opportunity2__r.Oportunidad_Relacionada__c, (SELECT Id, Name, Cotizacion__c, Nivel__c, Excepcion__c, Descontinuado__c, Tipo_de_producto__c, Aprobado__c, No_aprobado__c FROM Grupos_de_productos_a_aprobar__r WHERE Aprobado__c = false AND No_aprobado__c = false) FROM SBQQ__Quote__c WHERE id =: idQuote];
            System.debug('quote: ' + quote);
            //Si la Opp relacionada a la Opp esta vacia es una Opp Principal si no es una Opp Hija
            childOpp = (quote.SBQQ__Opportunity2__r.Oportunidad_Relacionada__c != null) ? true : false;
            //System.debug('mpDescuentos:SIZE: ' + mpDescuentos.size() + ', mpDescuentos: ' + mpDescuentos);

            //Llenamos el mapa con los grupos ya creados
            for(Grupo_de_productos_a_aprobar__c GPA : quote.Grupos_de_productos_a_aprobar__r){
                System.debug('inner obj: ' + GPA);
                if(GPA.Tipo_de_producto__c == 'MB'){
                    if(!mpGrupoProductosAprobarMB.containsKey('Exception')){
                        mpGrupoProductosAprobarMB.put('Exception', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                    }
                    
                    mpGrupoProductosAprobarMB.get('Exception').put(GPA.Nivel__c, GPA);
                }else if(GPA.Tipo_de_producto__c == 'NO'){
                    String gpaType = (GPA.Excepcion__c) ? 'Exception' : ((GPA.Descontinuado__c) ? 'Discontinued' : 'Normal');
                        
                        if(!mpGrupoProductosAprobarNO.containsKey(gpaType)){
                            mpGrupoProductosAprobarNO.put(gpaType, new Map<Double, Grupo_de_productos_a_aprobar__c>());
                        }
                    
                    mpGrupoProductosAprobarNO.get(gpaType).put(GPA.Nivel__c, GPA);
                }
            }

            Descuentos__mdt excepcion = Descuentos__mdt.getInstance('Excepcion');
            Descuentos__mdt descontinuado = Descuentos__mdt.getInstance('Descontinuado');

            if(quote.SBQQ__PriceBook__r.Lista_MB__c){
                System.debug('Entramos al proceso de muebles de baño');
                for(SBQQ__QuoteLine__c currentQLI : quoteLineItems){
                    if(currentQLI.INT_Tipo_CPQ__c == 'MB'){
                        if(currentQLI.SBQQ__Product__r.INT_Status__c == 'DESCONTINUADO' && !currentQLI.Confirmar_Aprobacion_Descontinuado__c){
                            //Validamos que el grupo no exista para crearlo
                            if(!mpGrupoProductosAprobarNO.containsKey('Discontinued')){
                                mpGrupoProductosAprobarNO.put('Discontinued', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                            }
                        
                            if (!mpGrupoProductosAprobarNO.get('Discontinued').containsKey(descontinuado.Nivel_aprobacion__c)) {
                                ApprovalGrupoHelper.createGroup2Approval(quote, 'Discontinued', descontinuado.Nivel_aprobacion__c, 'NO', 'NO');
                            }
                        
                            //Agregamos la partida con los datos del grupo al que corresponde
                            ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Discontinued', descontinuado.Nivel_aprobacion__c, currentQLI);
                        }else{
                            //Validamos que el grupo no exista para crearlo
                            if(!mpGrupoProductosAprobarMB.containsKey('Exception')){
                                mpGrupoProductosAprobarMB.put('Exception', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                            }
                    
                            if (!mpGrupoProductosAprobarMB.get('Exception').containsKey(excepcion.Nivel_aprobacion__c)) {
                                ApprovalGrupoHelper.createGroup2Approval(quote, 'Exception', excepcion.Nivel_aprobacion__c, 'MB', 'MB');
                            }
                    
                            //Agregamos la partida con los datos del grupo al que corresponde
                            ApprovalGrupoHelper.createWrapQuoteLine('MB', 'Exception', excepcion.Nivel_aprobacion__c, currentQLI);
                        }
                    }else{
                        System.debug('Error, No deben existir productos normales en una cotización de MB');
                        errorProccess = true;
                        errorCode = 1;
                        stProductNOinQuoteMB.add(currentQLI);
                    }
                }
            }else{
                System.debug('Entramos al proceso de muebles normales');
                //OBTENERMOS LOS REGISTROS DE LA METADATA
                for(Descuentos__mdt record : [SELECT Monto_minimo_cotizado__c,	Descuento_maximo__c, Descuento_Minimo__c, Nivel_aprobacion__c, Tipo_producto__c, Clasificacion__c, Tipo_Registro__c, DeveloperName FROM Descuentos__mdt where DeveloperName != 'Excepcion' AND DeveloperName != 'Descontinuado' ORDER BY Monto_minimo_cotizado__c desc]){
                    if(!mpDescuentos.containsKey(record.Tipo_Registro__c)){
                        mpDescuentos.put(record.Tipo_Registro__c, New List<Descuentos__mdt>());
                    }
                    mpDescuentos.get(record.Tipo_Registro__c).add(record);
                }

                //REVISAMOS CADA PARTIDA PARA ENCONTRAR SU GRUPO Y NIVEL
                for(SBQQ__QuoteLine__c currentQLI : quoteLineItems){
                    System.debug('currentQLI: ' + currentQLI);
                    //ES UN PRODUCTO DE MUEBLES DE BAÑO CON MAS DE 6% DE DESCUENTO
                    if(currentQLI.INT_Tipo_CPQ__c == 'MB' && currentQLI.SBQQ__Discount__c > 6){
                        System.debug('Error, No deben existir productos MB con descuento de mas de 6% en una cotización mixta');
                        errorProccess = true;
                        errorCode = 2;
                        stProductMBMixedNotPermited.add(currentQLI);
                    }else{
                        Boolean flagOtros = false;
                        //ES UNA PARTIDA DESCONTINUADA POR PRIMERA VEZ
                        if(currentQLI.SBQQ__Product__r.INT_Status__c == 'DESCONTINUADO' && !currentQLI.Confirmar_Aprobacion_Descontinuado__c){
                            if(!mpGrupoProductosAprobarNO.containsKey('Discontinued')){
                                mpGrupoProductosAprobarNO.put('Discontinued', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                            }
                        
                            if (!mpGrupoProductosAprobarNO.get('Discontinued').containsKey(descontinuado.Nivel_aprobacion__c)) {
                                ApprovalGrupoHelper.createGroup2Approval(quote, 'Discontinued', descontinuado.Nivel_aprobacion__c, 'NO', 'NO');
                            }
                        
                            ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Discontinued', descontinuado.Nivel_aprobacion__c, currentQLI);
                        }else if(childOpp){//SE AGREGA ESTE IF PARA EL PROCESO DE LAS OPPS HIJAS
                            if(!mpGrupoProductosAprobarNO.containsKey('Exception')){
                                mpGrupoProductosAprobarNO.put('Exception', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                            }
                            
                            if (!mpGrupoProductosAprobarNO.get('Exception').containsKey(excepcion.Nivel_aprobacion__c)) {
                                ApprovalGrupoHelper.createGroup2Approval(quote, 'Exception', excepcion.Nivel_aprobacion__c, 'NO', 'NO');
                            }
                            
                            ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Exception', excepcion.Nivel_aprobacion__c, currentQLI);
                        }else if(mpDescuentos.containsKey(currentQLI.Tipo_producto__c)){//ENTRAMOS EL FUJO DE NORMALES
                            Integer countMD = 0;
                            for(Descuentos__mdt record: mpDescuentos.get(currentQLI.Tipo_producto__c)){
                                System.debug('record: ' + record);
                                //VALIDAMOS QUE ENTREMOS AL METADATO CORRECTO POR TIPO DE PRODUCTO O CLASIFICACIÓN
                                if(!String.isBlank(currentQLI.Clasificacion__c) && !String.isBlank(record.Clasificacion__c) && currentQLI.Clasificacion__c == record.Clasificacion__c || !String.isBlank(currentQLI.Tipo_producto__c) && !String.isBlank(record.Tipo_producto__c) && currentQLI.Tipo_producto__c == record.Tipo_producto__c){
                                    System.debug('ENTRAMOS CON TIPO O CLASIFICACIÓN: ' + record);
                                    //Dentro del porcentaje
                                    if(currentQLI.SBQQ__Discount__c >= record.Descuento_Minimo__c && currentQLI.SBQQ__Discount__c <= record.Descuento_maximo__c){
                                        if(quote.SBQQ__ListAmount__c >= record.Monto_minimo_cotizado__c){
                                            //CUMPLE CON EL DESCUENTO Y MONTO, ES EL NIVEL
                                            if(!mpGrupoProductosAprobarNO.containsKey('Normal')){
                                                mpGrupoProductosAprobarNO.put('Normal', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                                            }
                                            
                                            if (!mpGrupoProductosAprobarNO.get('Normal').containsKey(record.Nivel_aprobacion__c)) {
                                                ApprovalGrupoHelper.createGroup2Approval(quote, 'Normal', record.Nivel_aprobacion__c, 'NO', 'NO');
                                            }
                                            
                                            ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Normal', record.Nivel_aprobacion__c, currentQLI);
                                            break;
                                        }else{
                                            //No cumple con el monto minino para el porcentaje
                                            System.debug('NORMAL:Algun producto no corresponde con el monto minimo para su porcentaje');
                                            errorProccess = true;
                                            errorCode = 3;
                                            stProductNotMeetMinimalAmount.add(currentQLI);
                                            break;
                                        }
                                    }else if(currentQLI.SBQQ__Discount__c > record.Descuento_maximo__c && quote.SBQQ__ListAmount__c >= excepcion.Monto_minimo_cotizado__c){
                                        //ES UNA EXCEPCION, TIENE MAYOR PROCENTAJE QUE EL REGISTRO DE MAYOR NIVEL Y CUMPLE CON EL MONTO DE LA EXCEPCION
                                        if(!mpGrupoProductosAprobarNO.containsKey('Exception')){
                                            mpGrupoProductosAprobarNO.put('Exception', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                                        }
                                        
                                        if (!mpGrupoProductosAprobarNO.get('Exception').containsKey(excepcion.Nivel_aprobacion__c)) {
                                            ApprovalGrupoHelper.createGroup2Approval(quote, 'Exception', excepcion.Nivel_aprobacion__c, 'NO', 'NO');
                                        }
                                        
                                        ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Exception', excepcion.Nivel_aprobacion__c, currentQLI);
                                        break;
                                    }
                                }else{
                                    //Aumentamos el contador solo si no existe la clasificación o el tipo de producto
                                    countMD++;
                                }
                            }
                            System.debug('countMD:' + countMD);
                            flagOtros = (countMD == mpDescuentos.get(currentQLI.Tipo_producto__c).size()) ? true : false;
                        }else{//ENTRAMOS AL ELSE DE OTROS
                            flagOtros = true;
                        }
                        System.debug('flagOtros: ' + flagOtros);
                        //ESTE ES EL PROCESO DE OTROS YA SEA POR TIPO DE PRODUCTO O CLASIFICACIÓN
                        if(flagOtros){
                            for(Descuentos__mdt record: mpDescuentos.get('OTROS')){
                                System.debug('OTROS:record: ' + record);
                                if(currentQLI.SBQQ__Discount__c >= record.Descuento_Minimo__c && currentQLI.SBQQ__Discount__c <= record.Descuento_maximo__c){
                                    if(quote.SBQQ__ListAmount__c >= record.Monto_minimo_cotizado__c){
                                        if(!mpGrupoProductosAprobarNO.containsKey('Normal')){
                                            mpGrupoProductosAprobarNO.put('Normal', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                                        }
                                        
                                        if (!mpGrupoProductosAprobarNO.get('Normal').containsKey(record.Nivel_aprobacion__c)) {
                                            ApprovalGrupoHelper.createGroup2Approval(quote, 'Normal', record.Nivel_aprobacion__c, 'NO', 'NO');
                                        }
                                        
                                        ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Normal', record.Nivel_aprobacion__c, currentQLI);
                                        break;
                                    }else{
                                        System.debug('OTROS:Algun producto no corresponde con el monto minimo para su porcentaje');
                                        errorProccess = true;
                                        errorCode = 3;
                                        stProductNotMeetMinimalAmount.add(currentQLI);
                                        break;
                                    }
                                }else if(currentQLI.SBQQ__Discount__c > record.Descuento_maximo__c && quote.SBQQ__ListAmount__c >= excepcion.Monto_minimo_cotizado__c){
                                    if(!mpGrupoProductosAprobarNO.containsKey('Exception')){
                                        mpGrupoProductosAprobarNO.put('Exception', new Map<Double, Grupo_de_productos_a_aprobar__c>());
                                    }
                                    
                                    if (!mpGrupoProductosAprobarNO.get('Exception').containsKey(excepcion.Nivel_aprobacion__c)) {
                                        ApprovalGrupoHelper.createGroup2Approval(quote, 'Exception', excepcion.Nivel_aprobacion__c, 'NO', 'NO');
                                    }
                                    
                                    ApprovalGrupoHelper.createWrapQuoteLine('NO', 'Exception', excepcion.Nivel_aprobacion__c, currentQLI);
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            if(errorProccess){
                //HUBO ALGUN ERROR EN EL PROCESO DE ASIGNACIÓN DE NIVEL Y TIPO
                List<SBQQ__QuoteLine__c> lst2Update  = new List<SBQQ__QuoteLine__c>();
                response.add('ERROR');

                if(errorCode == 1){
                    response.add('Hay productos normales en una cotización de MB');
                    for(SBQQ__QuoteLine__c objQLI : stProductNOinQuoteMB){
                        SBQQ__QuoteLine__c newObj = new SBQQ__QuoteLine__c();
                        newObj.Id = objQLI.Id;
                        newObj.Error_Proceso_Aprobacion__c = '1';
                        lst2Update.add(newObj);
                    }
                }else if(errorCode == 2){
                    response.add('Los productos MB en una cotización mixta no deben de tener mas de 6% de descuento, crea una cotiazción de MB para ellos');
                    for(SBQQ__QuoteLine__c objQLI : stProductMBMixedNotPermited){
                        SBQQ__QuoteLine__c newObj = new SBQQ__QuoteLine__c();
                        newObj.Id = objQLI.Id;
                        newObj.Error_Proceso_Aprobacion__c = '2';
                        lst2Update.add(newObj);
                    }
                }else if( errorCode == 3){
                    response.add('La cotización no tiene el monto minimo para algunos porcentajes');
                    for(SBQQ__QuoteLine__c objQLI : stProductNotMeetMinimalAmount){
                        SBQQ__QuoteLine__c newObj = new SBQQ__QuoteLine__c();
                        newObj.Id = objQLI.Id;
                        newObj.Error_Proceso_Aprobacion__c = '3';
                        lst2Update.add(newObj);
                    }
                }

                update lst2Update;
            }else{
                if(lstAllWrapQuoteLine.size() > 0){

                    if(!flagDiscontinuedFirstApproved){
                        SBQQ__Quote__c updQuote = new SBQQ__Quote__c();
                        updQuote.Id = idQuote;
                        updQuote.SBQQ__Status__c = 'In Review';
                        update updQuote;
                    }
                    
                    
                    //Obtenemos los aprobadores 1 y 2, Exceptiones y Descontinuados
                    User currentUser = new User();
                    User approverExceptionNO = new User();
                    User approverDiscontinued = new User();
                    User approverMB = new User();
                    //Map<Double, Aprobador__mdt> mpApproverNO = new Map<Double, Aprobador__mdt>();
                    
                    //Mapa para enviar las notificaciónes a los aprobadores
                    Map<String, String> mpApproverNotification = new Map<String, String>();
                    
                    for(User us : [SELECT Id, Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId, Manager.Manager.Manager.Manager.ManagerId, Profile.Name FROM User 
                                   WHERE isActive = true AND (Id =: quote.CreatedById 
                                                              OR Profile.Name = 'Autorizador Excepciones MB' 
                                                              OR Profile.Name = 'Autorizador Excepciones Loseta' 
                                                              OR Profile.Name = 'Autorizador Logística')]){
                                                                  
                                                                  if(us.Id == quote.CreatedById){
                                                                      currentUser = us;
                                                                  }else if(us.Profile.Name == 'Autorizador Excepciones MB'){
                                                                      approverMB = us;
                                                                  }else if(us.Profile.Name == 'Autorizador Excepciones Loseta'){
                                                                      approverExceptionNO = us;
                                                                  }else if(us.Profile.Name == 'Autorizador Logística'){
                                                                      approverDiscontinued = us;
                                                                  }
                                                              }
                    
                    //Revisamos si tenemos nuevos grupos
                    if(lstNuevoGruposProductosAprobar.size() > 0){
                        //Verificamos el perfil del ejecutivo y marcamos como aprobadas las de nivel 2 y/o 1
                        for(Grupo_de_productos_a_aprobar__c currentGPA : lstNuevoGruposProductosAprobar){
                            String gpaType = (currentGPA.Excepcion__c) ? 'Exception' : ((currentGPA.Descontinuado__c) ? 'Discontinued' : 'Normal');
                            if(gpaType == 'Normal'){
                                if(currentUser.Profile.Name == 'Ejecutivo Especificaciones Franquicia'){
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(1)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(1).Aprobado__c = true;
                                    }
                                }else if(currentUser.Profile.Name == 'Ejecutivo Especificaciones'){
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(1)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(1).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(2)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(2).Aprobado__c = true;
                                    }
                                    //cambio****************************************************
                                }/*else if(currentUser.Profile.Name == 'Jefatura Especificaciones'){
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(1)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(1).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(2)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(2).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(3)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(3).Aprobado__c = true;
                                    }
                                }else if(currentUser.Profile.Name == 'Gerente Especificaciones'){
                                     if (mpGrupoProductosAprobarNO.get('Normal').containsKey(1)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(1).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(2)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(2).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(3)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(3).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(4)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(4).Aprobado__c = true;
                                    }
                                    
                                }else if(currentUser.Profile.Name == 'Gerente Especificaciones Franquicia'){
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(1)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(1).Aprobado__c = true;
                                    }
                                    if (mpGrupoProductosAprobarNO.get('Normal').containsKey(2)) {
                                        mpGrupoProductosAprobarNO.get('Normal').get(2).Aprobado__c = true;
                                    }
                                }*/
                            }
                        }

                        //Insertamos los grupos ya actualizados(APROBADOS)
                        insert lstNuevoGruposProductosAprobar;
                
                        for(Grupo_de_productos_a_aprobar__c currentGPA : lstNuevoGruposProductosAprobar){
                            if(currentGPA.Tipo_de_producto__c == 'MB'){
                                mpGrupoProductosAprobarMB.get('Exception').put(currentGPA.Nivel__c, currentGPA);
                            }else{
                                String gpaType = (currentGPA.Excepcion__c) ? 'Exception' : ((currentGPA.Descontinuado__c) ? 'Discontinued' : 'Normal');
                                mpGrupoProductosAprobarNO.get(gpaType).put(currentGPA.Nivel__c, currentGPA);
                            }
                        }
                    }
                    
                    
                    //Recorremos la lista de partidas wrapper, actualizamos su partida correspondiente con su grupo
                    List<SBQQ__QuoteLine__c> lstQuoteLine2Update = new List<SBQQ__QuoteLine__c>();
                    for(wrapperPartidas currentWrp : lstAllWrapQuoteLine){
                        //asignamos los campos que se actualizan por defecto
                        SBQQ__QuoteLine__c newQL = new SBQQ__QuoteLine__c();
                        newQL.Id = currentWrp.quoteLine.Id;
                        newQL.Aprobador_Nivel_1__c = null;
                        newQL.Aprobador_Nivel_2__c = null;
                        newQL.Aprobador_Nivel_3__c = null;
                        newQL.Aprobador_Nivel_4__c = null;
                        newQL.Aprobador_Nivel_5__c = null;
                        newQL.Aprobador_Nivel_6__c = null;
                        newQL.Estado_Aprobacion_Nivel_1__c = null;
                        newQL.Estado_Aprobacion_Nivel_2__c = null;
                        newQL.Estado_Aprobacion_Nivel_3__c = null;
                        newQL.Estado_Aprobacion_Nivel_4__c = null;
                        newQL.Estado_Aprobacion_Nivel_5__c = null;
                        newQL.Estado_Aprobacion_Nivel_6__c = null;

                        String idNotificationApprover;
                        
                        //Asignamos grupo y Aprobadores, dependiendo su tipo y nivel/currentWrp.type == 'MB'
                        if(quote.SBQQ__PriceBook__r.Lista_MB__c){
                            
                            newQL.Aprobador_Nivel_1__c = currentUser.ManagerId;
                            newQL.Aprobador_Nivel_2__c = currentUser.Manager.ManagerId;
                            newQL.Aprobador_Nivel_3__c = approverMB.Id;
                            //*****************ajuste MB descontinuados
                            idNotificationApprover = currentUser.ManagerId;

                            //Si es descontinuado se va a la lista NO que es la que tiene todos
                            if(currentWrp.subType == 'Discontinued'){
                                //ajuste MB Descontinuados***********************************************************************
                                system.debug('currentWrp.subType == Discontinued');
                                 newQL.Aprobador_Nivel_1__c = approverDiscontinued.Id;
                                 newQL.Aprobador_Nivel_2__c = null;
                           		 newQL.Aprobador_Nivel_3__c = null;
                                idNotificationApprover = approverDiscontinued.Id;
                                system.debug('idNotificationApprover'+idNotificationApprover );
                                newQL.Grupos_de_productos__c = mpGrupoProductosAprobarNO.get(currentWrp.subType).get(currentWrp.level).Id;
                                 //newQL.Grupos_de_productos__c = mpGrupoProductosAprobarNO.get(currentWrp.subType).get(currentWrp.level).Id;
                            }else{
                                newQL.Grupos_de_productos__c = mpGrupoProductosAprobarMB.get(currentWrp.subType).get(currentWrp.level).Id;
                            }

                            //idNotificationApprover = currentUser.ManagerId;
                            //system.debug('currentUser.ManagerId'+ currentUser.ManagerId);
                        }else{
                            newQL.Grupos_de_productos__c = mpGrupoProductosAprobarNO.get(currentWrp.subType).get(currentWrp.level).Id;
                            
                            //Asignamos aprobadores por nivel
                            switch on currentWrp.subType {
                                when 'Discontinued' {
                                    system.debug('switch Discontinued ');
                                    
                                    newQL.Aprobador_Nivel_1__c = approverDiscontinued.Id;

                                    idNotificationApprover = approverDiscontinued.Id;
                                }	
                                when 'Exception' {
                                    newQL.Aprobador_Nivel_1__c = currentUser.ManagerId;
                                    newQL.Aprobador_Nivel_2__c = currentUser.Manager.ManagerId;
                                    newQL.Aprobador_Nivel_3__c = approverExceptionNO.Id;

                                    idNotificationApprover = currentUser.ManagerId;
                                }
                                when else {
                                    //Asignamos aprobadores por perfil y Nivel
                                    switch on currentUser.Profile.Name {//Administrador del sistema
                                        when 'Ejecutivo Especificaciones Franquicia' {
                                            if(currentWrp.level >= 1){
                                                newQL.Aprobador_Nivel_1__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_1__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 2){
                                                newQL.Aprobador_Nivel_2__c = currentUser.ManagerId;
                                                idNotificationApprover = currentUser.ManagerId;
                                            }
                                            if(currentWrp.level >= 3){
                                                newQL.Aprobador_Nivel_3__c = currentUser.Manager.ManagerId;
                                            }
                                            if(currentWrp.level >= 4){
                                                newQL.Aprobador_Nivel_4__c = currentUser.Manager.Manager.ManagerId;
                                            }
                                            if(currentWrp.level == 5){
                                                newQL.Aprobador_Nivel_4__c = currentUser.Manager.Manager.Manager.ManagerId;
                                            }
                                        }//Administrador del sistema
                                        when 'Ejecutivo Especificaciones' {
                                            if(currentWrp.level >= 1){
                                                newQL.Aprobador_Nivel_1__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_1__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 2){
                                                newQL.Aprobador_Nivel_2__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_2__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 3){
                                                newQL.Aprobador_Nivel_3__c = currentUser.ManagerId;
                                                idNotificationApprover = currentUser.ManagerId;
                                            }
                                            if(currentWrp.level >= 4){
                                                newQL.Aprobador_Nivel_4__c = currentUser.Manager.ManagerId;
                                            }
                                            if(currentWrp.level == 5){
                                                newQL.Aprobador_Nivel_5__c = currentUser.Manager.Manager.ManagerId;
                                            }
                                        }
                                        /*when 'Jefatura Especificaciones' {
                                            if(currentWrp.level >= 1){
                                                newQL.Aprobador_Nivel_1__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_1__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 2){
                                                newQL.Aprobador_Nivel_2__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_2__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 3){
                                                newQL.Aprobador_Nivel_3__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_3__c = 'Approved';
                                                
                                            }
                                            if(currentWrp.level >= 4){
                                                newQL.Aprobador_Nivel_4__c = currentUser.ManagerId;
                                                idNotificationApprover = currentUser.ManagerId;
                                            }
                                            if(currentWrp.level == 5){
                                                newQL.Aprobador_Nivel_5__c = currentUser.Manager.ManagerId;
                                            }
                                        }
                                        when 'Gerente Especificaciones'{
                                            if(currentWrp.level >= 1){
                                                newQL.Aprobador_Nivel_1__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_1__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 2){
                                                newQL.Aprobador_Nivel_2__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_2__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 3){
                                                newQL.Aprobador_Nivel_3__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_3__c = 'Approved';
                                                
                                            }
                                            if(currentWrp.level >= 4){
                                                newQL.Aprobador_Nivel_4__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_4__c = 'Approved';
                                                
                                            }
                                            if(currentWrp.level == 5){
                                                newQL.Aprobador_Nivel_5__c = currentUser.ManagerId;
                                                idNotificationApprover = currentUser.ManagerId;
                                            }
                                        }
                                        when 'Gerente Especificaciones Franquicia'{
                                            if(currentWrp.level >= 1){
                                                newQL.Aprobador_Nivel_1__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_1__c = 'Approved';
                                            }
                                            if(currentWrp.level >= 2){
                                                newQL.Aprobador_Nivel_2__c = currentUser.Id;
                                                newQL.Estado_Aprobacion_Nivel_2__c = 'Approved';
                                                idNotificationApprover = currentUser.ManagerId;
                                            }
                                            if(currentWrp.level >= 3){
                                                newQL.Aprobador_Nivel_3__c = currentUser.Manager.ManagerId;
                                            }
                                            if(currentWrp.level >= 4){
                                                newQL.Aprobador_Nivel_4__c = currentUser.Manager.Manager.ManagerId;
                                            }
                                            if(currentWrp.level == 5){
                                                newQL.Aprobador_Nivel_4__c = currentUser.Manager.Manager.Manager.ManagerId;
                                            }
                                        }*/
                                    }
                                }
                            }
                        }
                        System.debug('Asignamos Aprobadores:newQL: ' + newQL);
                        lstQuoteLine2Update.add(newQL);
                        mpApproverNotification.put(newQL.Grupos_de_productos__c, idNotificationApprover);
                    }
                    
                    if(lstQuoteLine2Update.size() > 0){
                        upsert lstQuoteLine2Update;
                        response.add('Exito');
                        
                        Aprobador__mdt CM = Aprobador__mdt.getInstance('TEMPLATE_EMAIL_APPROVAL');
                        //Enviamos la notificación al aprobador correspondiente por grupo
                        for(String stg : mpApproverNotification.keySet()){
                            Set<String> stId = new Set<String>();
                            stId.add(mpApproverNotification.get(stg));
                            
                            INT_Utility.sendApprovalNotification(stId, stg, 'Se requiere su aprobación. Cotización '+ quote.name, 'Se le ha asignado como aprobador para algunos productos, de clic para verlos.');
                            INT_Utility.sendApprovalEmail(CM.Id_Aprobador_Nivel_1__c, stg, mpApproverNotification.get(stg));
                        }
                    }
                }else{
                    response.add('ERROR');
                    response.add('No se encontro ningun producto para enviar a aprobar');
                }
            }
        }catch(Exception e){
            System.debug('OCURRIO UN ERROR: ' + e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString());
            response.add('ERROR');
            response.add(e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString());
        }

        System.debug('response: ' + response);
        System.debug('ApprovalGrupoHelper:executeApprovalGroupProccess:FIN');
        return response;
    }

    public class wrapperPartidas{
        public String type {get;set;}
        public String subType {get;set;}
        public Double level {get;set;}
        public SBQQ__QuoteLine__c quoteLine{get;set;}
    }

    public static void createGroup2Approval(SBQQ__Quote__c cotizacion, String namePrefix, Decimal level, String productType, String mapType){
        Grupo_de_productos_a_aprobar__c grupo = new Grupo_de_productos_a_aprobar__c();
        grupo.Cotizacion__c = cotizacion.Id;
        grupo.Descripcion__c = '';
        grupo.Name = cotizacion.Name + ' - Nivel ' + level.intValue() + ' ' + namePrefix;
        grupo.Nivel__c = level;
        grupo.Descontinuado__c = (namePrefix == 'Discontinued') ? true : false;
        grupo.Excepcion__c = (namePrefix == 'Exception') ? true : false;//(mapType == 'MB') ? false : ((namePrefix == 'Exception') ? true : false);
        grupo.Tipo_de_producto__c = productType;
        grupo.Fecha_Ultima_Aprobacion__c = System.now();
        
        lstNuevoGruposProductosAprobar.add(grupo);
        
        if(mapType == 'MB'){
            mpGrupoProductosAprobarMB.get(namePrefix).put(level, grupo);
        }else{
            mpGrupoProductosAprobarNO.get(namePrefix).put(level, grupo);
        }
    }
    
    public static void createWrapQuoteLine(String type, String subType, Decimal level, SBQQ__QuoteLine__c quoteLineItem){
        wrapperPartidas objWrpPartida = new wrapperPartidas();
        objWrpPartida.type = type;
        objWrpPartida.subType = subType;
        objWrpPartida.level = level;
        objWrpPartida.quoteLine = quoteLineItem;
        System.debug('Current:Partida: ' + objWrpPartida);
        lstAllWrapQuoteLine.add(objWrpPartida);
    }

}