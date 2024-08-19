@RestResource(urlMapping='/CasosPagination/*')
global with sharing class CasosPagination {

    private static final Integer MAX_RECORDS = 50000;

    @HttpGet
    global static void getCasesPagination() {
        Map<String, Object> mapName = new Map<String, Object>();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        //Obtener parametro del URL
        Integer pageNumber = Integer.valueOf(request.params.get('pageNumber'));
        Integer pageSize = Integer.valueOf(request.params.get('pageSize'));
        String idSinter = request.params.get('idSinter');

        if (pageSize == null || pageSize <= 0) {
            pageSize = 10;
        }

        if (pageNumber == null || pageNumber <= 0) {
            pageNumber = 1;
        }

        if (String.isBlank(idSinter)) {
            mapName.put('error', 'El parámetro idSinter es requerido');
            response.addHeader('Content-Type', 'application/json');            
                             response.responseBody = Blob.valueOf(JSON.serialize(mapName));            
                             response.statusCode = 404;
            return;
        }

        // Obtener todos los Id de casos filtrados por IdSinter
        List<Id> allCaseIds = new List<Id>();
        for (Case c : [SELECT Id 
                       FROM Case 
                       WHERE Contact.TS4_Cost_UsuSinter__c = :idSinter 
                       ORDER BY CreatedDate ASC 
                       LIMIT :MAX_RECORDS]) {
            allCaseIds.add(c.Id);
        }
        Integer offset = (pageNumber -1) * pageSize;

        Integer totalRecords = allCaseIds.size();
        Integer totalPages = Math.ceil(Decimal.valueOf(totalRecords) / Decimal.valueOf(pageSize)).intValue();

        //Calcular rango de IDs para la pagina solicitada
        Integer startIndex = (pageNumber - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, totalRecords);

        List<Id> pageIds = new List<Id>();
        for (Integer i = startIndex; i < endIndex; i++) {
            pageIds.add(allCaseIds[i]);
        }

        //Obtener los casos para los IDs calculados
        List<Case> casos = [SELECT Id, CaseNumber, Subject, Status, Contact.TS4_Cost_UsuSinter__c
                            FROM Case
                            WHERE Id IN :pageIds
                            ORDER BY CreatedDate ASC];

                             mapName.put('casos', casos);
                             mapName.put('totalRecords', totalRecords);
                             mapName.put('totalRecords', totalRecords);
                             mapName.put('pageSize', pageSize);
                             mapName.put('pageNumber', pageNumber);
                             mapName.put('totalPages', totalPages);
                             response.addHeader('Content-Type', 'application/json');            
                             response.responseBody = Blob.valueOf(JSON.serialize(mapName));            
                             response.statusCode = 200;
                            return;

    }
}