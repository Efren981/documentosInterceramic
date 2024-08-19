@isTest
public class CaseWebServiceTest {
	@isTest
    public static void createCaseSoapTest(){
         String caseSubject = 'Problema con el producto';
        String caseDescription = 'El producto no funciona como se esperaba.';

        // Llamada al método webservice
        CaseWebService.CaseResponse response = CaseWebService.createCase(caseSubject, caseDescription);
    }
}