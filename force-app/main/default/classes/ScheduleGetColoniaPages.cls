public class ScheduleGetColoniaPages implements System.Schedulable {
    public void execute(SchedulableContext SC) {
        System.enqueueJob(new QueueableGetColoniaPages());
    }
}