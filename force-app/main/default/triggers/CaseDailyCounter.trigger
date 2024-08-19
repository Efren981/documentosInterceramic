trigger CaseDailyCounter on Case (before insert) {
    CaseDailyCounterHandler.assignDailyCounter(Trigger.new);
}