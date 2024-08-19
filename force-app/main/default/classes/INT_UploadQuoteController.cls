public with sharing class INT_UploadQuoteController {
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
    public static string uploadFile(String csvData, String grupoProductosId) {
        
        List<String> partidasIds = new List<String>();
        List<String> partidasNames = new List<String>();
        List<String> productCodes = new List<String>();
        List<String> productsName = new List<String>();
        
        system.debug('grupoProductosId:'+grupoProductosId);
        system.debug('csvData:'+csvData);
        isExecuting = true;
        Grupo_de_productos_a_aprobar__c grupo = [SELECT Id, Name, Cotizacion__c, Cotizacion__r.Name FROM Grupo_de_productos_a_aprobar__c  WHERE Id = :grupoProductosId LIMIT 1];
        List<SBQQ__QuoteLine__c> qlList =  [SELECT Id, Name, Grupos_de_productos__c, SBQQ__ProductCode__c, INT_Nombre_de_producto__c FROM SBQQ__QuoteLine__c WHERE Grupos_de_productos__c = : grupoProductosId];
        
        for(SBQQ__QuoteLine__c ql: qlList){
            
            partidasIds.add(String.valueOf(ql.Id).substring(0, 15));
            partidasNames.add(ql.Name);
            productCodes.add(ql.SBQQ__ProductCode__c);
            productsName.add(ql.INT_Nombre_de_producto__c);
        }
        
        system.debug('partidasIds: ' +partidasIds);

        List<String> errors = new List<String>();
        String errorsString = '';

        SBQQ__QuoteLine__c[] quotelines = new SBQQ__QuoteLine__c[]{};
         //   try{
                //Convert csvData String param to Wrapper for processing
                try{

                    csvData[] lstPartidas = (CSVData[])JSON.deserialize(csvData, CSVData[].class);
                    system.debug('lstPartidas::'  +lstPartidas);
                    for(csvData qline : lstPartidas){
                    //validacion mismo grupo de productos
                    if(qline.GruposdeproductosGrupodeproductosaaprobarId == grupoProductosId ){
                        //validacion misma cotizacion
                        system.debug('qline.CotizacinId'+ qline.CotizacinId);
                        system.debug('grupo.Cotizacion__c' + grupo.Cotizacion__c);
                        system.debug('qline.Nmerodepresupuesto' + qline.Nmerodepresupuesto);
                        system.debug('grupo.Cotizacion__r.Name' + grupo.Cotizacion__c);
                        if(qline.CotizacinId == grupo.Cotizacion__c && qline.Nmerodepresupuesto == grupo.Cotizacion__r.Name ){

                            //validacion mismas partidas
                            system.debug('partidasIds::'+partidasIds);
                            system.debug('qline.PartidadepresupuestoId::' + qline.PartidadepresupuestoId);
                            system.debug('partidasNames::'+ partidasNames);
                            system.debug('qline.Nombredepartida::' + qline.Nombredepartida);
                            system.debug('productCodes: ' +productCodes);
                            system.debug('qline.Cdigodelproducto:' + qline.Cdigodelproducto);
                            system.debug('productsName::'+productsName);
                            system.debug('qline.Nombredelproducto' +qline.Nombredelproducto);
                            if(partidasIds.contains(qline.PartidadepresupuestoId) && partidasNames.contains(qline.Nombredepartida) && productCodes.contains(qline.Cdigodelproducto)){
                                SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(
                                SBQQ__Quote__c = qline.CotizacinId,
                                Id = qline.PartidadepresupuestoId,
                                SBQQ__ListPrice__c = Decimal.valueOf(qline.Preciounitariodelista),
                                SBQQ__Discount__c = String.isNotBlank(qline.Descuentoadicional) ? Decimal.valueOf(qline.Descuentoadicional) : null);

                                //Add records to list
                                quotelines.add(ql);
                            }else{
                                errors.add('\nError. Se cargó una partida que no se encuentra en el grupo de productos a aprobar. Favor de validar el Nombre, Id y Product Code. Nombre partida: '+ qline.Nombredepartida + ' Id partida: ' +qline.PartidadepresupuestoId + ' ');
                                errorsString += '\nError. Se cargó una partida que no se encuentra en el grupo de productos a aprobar. Favor de validar el Nombre, Id y Product Code. Nombre partida: '+ qline.Nombredepartida + ' Id partida: ' +qline.PartidadepresupuestoId;
                            }

                        }else{
                            if(qline.CotizacinId == null){
                                errors.add('');  
                                errorsString = '';
                            }else{
                                errors.add('\nError. Se cargó una partida que no corresponde a la misma cotización. Nombre Partida: '+ qline.Nombredepartida + ' Id partida:' +qline.PartidadepresupuestoId+ ' ');  
                                errorsString += '\nError. Se cargó una partida que no corresponde a la misma cotización. Nombre Partida: '+ qline.Nombredepartida + ' Id partida:' +qline.PartidadepresupuestoId;
                            }
                            
                        }
                       
                    }else{
                        //MEJOR AÑADIR UNA LISTA QUE GUARDE AQUELLO REGISTROS QUE NO CORRESPONDEN
                        //throw new AuraHandledException('Error. Se cargó una partida que no corresponde al grupo de productos. Partida: '+ qline.Nombredepartida);   
                        
                        if(qline.GruposdeproductosGrupodeproductosaaprobarId == null){
                            errors.add('');
                            errorsString = '';
                        }else{
                            errors.add('\nError. Se cargó una partida que no corresponde al grupo de productos. Partida: '+ qline.Nombredepartida);
                            errorsString += '\nError. Se cargó una partida que no corresponde al grupo de productos. Partida: '+ qline.Nombredepartida;
                        }
                        
                    }
                }

            if(lstPartidas.isEmpty()){
                throw new AuraHandledException('Error en estructura del archivo');
            }

            if (!errors.isEmpty()) {
                system.debug('entre a la validacion de errores' +errors);
                throw new AuraHandledException(String.join(errors, '\n'));
               //throw new AuraHandledException(errorsString);
            }

            if (quotelines.size() > 0) {
                String perfilUsuario = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
                try {
                    if (perfilUsuario == 'Autorizador Excepciones MB' || perfilUsuario == 'Administrador del sistema') {// pendiente meter esto en una metadata
                        System.debug('Entro con usuario');
                        if(errors.size() >0)
                        {

                        }else{
                            update quotelines;
                        }
                        
                    } else {
                        System.debug('Entro sin usuario');
                        throw new AuraHandledException('No tienes permiso para actualizar las partidas.');
                    }
                } catch(Exception ex) {
                    //throw new AuraHandledException('No tienes permiso para actualizar las partidas.');
                     throw new AuraHandledException('Error: '+ex.getMessage());
                }
            }

            return '';
                
        }catch(Exception ex){
            system.debug('entre a la excepcion tr catch');
            
            string mensaje = '';
            if(errors.size() >0){
                //mensaje = String.join(errors, '\n');
                  mensaje += String.join(errors, '\n') + '\n';
                  //mensaje += errorsString;
            }

            mensaje += ex.getMessage();

            /*AuraHandledException e = new AuraHandledException(mensaje);
            e.setMessage(mensaje);
            system.debug(mensaje);
            throw e;*/

            //system.debug('mensaje: '+ mensaje);
            //throw new AuraHandledException('Error. \n Valida la estructura del archivo: '+ mensaje);
            System.debug('Error.' + mensaje);
            return 'Error.' + mensaje;
            }
                //List iteration for fill the list of records to be inserted
                
    }
    /**
    * @description Wrapper to read CSV data from the LWC
    * @author emeza@freewayconsulting.com | 03-28-2022
    **/
    public class CSVData{

        @AuraEnabled public String GruposdeproductosGrupodeproductosaaprobarId;
        @AuraEnabled public String CotizacinId;
        @AuraEnabled public String PartidadepresupuestoId;
        @AuraEnabled public String Nmerodepresupuesto;
        @AuraEnabled public String Nombredepartida;
        @AuraEnabled public String Cdigodelproducto;
        @AuraEnabled public String Nombredelproducto;
        @AuraEnabled public String UnidaddeMedida;
        @AuraEnabled public String Cantidad;
        @AuraEnabled public String PreciounitariodelistaDivisa;
        @AuraEnabled public String Preciounitariodelista;
        @AuraEnabled public String Descuentoadicional;
        @AuraEnabled public String PrecioProyectoUnidaddeVentaMBDivisa;
        @AuraEnabled public String PrecioProyectoUnidaddeVentaMB;
    }
}