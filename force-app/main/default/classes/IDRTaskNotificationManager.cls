public with sharing class IDRTaskNotificationManager {
    
    public static void manageNotificationForTaskReminders(List<Task> taskList){
        List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
        for(Task t : taskList){
            Integer daysBetweenTaskDueDate = Date.today().daysBetween(t.ActivityDate);
            Boolean isDueDateWithinWindow = Label.IDR_Window_For_Task_Reminders.split(',').contains(String.valueOf(daysBetweenTaskDueDate))? true : false ;
            if(isDueDateWithinWindow){
                wrapperList.add(createNotification(t, daysBetweenTaskDueDate));
            }           
        }

        IDRBankerNotificationBuilder.sendNotification(wrapperList);

    }

    public static IDRBankerNotificationWrapper createNotification(Task t, Integer daysRemainingFromDue){
        String msgBody = 'Your task to : '+t.Subject+' is due in '+daysRemainingFromDue+' days, '+'Make sure you action it before due date';
        IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(t, new List<Id>{ t.OwnerId }, t.Id, msgBody, null);
        return wrapper;
    }
}
