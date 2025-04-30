/**
 * @author @ramvilas
 * @since April 2025
 * @description Test class for RLA Loan Application actions
 */
@isTest
private class AnzxLoanApplicationActionsTest {
  private static final String BROKER_CODE = 'TPMI123456789';
  private static final String SUNSET_STATUS = 'STATE_UNSPECIFIED';
  private static final String NON_SUNSET_STATUS = 'STATE_CAPTURE';
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );

  @isTest
  static void testLoanAppOwnerAssignment() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToInsert = createResidentialLoanApplications(
      1
    );
    // Test insert scenarios
    Test.startTest();
    AnzxLoanApplicationActions.assignHomeLoanAppQueue(testLoanAppsToInsert);
    Test.stopTest();

    Assert.areEqual(
      testLoanAppsToInsert[0].OwnerId,
      QueryQueue.get('Home_Loan_Applications_Queue').Id,
      'Owner should be Home Loan Applications Queue'
    );
  }

  /**
   * @description
   * Scenarios:
   * 1. insert status = sunset: set timestamp
   * 2. insert status = non sunset: do not set timestamp
   */
  @IsTest
  static void testSetSunsetTimestampForInsert() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToInsert = createResidentialLoanApplications(
      2
    );
    // Set new apps attributes
    testLoanAppsToInsert[0].Status = SUNSET_STATUS;
    testLoanAppsToInsert[1].Status = NON_SUNSET_STATUS;

    // Test insert scenarios
    Test.startTest();
    AnzxLoanApplicationActions.setSunsetTimestamp(testLoanAppsToInsert);
    Test.stopTest();

    // Assert
    Assert.isTrue(
      testLoanAppsToInsert[0].SunsetTimestamp__c.isSameDay(Date.today()),
      'Application Sunset Timestamp should be set as current date time'
    );
    Assert.isNull(
      testLoanAppsToInsert[1].SunsetTimestamp__c,
      'Application Sunset Timestamp should not be set'
    );
  }

  /**
   * @description
   * Scenarios:
   * 1. update from non sunset to non sunset: do not set timestamp
   * 2. update from sunset to sunset: keep the timestamp no change
   * 3. update from non sunset to sunset: set timestamp
   * 4. update from sunset to non sunset: clear timestamp
   */
  @IsTest
  static void testSetSunsetTimestampForUpdate() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToUpdate = createResidentialLoanApplications(
      4
    );
    List<ResidentialLoanApplication> oldLoanApps = testLoanAppsToUpdate.deepClone(
      true
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>(
      oldLoanApps
    );

    Datetime now = System.now();
    // Set new apps attributes
    testLoanAppsToUpdate[0].Status = NON_SUNSET_STATUS;
    testLoanAppsToUpdate[1].Status = SUNSET_STATUS;
    testLoanAppsToUpdate[2].Status = SUNSET_STATUS;
    testLoanAppsToUpdate[3].Status = NON_SUNSET_STATUS;
    testLoanAppsToUpdate[3].SunsetTimestamp__c = now;

    // Set old apps attributes
    oldLoanApps[0].Status = NON_SUNSET_STATUS;
    oldLoanApps[1].Status = SUNSET_STATUS;
    oldLoanApps[2].Status = NON_SUNSET_STATUS;
    oldLoanApps[3].Status = SUNSET_STATUS;
    oldLoanApps[3].SunsetTimestamp__c = now;

    Test.startTest();
    // Test update scenarios
    AnzxLoanApplicationActions.setSunsetTimestamp(
      testLoanAppsToUpdate,
      oldLoanAppMap
    );
    Test.stopTest();

    // Assert
    Assert.isNull(
      testLoanAppsToUpdate[0].SunsetTimestamp__c,
      'Application Sunset Timestamp should not be set'
    );
    Assert.areEqual(
      oldLoanApps[1].SunsetTimestamp__c,
      testLoanAppsToUpdate[1].SunsetTimestamp__c,
      'Application Sunset Timestamp should remain the same'
    );
    Assert.isTrue(
      testLoanAppsToUpdate[2].SunsetTimestamp__c.isSameDay(now),
      'Application Sunset Timestamp should be set as current date time'
    );
    Assert.isNull(
      testLoanAppsToUpdate[3].SunsetTimestamp__c,
      'Application Sunset Timestamp should be cleared'
    );
  }

  static List<ResidentialLoanApplication> createResidentialLoanApplications(
    Integer count
  ) {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < count; i++) {
      ResidentialLoanApplication loanApp = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i + 1)
      );
      loanApp.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      loanApp.Assisted_Broker_TPMI_SAO__c = BROKER_CODE;
      loanApps.add(loanApp);
    }
    return loanApps;
  }
}
