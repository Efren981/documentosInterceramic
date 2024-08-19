public class ScheduleTheScheduleGetColonias implements System.Schedulable {

    public void execute(SchedulableContext SC) {
        Colonia_Pagination__c coloniaPages =  Colonia_Pagination__c.getInstance();
        Integer iPages = Integer.valueOf(coloniaPages.Pages__c);
        
        for(Integer i=0; i<iPages; i++){
            Datetime fecha = Datetime.now().addMinutes(i + 1);
            String day = String.valueOf(fecha.day());
            String month = String.valueOf(fecha.month());
            String year = String.valueOf(fecha.year());
            String hour = String.valueOf(fecha.hour());
            String minutes = String.valueOf(fecha.minute());
            String CRON_EXP = '';
            CRON_EXP = '0 ' + minutes + ' ' +  hour + ' ' + day + ' ' + month + ' ? ' + year;
            System.schedule('Get Colonies Page: ' + i + ' Fecha: ' + String.valueOf(Datetime.now()), CRON_EXP, new ScheduleGetColonias(i));
        }
    }
}