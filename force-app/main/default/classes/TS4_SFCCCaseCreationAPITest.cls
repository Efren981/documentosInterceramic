@isTest
public class TS4_SFCCCaseCreationAPITest {
    
    @testSetup
    public static void init(){
        Account testAccount = new Account(
            Name = 'Cuenta de Prueba', 
            Phone = '9876543234',
            INT_RFC__c = 'BATJ891502XXX'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'hola',
            LastName = 'hola prueba',
            Email = 'prueba@prueba.com',
            Phone = '5525116728', 
            MobilePhone = '5525118828',
            Title = 'operador',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Case newCase = new Case();
        newCase.AccountId =testAccount.Id; 
        newCase.ContactId = testContact.Id;
        newCase.TS4_Correo__c = 'tst@tst.com';
        newCase.Subject = 'Asunto prueba'; 
        newCase.Description = 'Descripcion prueba';
        newCase.TS4_Categoria__c = 'Por atender';
        newCase.Origin = 'Web';
        insert newCase;
        
        TS4_EnlaceDocumentos__c document = new TS4_EnlaceDocumentos__c();
        document.URL_Documento__c = 'https://main-repo-003.s3.us-west-2.amazonaws.com/casos/adjuntos/azujelo.jpeg';
        document.TS4_IdCaso__c = newCase.Id;
        insert document;
    }
    
    @isTest
    static void testCreateCaseWithDocuments() {
        Account testAccount=[Select Id from Account limit 1];
        Contact testContact = [Select Id from Contact limit 1];
        String jsonBody = '{"clientServiceId":"'+ testContact.Id + '","aliasSinter": "EBARCENAS","clientType": "Cliente final", "name": "Juan Manuel Solorzano Menchaca","email": "tst@tst.com","contactPhone": "2223334444","subject": "Test Case Postman prueba video con alias sinter con emaul", "ticket": "tst@tst.com","category": "Ventas","subcategory": "Ventas Web","description": "Pruebas","state": "Estado de Mexico", "municipality":"Nezahualcoyotl","origin":"Web","documents":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}]}';
        
        RestRequest request = new RestRequest();
        request.requestURI ='/services/apexrest/CaseWithAttachments/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_SFCCCaseCreationAPI.createCaseWithAttachments();
        Test.stopTest();
    }
    
    @isTest
    static void testCreateCaseWithDocumentsError() {
        String jsonBody = '{"clientServiceId":"","aliasSinter": "EBARCENAS","clientType": "Cliente final", "name": "Juan Manuel Solorzano Menchaca","email": "","contactPhone": "","subject": "Test Case Postman prueba video con alias sinter con emaul", "ticket": "tst@tst.com","category": "Ventas","subcategory": "Ventas Web","description": "Pruebas","state": "Estado de Mexico", "municipality":"Nezahualcoyotl","origin":"Web","documents":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}]}';
        
        RestRequest request = new RestRequest();
        request.requestURI ='/services/apexrest/CaseWithAttachments/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_SFCCCaseCreationAPI.createCaseWithAttachments();
        Test.stopTest();
    }
        @isTest
    static void testCreateCaseWithDocumentsException() {
        // Caso con ID de contacto inválido para provocar un error en la consulta
        String jsonBody = '{"clientServiceId":"noExiste","aliasSinter": "noExiste","clientType": "Cliente final", "name": "Juan Manuel Solorzano Menchaca","email": "2222","contactPhone": "2223334444","subject": "Test Case Postman prueba video con alias sinter con emaul", "ticket": "tst@tst.com","category": "Ventas","subcategory": "Ventas Web","description": "Pruebas","state": "Estado de Mexico", "municipality":"Nezahualcoyotl","origin":"Web","documents":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}]}';
        
        RestRequest request = new RestRequest();
        request.requestURI ='/services/apexrest/TS4_SFCCCaseCreationAPI/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = request;
        
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        Test.startTest();
        TS4_SFCCCaseCreationAPI.createCaseWithAttachments();
        Test.stopTest();
        
	}
}