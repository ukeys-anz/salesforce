@IsTest
public class ContactToContactTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    Profile integrationUserProfile = CommonUtil.getProfileByName(
      'Integration User'
    );
    UserRole bdmRole = CommonUtil.getUserRoleByDevName(
      'Residential_Broker_Manager'
    );
    List<User> users = new List<User>();
    User user = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'StaffBDM',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => bdmRole.Id,
        'Lan_Id__c' => 'LANID12345678900'
      }
    );
    users.add(user);
    user = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'Staff01',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => bdmRole.Id,
        'Lan_Id__c' => 'LANID12345678901'
      }
    );
    users.add(user);
    user = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'Staff02',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => bdmRole.Id,
        'Lan_Id__c' => 'LANID12345678902'
      }
    );
    users.add(user);
    insert users;
    PermissionSet ps = CommonUtil.getPermissionSetByName(
      'Manage_Staff_Relationships'
    );
    List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = users[0].Id,
      PermissionSetId = ps.Id
    );
    psas.add(psa);
    psa = new PermissionSetAssignment(
      AssigneeId = users[1].Id,
      PermissionSetId = ps.Id
    );
    psas.add(psa);
    psa = new PermissionSetAssignment(
      AssigneeId = users[2].Id,
      PermissionSetId = ps.Id
    );
    psas.add(psa);
    insert psas;
  }

  @IsTest
  private static void testOwnershipChange() {
    List<Contact> contacts = createContacts();
    String ownerNameForStaffBDMCR = System.Label.Broker_Staff_User_as_Owner_of_Staff_BDM_records;
    Id ownerIdForStaffBDMCR;
    List<String> usersFirstName = new List<String>{
      'Staff01',
      'Staff02',
      'StaffBDM',
      'OCV Integration'
    };
    List<User> users = [
      SELECT Id, Name, FirstName, Lan_Id__c
      FROM User
      WHERE FirstName IN :usersFirstName AND IsActive = TRUE
    ];
    Map<String, Id> lanIdVsUserIds = new Map<String, Id>();
    User bdmUser;
    for (User user : users) {
      if (user.FirstName == 'StaffBDM') {
        bdmUser = user;
      }
      if (user.Name == ownerNameForStaffBDMCR) {
        ownerIdForStaffBDMCR = user.Id;
      }
      lanIdVsUserIds.put(user.Lan_Id__c, user.Id);
    }
    String rrRecordId = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByDeveloperName()
      .get('ContactRole')
      .getRecordTypeId();
    FinServ__ReciprocalRole__c reciprocalRole = new FinServ__ReciprocalRole__c(
      RecordTypeId = rrRecordId,
      Name = 'Broker',
      FinServ__InverseRole__c = 'Staff - BDM',
      FinServ__CreateInverseRole__c = true
    );
    insert reciprocalRole;
    System.runAs(bdmUser) {
      FinServ__ContactContactRelation__c contactRelation = new FinServ__ContactContactRelation__c(
        Broker__c = contacts[0].Id,
        Staff__c = contacts[1].Id,
        OCV_Role__c = 'OCV Role',
        FinServ__Role__c = reciprocalRole.Id,
        FinServ__Active__c = true,
        RecordTypeId = GetHelpConstants.BROKER_STAFF_RT_ID
      );
      insert contactRelation;
      List<FinServ__ContactContactRelation__c> contactRelations = [
        SELECT Id, Broker__c, OwnerId, Staff__c, FinServ__Role__r.Name
        FROM FinServ__ContactContactRelation__c
      ];

      Assert.isTrue(
        contactRelations.size() == 2,
        'Two Contact-Contact Relationship records should have been created!'
      );

      for (FinServ__ContactContactRelation__c cr : contactRelations) {
        if (cr.FinServ__Role__r.Name == 'Broker') {
          contactRelation = cr;
          Assert.areEqual(
            cr.OwnerId,
            lanIdVsUserIds.get('LANID12345678901'),
            'Contact Relation owner should change.'
          );
        }
        if (cr.FinServ__Role__r.Name == 'Staff - BDM') {
          Assert.areEqual(cr.OwnerId, ownerIdForStaffBDMCR);
        }
      }

      contactRelation.Staff__c = contacts[2].Id;
      update contactRelation;
      contactRelation = [
        SELECT Id, OwnerId, Staff__c
        FROM FinServ__ContactContactRelation__c
        WHERE Id = :contactRelation.Id
      ];
      Assert.areEqual(
        contactRelation.OwnerId,
        lanIdVsUserIds.get('LANID12345678902'),
        'Contact Relation owner should change.'
      );
      String errorMessage;
      contactRelation = [
        SELECT Id, Broker__c, OwnerId, Staff__c
        FROM FinServ__ContactContactRelation__c
        WHERE Id = :contactRelation.Id
      ];
      contactRelation.Staff__c = contacts[3].Id;
      errorMessage = System.Label.Broker_Staff_No_Lan_Id_for_Staff;
      checkForErrorMessages(contactRelation, errorMessage);

      contactRelation.Staff__c = contacts[4].Id;
      errorMessage = System.Label.Broker_Staff_No_User_for_Staff_s_Lan_Id;
      checkForErrorMessages(contactRelation, errorMessage);
    }

  }

  private static void checkForErrorMessages(
    FinServ__ContactContactRelation__c contactRelation,
    String errorMessage
  ) {
    try {
      update contactRelation;
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(errorMessage),
        'Error should be thrown with the message as: ' + errorMessage
      );
    }
  }

  private static List<Contact> createContacts() {
    String personAccountRecordtTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account personAccount = new Account(
      FirstName = 'Broker01',
      LastName = 'ANZX-6197',
      OCV_Id__c = 'OCV123456789',
      RecordTypeId = personAccountRecordtTypeId
    );
    insert personAccount;
    String brokerContactRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Broker')
      .getRecordTypeId();
    String staffContactRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Staff')
      .getRecordTypeId();

    List<Contact> contacts = new List<Contact>();
    Contact contact = new Contact(
      FirstName = 'Broker01',
      LastName = 'ANZX-6197',
      Email = 'contactbroker@anzx.abc',
      MobilePhone = '123456789',
      RetailTPMISAO__c = 'TPMI123456789',
      OCV_ID__c = 'OCV123456789',
      Broker_Customer_Profile__c = personAccount.Id,
      RecordTypeId = brokerContactRecordId
    );
    contacts.add(contact);
    contact = new Contact(
      FirstName = 'Staff01',
      LastName = 'ANZX-6197',
      Email = 'contactbroker01@anzx.abc',
      MobilePhone = '12345678901',
      RecordTypeId = staffContactRecordId,
      Lan_Id__c = 'LANID12345678901'
    );
    contacts.add(contact);
    contact = new Contact(
      FirstName = 'Staff02',
      LastName = 'ANZX-6197',
      Email = 'contactbroker02@anzx.abc',
      MobilePhone = '12345678902',
      RecordTypeId = staffContactRecordId,
      Lan_Id__c = 'LANID12345678902'
    );
    contacts.add(contact);
    contact = new Contact(
      FirstName = 'Staff02',
      LastName = 'ANZX-6197',
      Email = 'contactbroker02@anzx.abc',
      MobilePhone = '12345678902',
      RecordTypeId = staffContactRecordId
    );
    contacts.add(contact);
    contact = new Contact(
      FirstName = 'Staff02',
      LastName = 'ANZX-6197',
      Email = 'contactbroker02@anzx.abc',
      MobilePhone = '12345678902',
      RecordTypeId = staffContactRecordId,
      Lan_Id__c = 'LANID12345678903'
    );
    contacts.add(contact);
    insert contacts;
    return contacts;
  }
}
