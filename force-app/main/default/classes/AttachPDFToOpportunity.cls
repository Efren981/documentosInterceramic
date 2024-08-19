public without sharing class AttachPDFToOpportunity {
    
    @AuraEnabled
    public static Boolean checkOpportunityAttachment(Id opportunityId) {
        //Integer attachmentCount = [SELECT COUNT() FROM Attachment WHERE ParentId = :opportunityId];
        Integer attachmentCount = [SELECT COUNT() FROM ContentVersion WHERE contentVersion.FirstPublishLocationId = :opportunityId];
        return attachmentCount > 0;
    }
    
    @AuraEnabled
    public static String insertPDFAsAttachment(Id opportunityId) {
        System.debug('opportunityId ' + opportunityId);
        
        if (opportunityId != null) {
            Opportunity opp = [SELECT Name, INT_Id_Convenio__c, SBQQ__PrimaryQuote__r.Name FROM Opportunity WHERE Id = :opportunityId];
            if (opp != null) {
                String oppName = opp.SBQQ__PrimaryQuote__r.Name;
                String oppIdConvenio = opp.INT_Id_Convenio__c;
                
                // Generate the PDF content from the Visualforce page
                PageReference pdfPage = new PageReference('/apex/PDFProyectoObra_vfp');
                pdfPage.getParameters().put('id', opportunityId);
                Blob pdfContent = Test.isRunningTest() ? blob.valueOf('Unit.Test') : pdfPage.getContent();
                
                // Create the attachment
                /*Attachment attachment = new Attachment();
                attachment.ParentId = opportunityId;
                attachment.Name = oppIdConvenio + '_' + oppName + '.pdf';
                attachment.Body = pdfContent;
                attachment.ContentType = 'application/pdf';
                
                insert attachment;*/
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = oppIdConvenio + '_' + oppName + '.pdf';
                contentVersion.PathOnClient = '/' + oppIdConvenio + '_' + oppName + '.pdf';
                contentVersion.VersionData = pdfContent;
                contentVersion.FirstPublishLocationId = opportunityId;
                
                insert contentVersion;
                
                return 'OK';
            }
        }
        return 'Error';
    }
}