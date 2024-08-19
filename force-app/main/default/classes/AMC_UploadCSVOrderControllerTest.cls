@IsTest
private with sharing class AMC_UploadCSVOrderControllerTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(acc);
    }

    @isTest
    static void uploadFileExceptionTest() {
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        try {
            AMC_UploadCSVOrderController.uploadFile(opportunityId, 'csvData');
        } catch(AuraHandledException ex) {
            System.assertEquals(false, String.IsBlank(ex.getMessage()));
        }
        Test.stopTest();
    }

    @isTest
    static void uploadFileException2Test() {
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<AMC_UploadCSVOrderController.CSVData> csvData = new List<AMC_UploadCSVOrderController.CSVData>{new AMC_UploadCSVOrderController.CSVData()};
        Test.startTest();
        try {
            AMC_UploadCSVOrderController.uploadFile(opportunityId, JSON.serialize(csvData));
        } catch(AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void uploadFileTest() {
        User admin = [SELECT Id, Name  FROM User WHERE (Profile.Name = 'System Administrator' OR Profile.Name = 'Administrador del sistema') AND IsActive = true LIMIT 1]; 
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        AMC_UploadCSVOrderController.CSVData data = new AMC_UploadCSVOrderController.CSVData();
        data.Cantidad = '10';
        List<AMC_UploadCSVOrderController.CSVData> csvData = new List<AMC_UploadCSVOrderController.CSVData>{data};
        Test.startTest();
        try {
            AMC_UploadCSVOrderController.uploadFile(opportunityId, JSON.serialize(csvData));
        } catch(AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }
}