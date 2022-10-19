/**
 *
 * @author Adnan
 * @since Dec 2021
 * @description Test class for IDRExpressComplaintController (Express complaint functionality)
 */
@isTest
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
      IDR_Priority__c = 'Standard',
      IDR_Channel_Received__c = 'Phone',
      IDR_Written_Response_Requested__c = 'No'
    );
    insert knownIssue;
  }

  /**
   * @description creates cmos user, with level1 permission
   * @return User record
   */
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

    List<String> level1PSs = new List<String>{
      'IDR_User',
      'IDR_User_Level_1',
      'Product_Read_Only'
    };

    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :level1PSs
    ];

    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      psaList.add(TestUtil.createPSAssignment(cmosUser.id, ps.Id));
    }
    insert psaList;

    return cmosUser;
  }

  /**
   * @description creates cmos user, without any permission
   * @return User record
   */
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
    User contextUser = new User();
    User thisUser = [
      SELECT Id, Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    System.runAs(thisUser) {
      contextUser = createCMOSUser();
    }

    List<Known_Issues__c> knownIssueList = new List<Known_Issues__c>();
    Known_Issues__Share knownIssueShare = new Known_Issues__Share();
    knownIssueShare.ParentId = [
      SELECT Id
      FROM Known_Issues__c
      WHERE Name = 'Long Wait Times'
      LIMIT 1
    ]
    .Id;
    knownIssueShare.UserOrGroupId = contextUser.Id;
    knownIssueShare.AccessLevel = 'Read';
    knownIssueShare.RowCause = Schema.Known_Issues__Share.RowCause.Manual;
    insert knownIssueShare;
    System.runAs(contextUser) {
      // GIVEN known issue records present in system
      Test.startTest();
      // WHEN we try to access the known issues through CMOS complaint creation screen
      knownIssueList = IDRExpressComplaintController.getAllKnownIssues();
      Test.stopTest();
    }
    // THEN we should be able to access the known issue records
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
    // GIVEN known issue records present in system
    Boolean exceptionOccured = false;
    String errorMessage = '';
    System.runAs(contextUser) {
      // WHEN a user without IDR User permission is trying to access known issue records via CMOS complaint creation screen
      Test.startTest();
      try {
        knownIssueList = IDRExpressComplaintController.getAllKnownIssues();
      } catch (Exception e) {
        exceptionOccured = true;
        errorMessage = e.getMessage();
      }
      Test.stopTest();
      // THEN the user should not be able to access those records
      System.assert(
        knownIssueList.size() == 0,
        'a user without the permission set cannot see any records'
      );
      System.assertEquals(
        true,
        exceptionOccured,
        'Exception should have occured|\n' + errorMessage
      );
    }
  }
}
