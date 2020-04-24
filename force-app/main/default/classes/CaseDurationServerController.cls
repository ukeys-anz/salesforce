/**
 *
 * @author Lance Shi
 * @since 2020
 * @description CaseDurationServerController is apex side controller for caseDuration LWC
 */
public with sharing class CaseDurationServerController {
  /**
   * @description The Case record page has a lwc which needs to fetch the duration information on demand on a case record page based on case Id.
   *
   * @param caseId the case id of the related case record
   * @return `DurationTime`
   */
  @AuraEnabled
  public static DurationTime getCaseDurationTime(String caseId) {
    List<Case> caseList;
    if (Case.sObjectType.getDescribe().isQueryable()) {
      caseList = [
        SELECT Id, Duration_Hours__c, Duration_Minutes__c, BusinessHoursId
        FROM Case
        WHERE Id = :caseId
      ];
    }

    if (caseList.isEmpty()) {
      //Should not happen in normal usage
      AuraHandledException ahe = new AuraHandledException(
        'Failed to load case duration data'
      );
      ahe.setMessage('Failed to load case duration data');
      throw ahe;
    }

    List<Case_Duration__c> relatedCdList;
    if (Case_Duration__c.sObjectType.getDescribe().isQueryable()) {
      relatedCdList = [
        SELECT Id, Start_Time__c
        FROM Case_Duration__c
        WHERE
          Case__c = :caseId
          AND Initial_Status__c != 'On Hold'
          AND Initial_Status__c != 'Closed'
          AND End_Time__c = null
        ORDER BY CreatedDate DESC
      ]; // Should only have 0 or 1 record
    }

    return calculateDurationTime(caseList, relatedCdList);
  }

  /**
   * @description calculate the duration time of the current case up to now when the page loads.
   *
   * @param caseList the related case
   * @param relatedCdList the related case duration if there is any
   * @return `DurationTime`
   */
  private static DurationTime calculateDurationTime(
    List<Case> caseList,
    List<Case_Duration__c> relatedCdList
  ) {
    long durationHours = (long) (caseList[0].Duration_Hours__c != null
      ? caseList[0].Duration_Hours__c
      : 0);
    long durationMinutes = (long) (caseList[0].Duration_Minutes__c != null
      ? caseList[0].Duration_Minutes__c
      : 0);

    long tillNowDurationMins = 0;
    long tillNowDurationHours = 0;
    if (!relatedCdList.isEmpty()) {
      Decimal timeDifferenceInHours = DateTimeUtils.calculateHoursBetween(
        relatedCdList[0].Start_Time__c,
        DateTime.now(),
        caseList[0].BusinessHoursId
      );
      tillNowDurationHours = timeDifferenceInHours.longValue();
      tillNowDurationMins = ((timeDifferenceInHours - tillNowDurationHours) *
        SFConstants.MIN_IN_HOUR)
        .longValue();
    }

    DurationTime returnedData = new DurationTime();
    returnedData.durationHours = durationHours + tillNowDurationHours;
    returnedData.durationMins = durationMinutes + tillNowDurationMins;

    if (returnedData.durationMins >= 60) {
      returnedData.durationHours += 1;
      returnedData.durationMins -= 60;
    }

    return returnedData;
  }

  /**
		@description wrapper class of the duration time
	  */
  public class DurationTime {
    @AuraEnabled
    public long durationHours;
    @AuraEnabled
    public long durationMins;
  }
}
