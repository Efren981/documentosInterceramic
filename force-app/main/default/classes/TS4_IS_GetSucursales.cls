public class TS4_IS_GetSucursales {
    
    public String RESULTADO;	//OK
	public String ALMACEN_ID;	//204CDCH
	public cls_TIENDAS[] TIENDAS;
	class cls_TIENDAS {
		public String TIENDA;	//Tienda Canal
		public String HORARIO;	//Lunes a Viernes de 9:00 a 19:00, Sábado de 9:00 a 14:00
		public String DIRECCION;	//Teófilo Borunda #1617, Col. Santo Niño, C.P. 31205, Chihuahua, Chihuahua
		public String TELEFONO;	//6144154022
	}

    
    @InvocableMethod(Label='Search sucursales') 
    public static List<List<TranscriptOutput>> createSigntaureRequest(List<String> postalCode){
                    System.debug('postalCode '+postalCode[0]);

     HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String infoTiendas='';
        List<TranscriptOutput> listTranscriptOutput= new List<TranscriptOutput>();      

        

            request.setEndpoint('callout:AWS_ObtenerSucursales');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('pPaisClave', '1');
            request.setHeader('pCodigoPostal', postalCode[0]);
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
                TS4_IS_GetSucursales getSucursalesResponse = (TS4_IS_GetSucursales)JSON.deserialize(response.getBody(), TS4_IS_GetSucursales.class);                
               

                for(TS4_IS_GetSucursales.cls_TIENDAS tiendas: getSucursalesResponse.TIENDAS){
                    TranscriptOutput transOutput = new TranscriptOutput();
                    infoTiendas = 'TIENDA: '+tiendas.TIENDA+'\r\n'+'HORARIO: '+tiendas.HORARIO+'\r\n' +'DIRECCION: '+tiendas.DIRECCION+'\r\n' +'TELEFONO: '+tiendas.TELEFONO+'\r\n' ;
                    transOutput.tienda =infoTiendas;
                    listTranscriptOutput.add(transOutput);

                }

            } else {
                // Throw a custom exception with the error message
            }
        return new List<List<TranscriptOutput>>{listTranscriptOutput};


    }
    
    
    public class TranscriptOutput {
        @InvocableVariable
        public String tienda; 
 
    }
}