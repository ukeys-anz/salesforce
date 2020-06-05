/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2020
 * @description  Batch class for calculating and updating case duration on hourly basis.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class BatchUpdateCaseDuration implements Database.Batchable<sObject>, Database.Stateful {
  /**
   * @description To collect the case duration records for processing
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT ID, Start_Time__c, Case__c, Case__r.Status_Change_Duration__c, Case__r.Duration_Hours__c, Case__r.Duration_Minutes__c, Case__r.BusinessHoursId FROM Case_Duration__c ' +
      'WHERE Initial_Status__c != \'On Hold\' AND Initial_Status__c != \'Closed\' AND End_Time__c = null ' +
      'AND Case__r.RecordType.DeveloperName = \'General_Inquiry\' Order By Createddate DESC'
    );
  }
  /**
   * @description To Calculate and batch update case duration in case object
   * @param bc Database.BatchableContext
   * @param scope from start method
   */
  global void execute(
    Database.BatchableContext bc,
    List<Case_Duration__c> scope
  ) {
    List<Case> updateCaseList = new List<Case>();
    for (Case_Duration__c cd : scope) {
      long durationHours = 0;
      long durationMinutes = 0;
      Decimal timeDifferenceInHours = 0;

      decimal statusChangeDurationHours = (decimal) (cd.Case__r.Status_Change_Duration__c !=
        null
        ? cd.Case__r.Status_Change_Duration__c
        : 0);

      timeDifferenceInHours = DateTimeUtils.calculateHoursBetween(
        cd.Start_Time__c,
        DateTime.now(),
        cd.Case__r.BusinessHoursId
      );

      Decimal finalDurationHours =
        statusChangeDurationHours + timeDifferenceInHours;
      durationHours = finalDurationHours.longValue();
      durationMinutes = ((finalDurationHours - durationHours) *
        SFConstants.MIN_IN_HOUR)
        .longValue();

      Case updateCase = new Case();
      updateCase.Id = cd.Case__c;
      updateCase.Duration_Hours__c = durationHours;
      updateCase.Duration_Minutes__c = durationMinutes;
      updateCaseList.add(updateCase);
    }

    if (!updateCaseList.isEmpty()) {
      List<Database.SaveResult> results = Database.Update(
        updateCaseList,
        false
      );

      //call application log functions to log results incase of failure
      lib_systemLog log = new lib_systemLog(
        'BatchUpdateCaseDuration',
        'Execute',
        bc.getJobId()
      );
      log.addDatabaseSaveResult('Case', results, updateCaseList);
      log.insertLog();
    }
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */

  @SuppressWarnings('PMD.EmptyStatementBlock')
  global void finish(Database.BatchableContext bc) {
    //No post processing steps as of now
  }
}
