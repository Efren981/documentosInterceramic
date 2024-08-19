global class CaseWebService {

    global class CaseResponse {
        webservice String caseId;
        webservice String caseNumber;
        webservice String message;
    }

    webservice static CaseResponse createCase(String caseSubject, String caseDescription, String contactNumber) {
        CaseResponse response = new CaseResponse();
        try {
            Case newCase = new Case(
                Subject = caseSubject,
                Description = caseDescription,
                Origin = 'Teléfono', 
                TS4_ContactoRegistro__c = contactNumber
            );
            insert newCase;

            response.caseId = newCase.Id;
            response.caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id].CaseNumber;
            response.message = 'Caso creado exitosamente';
        } catch (Exception e) {
            response.message = 'Error al crear el caso: ' + e.getMessage();
        }
        return response;
    }
}