public class CaseDailyCounterHandler {
    public static void assignDailyCounter(List<Case> newCases) {
        try {
            Date today = Date.today();
            
            List<Case> lastCasesToday = [SELECT TS4_DailyCounter__c 
                                         FROM Case 
                                         WHERE CreatedDate = TODAY 
                                         ORDER BY TS4_DailyCounter__c DESC 
                                         LIMIT 1];
            
            Integer counter = 0;
            if (!lastCasesToday.isEmpty()) {
                counter = Integer.valueOf(lastCasesToday[0].TS4_DailyCounter__c);
            }
            
            for (Case c : newCases) {
                counter++;
                c.TS4_DailyCounter__c = counter;
            }
        } catch (Exception e) {
            System.debug('Error en CaseDailyCounterHandler favor de notificar a su Administrador: ' + e.getMessage());
        }
    }
}