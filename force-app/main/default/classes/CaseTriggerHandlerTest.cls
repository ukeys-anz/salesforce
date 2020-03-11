@isTest
private class CaseTriggerHandlerTest {
  @isTest
  static void testCaseNumberCopy() {
    // GIVEN cases are created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(new Case());
    }
    // WHEN they are inserted
    insert newCases;
    // THEN CaseNumber is copied into CaseNumber__c
    Case c = [
      SELECT CaseNumber, CaseNumber__c
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(
      c.CaseNumber,
      c.CaseNumber__c,
      'CaseNumber__c should be equal to CaseNumber.'
    );
    newCases.get(0).CaseNumber__c = null;
    update newCases.get(0);
    System.assertEquals(
      c.CaseNumber,
      c.CaseNumber__c,
      'CaseNumber__c should be equal to CaseNumber.'
    );
  }
  @isTest
  static void testCaseNumberNoCopy() {
    // GIVEN cases which already have their case number copied
    Case[] casesWithCopiedCaseNumber = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesWithCopiedCaseNumber.add(new Case(CaseNumber__c = '123'));
    }
    // WHEN they are inserted
    insert casesWithCopiedCaseNumber;
    // THEN CaseNumber is not copied into CaseNumber__c
    Case c = [
      SELECT CaseNumber, CaseNumber__c
      FROM Case
      WHERE id = :casesWithCopiedCaseNumber[0].id
    ];
    System.assertNotEquals(
      c.CaseNumber,
      c.CaseNumber__c,
      'CaseNumber should not have been copied.'
    );
    System.assertEquals(
      '123',
      c.CaseNumber__c,
      'CaseNumber__c should not have changed.'
    );
  }
  @isTest
  static void testComplaintCardNumberMasking() {
    // GIVEN cases relate to a account/card/policy
    Case[] casesWithACPNumber = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesWithACPNumber.add(
        new Case(
          IDR_Account_Card_Policy_Number__c = '000001234',
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID
        )
      );
    }
    // WHEN they are inserted
    insert casesWithACPNumber;
    // THEN IDR_Account_Card_Policy_Number__c is masked, showing only the last four digits
    Case c = [
      SELECT IDR_Account_Card_Policy_Number__c
      FROM Case
      WHERE id = :casesWithACPNumber[0].id
    ];
    System.assertEquals(
      '*****1234',
      c.IDR_Account_Card_Policy_Number__c,
      'IDR_Account_Card_Policy_Number__c should be masked.'
    );
  }

  @isTest
  static void testIsComplaintEscalated() {
    // GIVEN cases are created as escalated
    Case[] newCasesWithStatus = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCasesWithStatus.add(
        new Case(
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1',
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID
        )
      );
    }
    // WHEN they are inserted
    insert newCasesWithStatus;
    // THEN check if IsEscalated is true
    Case c = [
      SELECT CaseNumber, IsEscalated
      FROM Case
      WHERE id = :newCasesWithStatus[0].id
    ];
    System.assert(c.IsEscalated, 'IsEscalated is true');

    // GIVEN cases are created as not escalated
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN check if IsEscalated is false
    c = [SELECT CaseNumber, IsEscalated FROM Case WHERE id = :newCases[0].id];
    System.assert(!c.IsEscalated, 'IsEscalated is false');

    // GIVEN cases siwtch to escalated
    for (Integer i = 0; i < newCases.size(); i++) {
      newCases[i].Status = 'Escalated';
      newCases[i].IDR_Escalated_to__c = '1';
      newCases[i].IDR_Escalation_Reason__c = '1';
    }
    // WHEN they are updated
    update newCases;
    // THEN check if IsEscalated is true
    c = [SELECT CaseNumber, IsEscalated FROM Case WHERE id = :newCases[0].id];
    System.assert(c.IsEscalated, 'IsEscalated is true');
  }

  @isTest
  static void testComplaintEscalationStatus() {
    // GIVEN cases are created as not escalated
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
          IsEscalated = true,
          IDR_Escalated_to__c = '2',
          IDR_Escalation_Reason__c = '1',
          OwnerId = IDRCaseActions.queue.Id
        )
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN check if IsEscalated is false
    Case c = [
      SELECT CaseNumber, IDR_Escalated_to__c, Status, IsEscalated
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assert(c.Status == 'Escalated', 'Status is Escalated ');
    System.assert(c.IDR_Escalated_to__c == '1', 'Escalated is changed to CRC');
  }

  @isTest
  static void testDateWhenComplaintIsReopened() {
    // GIVEN cases are created as not re-openened
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Closed',
          IDR_Complaint_Outcome__c = '1',
          IDR_Description_of_Outcome__c = 'test'
        )
      );
    }
    // WHEN they are insterted
    insert newCases;
    // THEN check if re-openened date is null
    Case c = [
      SELECT CaseNumber, IDR_Date_Re_Opened__c
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(null, c.IDR_Date_Re_Opened__c, 'Date is null');

    // GIVEN cases are updated as re-openened
    for (Integer i = 0; i < newCases.size(); i++) {
      newCases[i].Status = 'Re-opened';
      newCases[i].IDR_Reason_for_re_opening__c = '1';
    }
    // WHEN they are updated
    update newCases;
    // THEN check if date is todays date
    c = [
      SELECT CaseNumber, IDR_Date_Re_Opened__c, IsEscalated
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(
      System.today(),
      c.IDR_Date_Re_Opened__c,
      'Date is current date'
    );
    System.assert(!c.IsEscalated, 'IsEscalated is false');
  }

  @istest
  static void testAnonymousComplaint() {
    // GIVEN cases are created and consent not obtained
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          IDR_NC_Is_Consent_Obtained__c = false,
          RecordTypeId = IDRCaseActions.NON_CUSTOMER_COMPLAINT_RT_ID
        )
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN check if names have been anonymised
    Case c = [
      SELECT
        CaseNumber,
        IDR_NC_First_Name__c,
        IDR_NC_Middle_Names__c,
        IDR_NC_Last_Name__c
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(
      Label.Anonymous_Complainant,
      c.IDR_NC_First_Name__c,
      'Name is anonymised'
    );
    System.assertEquals(
      Label.Anonymous_Complainant,
      c.IDR_NC_Middle_Names__c,
      'Name is anonymised'
    );
    System.assertEquals(
      Label.Anonymous_Complainant,
      c.IDR_NC_Last_Name__c,
      'Name is anonymised'
    );
  }

  @istest
  static void testComplaintAssignment() {
    // GIVEN complaints are created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN office field matches the case owner's
    User currentUser = [
      SELECT Id, Division
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    Case c = [SELECT IDR_Office__c FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(
      currentUser.Division,
      c.IDR_Office__c,
      'Office is current owner\'s division'
    );

    // GIVEN complaint is reassigned to another User
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard USer'];
    User idrUser = new User(
      Alias = 'idruse',
      Email = 'idruser@anztest.com',
      LastName = 'Testing',
      ProfileId = p.Id,
      UserName = 'idruser@anztest.com',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      Division = 'IDR Test Office'
    );
    insert idrUser;
    c.OwnerId = idrUser.Id;
    // WHEN complaint is updated
    update c;
    // THEN Office has changed to new user's
    idrUser = [
      SELECT Division
      FROM User
      WHERE UserName = 'idruser@anztest.com'
    ];
    c = [SELECT IDR_Office__c FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(
      idrUser.Division,
      c.IDR_Office__c,
      'Office is new owner\'s division'
    );
  }

  @istest
  static void testNotifications() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1'
        )
      );
    }
    insert newCases;
    System.assert(
      IDRCaseActions.idrNotifications.size() ==
      Integer.valueOf(Label.Test_Bulk_Size),
      'Matching no of events'
    );
  }

  @istest
  static void testCFMSEscalation() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1'
        )
      );
    }
    insert newCases;
    System.assert(
      IDRCaseActions.idrCaseEscalations.size() ==
      Integer.valueOf(Label.Test_Bulk_Size),
      'Matching no of events'
    );
  }
  @istest
  static void testIDRCaseDelete() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRCaseActions.CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    insert newCases;

    try {
      delete newCases;
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('You cannot delete cases'),
        'Cases Cannot be deleted'
      );
    }
  }
}
