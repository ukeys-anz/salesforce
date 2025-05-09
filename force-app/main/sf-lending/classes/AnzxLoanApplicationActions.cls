/**
 * @author @ramvilas
 * @since April 2025
 * @description class for Loan Application Residential Loan Application actions
 * @runTests AnzxLoanApplicationActionsTest
 */
public with sharing class AnzxLoanApplicationActions {
    private static final String HOME_LOAN_APP_DEV_NAME = 'Home_Loan_Applications_Queue';
  
    private static final List<String> SUNSET_STATUSES = new List<String>{
      'STATE_UNSPECIFIED',
      'STATE_INELIGIBLE',
      'STATE_COMPLETED',
      'STATE_DECLINED',
      'STATE_CANCELLED',
      'STATE_EXPIRED'
    };
  
    /**
     * @description Assign Home Loan Applications Queue as owner
     * @param rlaRecords records to assign owner
     */
    public static void assignHomeLoanAppQueue(
      List<ResidentialLoanApplication> rlaRecords
    ) {
      ListUtil.setField(
        rlaRecords,
        ResidentialLoanApplication.OwnerId,
        QueryQueue.get(HOME_LOAN_APP_DEV_NAME)?.Id
      );
    }
    /**
     * @description Set the sunset timestamp date time value (usually for insert context)
     * @param records records to update
     * @return List<ResidentialLoanApplication> updated records
     */
    public static List<ResidentialLoanApplication> setSunsetTimestamp(
      List<ResidentialLoanApplication> records
    ) {
      List<ResidentialLoanApplication> recordsEnteringSunset = ListUtil.filter(
          records
        )
        .equals(ResidentialLoanApplication.Status, SUNSET_STATUSES)
        .toList();
  
      recordsEnteringSunset = ListUtil.setField(
        recordsEnteringSunset,
        ResidentialLoanApplication.SunsetTimestamp__c,
        System.now()
      );
  
      return records;
    }
  
    /**
     * @description Set the sunset timestamp date time value
     * @param records records to update
     * @param oldMap old records map
     * @return List<ResidentialLoanApplication> updated records
     */
    public static List<ResidentialLoanApplication> setSunsetTimestamp(
      List<ResidentialLoanApplication> records,
      Map<Id, ResidentialLoanApplication> oldMap
    ) {
      // Process the records
      List<ResidentialLoanApplication> recordsEnteringSunset = ListUtil.filter(
          records,
          oldMap
        )
        .changedTo(ResidentialLoanApplication.Status, SUNSET_STATUSES)
        .toList();
  
      List<ResidentialLoanApplication> recordsExitingSunset = ListUtil.filter(
          records,
          oldMap
        )
        .changedFrom(ResidentialLoanApplication.Status, SUNSET_STATUSES)
        .toList();
  
      // Set sunset timestamp
      recordsEnteringSunset = ListUtil.setField(
        recordsEnteringSunset,
        ResidentialLoanApplication.SunsetTimestamp__c,
        System.now()
      );
  
      recordsExitingSunset = ListUtil.setField(
        recordsExitingSunset,
        ResidentialLoanApplication.SunsetTimestamp__c,
        null
      );
  
      return records;
    }
  }
