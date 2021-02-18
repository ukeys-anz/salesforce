public with sharing class IDRTaskActions {
     // IDR Non Customer Record Type ID
  @TestVisible
  static final Id IDR_MAXIMUM_TIME_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('IDR_System_Task')
    .getRecordTypeId();
  	 public static void beforeInsertActions(list<Task> records ){
        checkIDRMaximumTimeTasks(records);
    }
    public static void afterInsertActions(list<Task> records ){
        closeOldIDRMaximumTimeTasks(records);
    }
    public static void afterUpdateActions(list<Task> records ){
        closeMilestonesOfClosedTask(records);
    }
    private static void closeOldIDRMaximumTimeTasks(list<Task> taskRecs){  
       Set<Id> currentTask = new set<Id> ();
        Map<Id,ID> caseTaskMap = new Map<Id,ID> ();
        for (Task record : taskRecs){
            if (record.RecordTypeId == IDR_MAXIMUM_TIME_RT_ID) { 
                currentTask.add(record.Id);
                 caseTaskMap.put(record.WhatId, record.Id);   
            }
        } 
         
        if (caseTaskMap.size()>0){
          list<task> oldTasks = [Select Id,Status,subject from Task 
                                 where WhatId in :caseTaskMap.keySet() 
                                 AND RecordTypeId =:IDR_MAXIMUM_TIME_RT_ID
                                 AND Id not in :currentTask 
                                 AND Status != :IDRConstants.TASK_STATUS_COMPLETED
                                 AND Status != :IDRConstants.TASK_STATUS_EXPIRED ];
            for (task t: oldTasks){
                t.status = IDRConstants.TASK_STATUS_EXPIRED;
            }
            if (oldTasks.size() > 0){
                update oldTasks;
            }
        }           
    }
    private static void checkIDRMaximumTimeTasks(list<Task> taskRecs){
        list<Task> idrMaixmumTimeTasks = new list<Task> ();
        Map<Id,ID> taskCaseMap = new Map<Id,ID> ();
        set<Id> caseIdSet = new set<Id> ();   
    	Map<Id,String> caseTaskMap = new Map<Id,String>() ;
        for (Task record : taskRecs){
            if (record.subject == IDRConstants.TASK_SUBJECT_DAY7 
                || record.subject == IDRConstants.TASK_SUBJECT_DAY5 
                || record.subject == IDRConstants.TASK_SUBJECT_DAY3  
                || record.subject == IDRConstants.TASK_SUBJECT_DAY1  ) {
				record.RecordTypeId = IDR_MAXIMUM_TIME_RT_ID; 
                if(!caseIdSet.contains(record.WhatId) 
                    ||(record.subject == IDRConstants.TASK_SUBJECT_DAY1) 
                   	||(record.subject == IDRConstants.TASK_SUBJECT_DAY5 && (caseTaskMap.get(record.WhatId) == IDRConstants.TASK_SUBJECT_DAY7 ))
                    ||(record.subject == IDRConstants.TASK_SUBJECT_DAY3   
                       && (caseTaskMap.get(record.WhatId) == IDRConstants.TASK_SUBJECT_DAY5 || caseTaskMap.get(record.WhatId) == IDRConstants.TASK_SUBJECT_DAY7 ))
                    
                   ){
                 	caseTaskMap.put(record.WhatId,record.subject) ;
                }
                idrMaixmumTimeTasks.add(record);
                taskCaseMap.put(record.Id,record.WhatId); 
                
                caseIdSet.add(record.WhatId);
            }
        }
        Map<Id,Case> caseMap = new Map<Id,Case>();
        if (caseIdSet.size()>0){
            list<case> relatedCaseList = [select Id , BusinessHoursId , IDR_Date_Received__c , Priority  from Case where Id in :caseIdSet];
            for (case c : relatedCaseList){
               caseMap.put(c.ID, c);
            }
        }
        for (Task record : IDRMaixmumTimeTasks){
                datetime expectedDueDate ;
            if(record.Subject == IDRConstants.TASK_SUBJECT_DAY7 && caseMap.get(record.WhatId).Priority == IDRConstants.TASK_STANDARD_PRIORITY ){
              	expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			23); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY7 && caseMap.get(record.WhatId).Priority != IDRConstants.TASK_STANDARD_PRIORITY ){
              	expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			14); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY5 && caseMap.get(record.WhatId).Priority == IDRConstants.TASK_STANDARD_PRIORITY  ){
                expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			25); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY5 && caseMap.get(record.WhatId).Priority != IDRConstants.TASK_STANDARD_PRIORITY  ){
                expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			16); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY3 && caseMap.get(record.WhatId).Priority == IDRConstants.TASK_STANDARD_PRIORITY  ){
                expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			27); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY3 && caseMap.get(record.WhatId).Priority != IDRConstants.TASK_STANDARD_PRIORITY  ){
                expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			18); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY1 && caseMap.get(record.WhatId).Priority == IDRConstants.TASK_STANDARD_PRIORITY){
                expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			29); 
            }else if(record.Subject == IDRConstants.TASK_SUBJECT_DAY1 && caseMap.get(record.WhatId).Priority != IDRConstants.TASK_STANDARD_PRIORITY){
                expectedDueDate =  addDays(
                    			caseMap.get(record.WhatId).BusinessHoursId,
                    			caseMap.get(record.WhatId).IDR_Date_Received__c,
                    			20); 
            }
            if (record.ActivityDate > date.valueof(expectedDueDate)){
                record.ActivityDate = date.valueof(expectedDueDate);              
             }
            
            if (record.subject != caseTaskMap.get(record.WhatId)){
                record.Status = IDRConstants.TASK_STATUS_EXPIRED;
            }
         }
           
 	}
    private static void closeMilestonesOfClosedTask(list<Task> taskRecs){  
        set<Id> caseIDSet = new Set<Id>();
        for (task t: taskRecs){
            if (t.RecordTypeId == IDR_MAXIMUM_TIME_RT_ID && t.Status == 'Completed'){
                caseIDSet.add(t.WhatId);
            }
        }
        
        if (caseIDSet.size()>0){
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
     public static datetime addDays(id BusinessHrs , datetime startDate , integer daysToAdd ){
        datetime newDate = startDate;
        for(integer i=1; i<= daysToAdd; i++ ){
            newDate = newDate.addDays(1);
            if(!BusinessHours.isWithin(BusinessHrs,newDate)){
                newDate = BusinessHours.nextStartDate(BusinessHrs, newDate);
            }
        }
        
        return newDate;
    }
}