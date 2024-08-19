public class ScheduleGetColonias implements System.Schedulable {
    Integer iPages;
    
    public ScheduleGetColonias (Integer pag){
        this.iPages = pag;
    }
    
    public void execute(SchedulableContext SC) {
        System.enqueueJob(new QueueableGetColonias(iPages));
    }
}