/**
 * @author Laxmi Vuyyuru
 * @since 11-2023
 * @description Test class for IDRComplaintResolutionActions
 */
@IsTest
public class ComplaintResolutionTriggerHandlerTest {
  @testsetup
  static void setupData() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'ANZ Standard User'
      LIMIT 1
    ];
    User contextUser = (User) FakerFactory.make(new FakerUserFactory());
    contextUser.FirstName = 'IDRContextUser';
    contextUser.ProfileId = profile.Id;
    insert contextUser;

    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :new List<String>{ 'IDR_User' }
    ];
    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = contextUser.id,
        PermissionSetId = ps.Id
      );
      psaList.add(psa);
    }
    insert psaList;
  }

  /**
   * @description : This is to test when Payment amount provided field is populated, Duration of remedy to be null
   */
  @isTest
  static void testFinancialRemedy() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IDRContextUser'
      LIMIT 1
    ];
    System.runAs(contextUser) {
      test.startTest();
      testRemedy('1', '7', 123, 123, null);
      test.stopTest();
    }
  }

  /**
   * @description : This is to test when Duration of remedy field is populated, Payment amount provided to be null
   */
  @isTest
  static void testDurationOfRemedy() {
    User contextUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IDRContextUser'
      LIMIT 1
    ];

    System.runAs(contextUser) {
      test.startTest();
      testRemedy('4', '16', 123, 123, null);
      test.stopTest();
    }
  }

  /**
   * @description creation of Complaint Resolution record
   * @param remedy Complaint Remedy field
   * @param subRemedy Complaint Sub Remedy field
   * @param durationOfRemedy Duration Of Remedy field
   * @param financialRemedy Reward Points field
   * @param expectedValue field output value
   */
  public static void testRemedy(
    String remedy,
    String subRemedy,
    Decimal durationOfRemedy,
    Decimal financialRemedy,
    Object expectedValue
  ) {
    Case c = new Case(
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      Status = IDRConstants.OPEN_STATUS,
      Description = 'Test decription',
      IDR_Additional_Correspondence_reviewed__c = false,
      Origin = 'Phone'
    );
    insert c;
    Complaint_Resolution__c cr = new Complaint_Resolution__c(
      IDR_Complaint__c = c.Id,
      IDR_Complaint_Remedy__c = remedy,
      IDR_Complaint_Sub_Remedy__c = subRemedy,
      IDR_Duration_of_Remedy__c = durationOfRemedy,
      IDR_Financial_Remedy_Points__c = financialRemedy
    );
    insert cr;
    IDRComplaintResolutionActions.populateDependentFields(
      new List<Complaint_Resolution__c>{ cr }
    );
    cr = [
      SELECT Id, IDR_Other_Remedy_Provided__c
      FROM Complaint_Resolution__c
      WHERE Id = :cr.Id
    ];
    System.assertEquals(
      cr.IDR_Other_Remedy_Provided__c,
      expectedValue,
      'Field not updated to right value'
    );
  }
}
