public with sharing class IDRExpressComplaintControllerTest {
  @TestSetup
  static void makeData() {
    //Create Known Issue Records
    Known_Issues__c knownIssue = new Known_Issues__c(
      Name = 'Long Wait Times',
      IDR_Issue_Type__c = '13',
      IDR_Sub_Issue_Type__c = '9',
      IDR_Description_of_Issue__c = 'Customer is unable to access ANZ Internet Banking due to a system outage',
      IDR_Is_there_another_issue__c = false,
      IDR_Written_Response_Required__c = 'No',
      IDR_REAL_Form_Required__c = false,
      IDR_Possible_Systemic_Issue__c = 'No',
      IDR_Status__c = 'Closed',
      IDR_Description_of_Outcome__c = 'Apology provided to customer',
      IDR_Complaint_Remedy__c = '2',
      IDR_Non_Financial_Remedy__c = '1',
      Is_Active__c = true,
      IDR_Written_Response_Requested__c = 'No'
    );
    insert knownIssue;
  }

  public static User createCMOSUser() {
    //Create CMOS User
    Profile profile = CommonUtil.getProfileByName('ANZ Standard User');
    UserRole role = CommonUtil.getUserRoleByDevName('Customer_Resolution');
    User cmosUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'cmosUser',
        'ProfileId' => profile.Id,
        'UserRoleId' => role.Id
      }
    );
    insert cmosUser;

    //Query permission set group
    PermissionSetGroup psetGroup = [
      SELECT Id, DeveloperName
      FROM PermissionSetGroup
      WHERE DeveloperName = 'IDR_Level_1'
    ];
    //Assign permission set group to user
    PermissionSetAssignment psAssignment = TestUtil.createPSGroupAssignment(
      cmosUser.id,
      psetGroup.Id
    );
    insert psAssignment;

    return cmosUser;
  }

  public static User createCMOSUserWithoutPermission() {
    //Create CMOS User
    Profile profile = CommonUtil.getProfileByName('ANZ Standard User');
    UserRole role = CommonUtil.getUserRoleByDevName('Customer_Resolution');
    User cmosUserWithoutPermission = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'cmosUserWithoutPermission',
        'ProfileId' => profile.Id,
        'UserRoleId' => role.Id
      }
    );
    insert cmosUserWithoutPermission;

    return cmosUserWithoutPermission;
  }

  @isTest
  static void testGetAllKnownIssues() {
    User contextUser = createCMOSUser();
    List<Known_Issues__c> knownIssueList = new List<Known_Issues__c>();
    System.runAs(contextUser) {
      knownIssueList = IDRExpressComplaintController.getAllKnownIssues();
    }
    System.assertEquals(
      knownIssueList.size() > 0,
      true,
      'No known issue records are retrieved'
    );
    System.assertEquals(
      'Long Wait Times',
      knownIssueList[0].Name,
      'Incorrect known issue retrieved'
    );
  }

  @isTest
  static void testAccessCheckException() {
    User contextUser = createCMOSUserWithoutPermission();
    List<Known_Issues__c> knownIssueList = new List<Known_Issues__c>();
    Boolean exceptionOccured = false;
    System.runAs(contextUser) {
      try {
        knownIssueList = IDRExpressComplaintController.getAllKnownIssues();
      } catch (Exception e) {
        exceptionOccured = true;
      }
      System.assert(
        knownIssueList.size() == 0,
        'a user without the permission set cannot see any records'
      );
    }
  }
}
