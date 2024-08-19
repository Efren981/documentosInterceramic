public class ScheduleGetFranquicias implements System.Schedulable {

    public void execute(SchedulableContext ctx){
        System.enqueueJob(New QueueableGetFranquicias());
    }
}