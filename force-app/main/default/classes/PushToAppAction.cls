/**
 * @author Kopal Goswami
 * @since April 2025
 * @description This class is used to perform Task DML operations on Customer action on Mobile App
 */
public with sharing class PushToAppAction {
    
    private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
        DmlRepository.class
      );
  
      /**
       * @description this method is used to append TaskNumber field autonumber value to the Subject after creation and taskid into pubSubEventId
       * @param taskRecords list of Customer Nudge task records for which update to be done
       */
      public static void updateCustomerNudgeTask(List<Task> taskRecords)
      {
          try{
              List<Task> tasksToUpdate = new List<Task>();
              for (Task taskRec : taskRecords) {
                  Task taskRecRef = new Task(Id = taskRec.Id);
                  taskRecRef.Subject = taskRec.TaskNumber__c + ' - ' + taskRec.Subject;
                  taskRecRef.Pub_Sub_Event_Id__c = taskRec.Pub_Sub_Event_Id__c + taskRec.Id;
                  tasksToUpdate.add(taskRecRef);
              }
              DML_REPOSITORY.doUpdate(tasksToUpdate);
          }
          catch(Exception objException){
              throw CommonUtil.logException(objException);
          }   
      }
  
  
       /**
       * @description create task cloud event 
       * @param taskRecords list of Customer Nudge task records 
       */
      public static void createTaskCloudEvent(List<Task> taskRecords) {
          List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
          
          for (Task taskRec : taskRecords) {
              cloudEventModels.add(new CustomerNudgeTaskCloudEventModel(taskRec)); 
            }
         
          CloudEventController.publishCloudEvents(cloudEventModels); 
      }
}
