trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            List<SBQQ__QuoteLine__c> quoteLines = Trigger.new;
            IQuoteLineUpdater updater = QuoteLineUpdaterFactory.getUpdater();
            try {
                updater.updateQuoteLines(quoteLines);
            } catch (QuoteLineUpdater.QuoteLineUpdaterException e) {
                for (SBQQ__QuoteLine__c qli : quoteLines) {
                    qli.addError(e.getMessage());
                }
            }
        }
    }
}