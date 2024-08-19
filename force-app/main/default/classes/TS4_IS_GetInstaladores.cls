public class TS4_IS_GetInstaladores {
    
     //public class ExternalSystemException extends Exception {}
    
    public String RESULTADO;	//OK
	public cls_MENSAJE MENSAJE;
	public cls_DATOS DATOS;
	class cls_MENSAJE {
	}
	class cls_DATOS {
		public String ALMACEN_ID;	//204CDCH
		public cls_TIENDAS[] TIENDAS;
		public cls_INSTALADORES[] INSTALADORES;
	}
	class cls_TIENDAS {
		public String TIENDA;	//Tienda Canal
		public String HORARIO;	//Lunes a Viernes de 9:00 a 19:00, Sábado de 9:00 a 14:00
		public String DIRECCION;	//Teófilo Borunda #1617, Col. Santo Niño, C.P. 31205, Chihuahua, Chihuahua
		public String TELEFONO;	//6144154022
		public String URL;	//https://www.google.com/maps/@28.6320966, 106.0836678,3a,75y,25.57h,88.58t/data=!3m6!1e1!3m4!1sIO8CbvY rNDgFlAmdaU91g!2e0!7i13312!8i6656
	}
	class cls_INSTALADORES {
		public String NOMBRE;	//Mendoza Muñoz Roberto
		public String TELEFONO;	//6141324101
		public String CELULAR;	//6141324101
		public String TIPO;	//Instalador
	}
    
    //input details that comes to apex from flow
    public class paramsInputs{
        
        @InvocableVariable
        public String zipCode;
        
        @InvocableVariable
        public String tipoInstalador;
    }
    
    /*@InvocableMethod(Label='Get instaladores') 
    public static void procesaParametros(List<paramsInputs> params) {
        List<TranscriptOutput> resultsInputs = new List<TranscriptOutput>();
        for(paramsInputs param:params){
            resultsInputs.add(getInstadores(param));
        }

    }*/

        
    @InvocableMethod(Label='Get instaladores') 
       public static List<List<TranscriptOutput>> getInstadores(List<paramsInputs> params) {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String infoTiendas='';
        String infoInstaladores='';
           
        //String codigoP='';
        
        String instaladorTipo=params[0].tipoInstalador=='Instalador'?'1':params[0].tipoInstalador=='Plomero'?'2':params[0].tipoInstalador=='Instalador y Plomero'?'3':'0';
           
        List<TranscriptOutput> listTranscriptOutput= new List<TranscriptOutput>();      
        List<TranscriptOutput> listTranscriptOutputInst= new List<TranscriptOutput>();      

        try {

            request.setEndpoint('callout:AWS_ObtenerInstaladores');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            //request.setHeader('pCodigoPostal', '31060');
            //request.setHeader('pTipoDeInstalador', '1');
            request.setHeader('pCodigoPostal', params[0].zipCode);
            request.setHeader('pTipoDeInstalador', instaladorTipo);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            System.debug('request'+request);
            System.debug('response'+response);
            System.debug('This is working'+response.getBody());

            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map


                System.debug('This is working'+response.getBody());
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                TS4_IS_GetInstaladores getInstaladoresResponse = (TS4_IS_GetInstaladores)JSON.deserialize(response.getBody(), TS4_IS_GetInstaladores.class);                
                System.debug('getInstaladoresResponse '+getInstaladoresResponse);

               /*for(TS4_IS_GetInstaladores.cls_TIENDAS instaladoresT: getInstaladoresResponse.DATOS.TIENDAS){
                    TranscriptOutput transOutput = new TranscriptOutput();
                    System.debug('This is working instaladores '+instaladoresT);
                    infoTiendas = 'TIENDA: '+instaladoresT.TIENDA+'\r\n'+'HORARIO: '+instaladoresT.HORARIO+'\r\n' +'DIRECCION: '+instaladoresT.DIRECCION+'\r\n' +'TELEFONO: '+instaladoresT.TELEFONO+'\r\n'+'URL: '+instaladoresT.URL;
                    transOutput.tienda =infoTiendas;
                    listTranscriptOutput.add(transOutput);

                }*/
                
                
               for(TS4_IS_GetInstaladores.cls_INSTALADORES instaladores: getInstaladoresResponse.DATOS.INSTALADORES){
                    TranscriptOutput transOutput = new TranscriptOutput();
                    System.debug('This is working instaladores '+instaladores);
                    //infoInstaladores = 'NOMBRE: '+instaladores.NOMBRE !=null?instaladores.NOMBRE:''+'\r\n'+'TELEFONO: '+instaladores.TELEFONO !=null?instaladores.TELEFONO:''+'\r\n' +'CELULAR: '+instaladores.CELULAR !=null?instaladores.CELULAR:''+'\r\n' +'TIPO: '+instaladores.TIPO !=null?instaladores.TIPO:'';
                   infoInstaladores = 'NOMBRE: '+instaladores.NOMBRE+'\r\n'+'TELEFONO: '+instaladores.TELEFONO+'\r\n' +'CELULAR: '+instaladores.CELULAR+'\r\n' +'TIPO: '+instaladores.TIPO;
                   transOutput.tienda =infoInstaladores;
                    listTranscriptOutput.add(transOutput);

                }
                System.debug('listTranscriptOutput tiendas '+listTranscriptOutput);
                //System.debug('listTranscriptOutputInst inst '+listTranscriptOutputInst);

            } else {
                // Throw a custom exception with the error message
                //throw new ExternalSystemException(response.getStatus() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
            //throw new ExternalSystemException('An error occurred while getting the token.');
        } finally {
           
        }
           return new List<List<TranscriptOutput>>{listTranscriptOutput};

    }
    
    public class TranscriptOutput {
        @InvocableVariable
        public String tienda; 

 
    }

}