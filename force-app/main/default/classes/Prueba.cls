public class Prueba {
    
    @InvocableMethod(Label='prueba')
    public static List<List<TranscriptOutput>> prueba(){
        String infoCompra='';
        List<TranscriptOutput> listTranscriptOutput= new List<TranscriptOutput>();      

        TranscriptOutput transOutput = new TranscriptOutput();
        
        infoCompra='Hola';
        transOutput.compraStatus =infoCompra;
        listTranscriptOutput.add(transOutput);
        return new List<List<TranscriptOutput>>{listTranscriptOutput};
            
            }
    public class TranscriptOutput {
        @InvocableVariable
        public String compraStatus; 
        
    }



}