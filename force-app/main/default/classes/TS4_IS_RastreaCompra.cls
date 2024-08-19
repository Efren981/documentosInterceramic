public class TS4_IS_RastreaCompra {
    
    	public String FECHA_COMPRA;	//18/09/2020 20:47:03
	public Integer PORCENTAJE;	//100
	public cls_STATUS[] STATUS;
	public Double SUBTOTAL;	//2026.08
	public Integer COSTO_ENVIO;	//0
	public String MONEDA;	//MXN
	public Double TOTAL;	//2026.08
	public cls_METODO_ENVIO METODO_ENVIO;
	public String METODO_PAGO;	//PUE
	public cls_ARTICULOS[] ARTICULOS;
	public cls_DIRECCION[] DIRECCION;
	public cls_FACTURACION[] FACTURACION;
	class cls_STATUS {
		public String STATUS;	//delivered
		public String DESCRIPCION;	//Entregado
		public String FECHA_STATUS;	//22/09/2020 11:08:25
		public String FECHA_STATUSDESC;	//22 de Septiembre 11:08 AM
		public cls_ANEXOS[] ANEXOS;
	}
	class cls_ANEXOS {
		public String DESCRIPCION;	//Documento de entrega
		public String VALOR;	//https://obxr9vb5lb.execute-api.us-west-2.amazonaws.com/dev/consultaevidenciaentrega-get/1FE0A344083A0755848013E8B9DE2FF59700B47E8891A4D228474FDDB7249BA7
	}
	class cls_METODO_ENVIO {
	}
	class cls_ARTICULOS {
		public Integer ARTNUM;	//268323
		public Integer ID_COMERCIAL;	//1270
		public String DESCRIPCION;	//INFINITY COLLECTION BOTTICINO CREME 60X120 PRIMERA
		public Double PRECIO;	//675.36
		public Integer CANTIDA;	//3
		public Double TOTAL;	//2026.08
	}
	class cls_DIRECCION {
		public String CALLE;	// #
		public String NOMBRE_CLIENTE;	//Ruben  Contreras
	}
	class cls_FACTURACION {
		public String PAISCLAVE;	//1
		public String CALLE;	// #
	}
    
    @InvocableMethod(Label='Rastrea compra') 
    public static List<List<TranscriptOutput>> getRastreaCompra(List<String> ticketVenta) { //List<String> ticketVenta
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String infoCompra='';
        String infoDocumentoEntrega='';

        List<TranscriptOutput> listTranscriptOutput= new List<TranscriptOutput>();      
        //try {
            request.setEndpoint('callout:AWSRastreaCompra');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', 'tEswXEbVsFaIWHWrQgLVd8orlPgi6XVJ4TlU7L4S');
            request.setHeader('clave-modulo', 'Magento');
            //request.setHeader('Folio-Ticket', '202VWMECO2500');
            request.setHeader('Folio-Ticket', ticketVenta[0]);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            
            Http http = new Http();
            response = http.send(request);
            //System.debug('This is working'+response.getBody());

            if (response.getStatusCode() == 200) {
                // Use JSON.deserializeUntyped to parse the response body as a Map
                Blob decodedBlob = EncodingUtil.base64Decode(response.getBody());
                String decodedResponse = decodedBlob.toString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(decodedResponse);

                System.debug('results'+results);
                
                /*if(results.get('MENSAJE') !=null){
                    TranscriptOutput transOutput = new TranscriptOutput();
                    infoCompra=''+results.get('VBELN_E');
                    transOutput.compraStatus =infoCompra;
                    listTranscriptOutput.add(transOutput);
                    System.debug('entra if. mensaje');

                }else{*/
                    System.debug('entra else. mensaje');
                TS4_IS_RastreaCompra getSucursalesResponse = (TS4_IS_RastreaCompra)JSON.deserialize(decodedResponse, TS4_IS_RastreaCompra.class);                
                System.debug('getSucursalesResponse'+getSucursalesResponse);

                for(TS4_IS_RastreaCompra.cls_STATUS compra: getSucursalesResponse.STATUS){
                    TranscriptOutput transOutput = new TranscriptOutput();
                    if(compra.DESCRIPCION=='Entregado'){
                        
                        infoDocumentoEntrega=compra.ANEXOS[0].VALOR;
                        infoCompra = 'ESTADO: '+compra.DESCRIPCION+'\r\n'+'FECHA Y HORA: '+compra.FECHA_STATUSDESC+'\r\n'+'DOCUMENTO ENTREGA: '+infoDocumentoEntrega;                        
                        
                    }else{
                        infoCompra = 'ESTADO: '+compra.DESCRIPCION+'\r\n'+'FECHA Y HORA: '+compra.FECHA_STATUSDESC+'\r\n';
                        
                    }
                    transOutput.compraStatus =infoCompra;
                    listTranscriptOutput.add(transOutput);

                    
                //}
                //system.debug((TS4_IS_RastreaCompra) System.JSON.deserialize(decodedResponse, TS4_IS_RastreaCompra.class));


                }
                system.debug('listTranscriptOutput'+listTranscriptOutput);


            } else {
                // Throw a custom exception with the error message
                
            }

           
       /* } catch (Exception e) {
            // Log the exception and throw a custom exception
            System.debug(LoggingLevel.ERROR, 'Exception occurred while getting token: ' + e.getMessage());
           
        }*/
        return new List<List<TranscriptOutput>>{listTranscriptOutput};

    }
    
    public class TranscriptOutput {
        @InvocableVariable
        public String compraStatus; 
 
    }

}