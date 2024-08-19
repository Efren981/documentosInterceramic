@isTest
private class AttachPDFToOpportunityTest {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount();
        Opportunity testOpportunity = TestDataFactory.createOpportunity(acc);
    }

    @isTest
    public static void testCheckOpportunityAttachment() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        // Call the method to be tested
        Boolean hasAttachment = AttachPDFToOpportunity.checkOpportunityAttachment(testOpportunity.Id);

        // Perform the assertion
        System.assertEquals(false, hasAttachment, 'Opportunity should not have an attachment yet');
    }

    @isTest
    public static void testInsertPDFAsAttachment() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        // Call the method to be tested
        Test.startTest();
        String result = AttachPDFToOpportunity.insertPDFAsAttachment(testOpportunity.Id);
        Test.stopTest();

        // Perform the assertions
        System.assertEquals('OK', result, 'Inserting PDF as attachment should return OK');

        // Retrieve the ContentVersion records related to the Opportunity
        List<ContentVersion> contentVersions = [
            SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE FirstPublishLocationId = :testOpportunity.Id
        ];

        // Perform additional assertions to verify that the ContentVersion record is created as expected
        System.assertEquals(1, contentVersions.size(), 'There should be one ContentVersion record');
        ContentVersion contentVersion = contentVersions[0];
        System.assertNotEquals(null, contentVersion.ContentDocumentId, 'ContentDocumentId should not be null');
        //System.assertEquals(testOpportunity.Name + '.pdf', contentVersion.Title, 'ContentVersion Title should match the opportunity name');
    }
}