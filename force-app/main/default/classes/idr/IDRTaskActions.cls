/**
 * @author Himabindu Nekkanti
 * @since  02/2021
 * @description IDRTaskActions is class to handle all the IDR (Internal Dispute Resolution) Actions
 */
public with sharing class IDRTaskActions {
     // IDR Maximum time Record Type ID
  @TestVisible
  static final Id IDR_MAXIMUM_TIME_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('IDR_System_Task')
    .getRecordTypeId();
    /**
   * @description beforeInsertActions is called onBeforeInsert. any logic that needs to be executed on before insert is executed from here
   * @param records The Task record list.
   */
  	 public static void beforeInsertActions(list<Task> records ){
        checkIDRMaximumTimeTasks(records);
    }
    /**
   * @description afterInsertActions is called onAfterInsert. any logic that needs to be executed on after insert is executed from here
   * @param records The Task record list.
   */
    public static void afterInsertActions(list<Task> records ){
        closeOldIDRMaximumTimeTasks(records);
    }
    /**
   * @description afterUpdateActions is called onAfterUpdate. any logic that needs to be executed on after Update is executed from here
   * @param records The Task record list.
   */
    public static void afterUpdateActions(list<Task> records ){
        closeMilestonesOfClosedTask(records);
    }
    /**
   * @description closeOldIDRMaximumTimeTasks will close out old IDR Task reminders against case when a new Task is created.
   * @param taskRecs The Task record list.
   */
    private static void closeOldIDRMaximumTimeTasks(list<Task> taskRecs){  
       Set<Id> currentTask = new set<Id> ();
        Map<Id,ID> caseTaskMap = new Map<Id,ID> ();
        for (Task record : taskRecs){
            if (record.RecordTypeId == IDR_MAXIMUM_TIME_RT_ID) { 
                currentTask.add(record.Id);
                 caseTaskMap.put(record.WhatId, record.Id);   
            }
        } 
         
        list<task> oldTasks = new list<task>();
        if(caseTaskMap.size()>0 && case.sObjectType.getDescribe().isQueryable()){  
            oldTasks = [Select Id,Status,subject from Task 
                            where WhatId in :caseTaskMap.keySet() 
                            AND RecordTypeId =:IDR_MAXIMUM_TIME_RT_ID
                            AND Id not in :currentTask 
                            AND Status != :IDRConstants.TASK_STATUS_COMPLETED
                            AND Status != :IDRConstants.TASK_STATUS_EXPIRED ];

        }     
        for (task t: oldTasks){
            t.status = IDRConstants.TASK_STATUS_EXPIRED;
        }
        if (oldTasks.size() > 0 && task.sObjectType.getDescribe().isUpdateable()){
            update oldTasks;
        }                          
    }
     /**
   * @description checkIDRMaximumTimeTasks will perform the following actions.
   *1. since record type cannot be set from milestone , the appriapriate Task record type will be set here. 
   *2. Edge case scenarios: In the event case is created with a very old date recieved the milestone will create IDR tasks with wrong due date. 
   *   we will recalaulate and adust the date to correct date here and also expire any unwanted tasks.                            
   * @param taskRecs The Task record list.
   */
    private static void checkIDRMaximumTimeTasks(list<Task> taskRecs){
        list<Task> idrMaixmumTimeTasks = new list<Task> ();
        Map<Id,ID> taskCaseMap = new Map<Id,ID> ();
    	Map<Id,String> caseTaskMap = new Map<Id,String>() ;
        for (Task record : taskRecs){
            if (record.subject == IDRConstants.TASK_SUBJECT_DAY5   
                || record.subject == IDRConstants.TASK_SUBJECT_DAY1  ) {
				record.RecordTypeId = IDR_MAXIMUM_TIME_RT_ID; 
                idrMaixmumTimeTasks.add(record);
                taskCaseMap.put(record.Id,record.WhatId); 
            }
            if(record.RecordTypeId == IDR_MAXIMUM_TIME_RT_ID 
                    && (!caseTaskMap.KeySet().contains(record.WhatId) 
                    ||(record.subject == IDRConstants.TASK_SUBJECT_DAY1)))
                    {    
                 	caseTaskMap.put(record.WhatId,record.subject) ;
                }
        }

        validateDueDate(idrMaixmumTimeTasks,caseTaskMap);
        
 	}
     /**
   * @description validateDueDate will validate update the due date for IDR Tasks.                            
   * @param IDRMaixmumTimeTasks The Task record.
   * @param caseTaskMap  map of case  id and task subjects  
   */
    public static void validateDueDate(list<task> idrMaixmumTimeTasks, Map<id,string> caseTaskMap){
            Map<Id,Case> caseMap = new Map<Id,Case>();
            list<case> relatedCaseList = new list<case>();
            if(case.sObjectType.getDescribe().isQueryable() && caseTaskMap.size()>0 ){
                relatedCaseList = [select Id , BusinessHoursId , IDR_Date_Received__c , Priority  from Case where Id in :caseTaskMap.keySet()];
            }
            for (case c : relatedCaseList){
                caseMap.put(c.ID, c);
            }
            for (Task record : idrMaixmumTimeTasks){
                datetime expectedDueDate = calculateExpectedDue(record ,caseMap.get(record.WhatId));
            
                if (record.ActivityDate > date.valueof(expectedDueDate)){
                    record.ActivityDate = date.valueof(expectedDueDate);              
                }
            
                if (record.subject != caseTaskMap.get(record.WhatId)){
                    record.Status = IDRConstants.TASK_STATUS_EXPIRED;
                }
         }
           
    }
     /**
   * @description calculateExpectedDue will calaulate the what the due date must be for IDR Tasks.                            
   * @param record The Task record.
   * @param caseRec the case record that this task is related to.
   * @return datetime new datetime value that expected to be the due date based on the task and case parms.
   */
    public static datetime calculateExpectedDue(task record, case caseRec){
        datetime expectedDueDate;
        if(record.Subject == IDRConstants.TASK_SUBJECT_DAY5 && caseRec.Priority == IDRConstants.TASK_STANDARD_PRIORITY  ){
                expectedDueDate =  DateTimeUtils.addBusinessDays(
                    			caseRec.BusinessHoursId,
                    			caseRec.IDR_Date_Received__c,
                    			25); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY5 && caseRec.Priority != IDRConstants.TASK_STANDARD_PRIORITY  ){
                expectedDueDate =  DateTimeUtils.addBusinessDays(
                    			caseRec.BusinessHoursId,
                    			caseRec.IDR_Date_Received__c,
                    			16); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY1 && caseRec.Priority == IDRConstants.TASK_STANDARD_PRIORITY){
                expectedDueDate =  DateTimeUtils.addBusinessDays(
                    			caseRec.BusinessHoursId,
                    			caseRec.IDR_Date_Received__c,
                    			29); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY1 && caseRec.Priority != IDRConstants.TASK_STANDARD_PRIORITY){
                expectedDueDate =  DateTimeUtils.addBusinessDays(
                    			caseRec.BusinessHoursId,
                    			caseRec.IDR_Date_Received__c,
                    			20); 
            }
        return expectedDueDate;
    }
    /**
   * @description closeMilestonesOfClosedTask will mark Maximum IDR milestones as completed
   *               when the corresponding Taks completed.
   *                             
   * @param taskRecs List of task records.
   */
    private static void closeMilestonesOfClosedTask(list<Task> taskRecs){  
        set<Id> caseIDSet = new Set<Id>();
        for (task t: taskRecs){
            if (t.RecordTypeId == IDR_MAXIMUM_TIME_RT_ID && t.Status == 'Completed'){
                caseIDSet.add(t.WhatId);
            }
        }
        
        if (caseIDSet.size()>0 && CaseMilestone.sObjectType.getDescribe().isUpdateable()){
            List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm 
                                              where caseId in :caseIDSet and 
                                               	(cm.MilestoneType.Name= :IDRConstants.MILESTONE_STANDARD or cm.MilestoneType.Name= :IDRConstants.MILESTONE_PRIORITY )
            									and completionDate = null limit 1];
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = system.now();
            }
            
            if(cmsToUpdate.size() >0){
                update cmsToUpdate;
            }
            
        }
    }
     
}