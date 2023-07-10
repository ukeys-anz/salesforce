/**
 * @author Nilesh Kalal
 * @since July 2023
 * @description InteractionContextTagActionTest is the test class for InteractionContextTagAction Class.
 */
@isTest
public with sharing class InteractionContextTagActionTest {
  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZ Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    // Create coach user
    User coachUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'Coach Test ICT',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coachUser;
    //Assign Permission set group as coach
    PermissionSetGroup psgCoach = [
      SELECT Id
      FROM PermissionSetGroup
      WHERE DeveloperName = 'Coach'
      LIMIT 1
    ];
    Test.calculatePermissionSetGroup(new List<String>{ psgCoach.Id });
    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = coachUser.Id,
      PermissionSetGroupId = psgCoach.Id
    );
    insert psa;

    System.runAs(coachUser) {
      // Create common test accounts
      List<Interaction> listOfInteractions = new List<Interaction>();
      Faker faker = new Faker('AU');
      for (Integer i = 0; i < 5; i++) {
        Interaction interactNew = new Interaction();
        interactNew.RecordTypeId = GetHelpConstants.INTERACTION_STORE_RT_ID;
        String randInteractName = faker.randomString(10);
        interactNew.Name = randInteractName;
        interactNew.StartTime = System.now().addDays(30);
        interactNew.EndTime = interactNew.StartTime.addMinutes(30);
        listOfInteractions.add(interactNew);
      }
      insert listOfInteractions;

      List<Interaction_Tag__c> listOfInteractionTags = new List<Interaction_Tag__c>();
      Interaction_Tag__c interactionTagToInsert = new Interaction_Tag__c();
      interactionTagToInsert.Sub_Type__c = 'Store';
      interactionTagToInsert.Tag__c = 'ANZ Query';
      interactionTagToInsert.Type__c = 'Reason';
      listOfInteractionTags.add(interactionTagToInsert);
      Interaction_Tag__c interactionTagToInsert2 = new Interaction_Tag__c();
      interactionTagToInsert2.Sub_Type__c = 'Store';
      interactionTagToInsert2.Tag__c = 'About ANZ Plus';
      interactionTagToInsert2.Type__c = 'Topic';
      listOfInteractionTags.add(interactionTagToInsert2);
      Interaction_Tag__c interactionTagToInsert3 = new Interaction_Tag__c();
      interactionTagToInsert3.Sub_Type__c = 'Store';
      interactionTagToInsert3.Tag__c = 'ANZ Plus Home Loan - Fixed';
      interactionTagToInsert3.Type__c = 'Product';
      listOfInteractionTags.add(interactionTagToInsert3);
      Interaction_Tag__c interactionTagToInsert4 = new Interaction_Tag__c();
      interactionTagToInsert4.Sub_Type__c = 'Store';
      interactionTagToInsert4.Tag__c = 'Join ANZ Plus';
      interactionTagToInsert4.Type__c = 'Reason';
      listOfInteractionTags.add(interactionTagToInsert4);
      insert listOfInteractionTags;

      Integer i = 0;
      List<Interaction_Context_Tag__c> listOfIctToInsert = new List<Interaction_Context_Tag__c>();
      for (Interaction_Tag__c eachInteractionTag : listOfInteractionTags) {
        Interaction_Context_Tag__c interactionContextTagToInsert = new Interaction_Context_Tag__c();
        interactionContextTagToInsert.Interaction__c = listOfInteractions.get(i)
          .Id;
        interactionContextTagToInsert.Interaction_Tag__c = eachInteractionTag.id;
        listOfIctToInsert.add(interactionContextTagToInsert);
        i++;
      }
      // insertion of tags on same interaction for letting mastermap to cover else part (getMapOfInteractionIdWithTopicDetails())
      Interaction_Context_Tag__c interactionContextTagToInsert = new Interaction_Context_Tag__c();
      interactionContextTagToInsert.Interaction__c = listOfInteractions.get(0)
        .Id;
      interactionContextTagToInsert.Interaction_Tag__c = listOfInteractionTags.get(
          1
        )
        .id;
      listOfIctToInsert.add(interactionContextTagToInsert);
      Interaction_Context_Tag__c interactionContextTagToInsert2 = new Interaction_Context_Tag__c();
      interactionContextTagToInsert2.Interaction__c = listOfInteractions.get(0)
        .Id;
      interactionContextTagToInsert2.Interaction_Tag__c = listOfInteractionTags.get(
          2
        )
        .id;
      listOfIctToInsert.add(interactionContextTagToInsert2);
      Interaction_Context_Tag__c interactionContextTagToInsert3 = new Interaction_Context_Tag__c();
      interactionContextTagToInsert3.Interaction__c = listOfInteractions.get(0)
        .Id;
      interactionContextTagToInsert3.Interaction_Tag__c = listOfInteractionTags.get(
          1
        )
        .id;
      listOfIctToInsert.add(interactionContextTagToInsert3);
      insert listOfIctToInsert;
    }
  }

  @isTest
  static void testUpdateTopicFieldsOnCreate() {
    Test.startTest();
    User coachUser = [
      SELECT Id, Name, FirstName
      FROM User
      WHERE FirstName = 'Coach Test ICT'
    ];
    System.runAs(coachUser) {
      List<Interaction_Context_Tag__c> listOfInsertedIct = [
        SELECT Id, Interaction__c, Interaction_Tag__c
        FROM Interaction_Context_Tag__c
      ];
      List<Interaction> listOfInterationRecord = [
        SELECT Id, Reason_for_Visit__c, Actual_Topics__c, Products__c
        FROM Interaction
        WHERE Id = :listOfInsertedIct[0].Interaction__c
      ];
      System.assertEquals(
        'ANZ Query',
        listOfInterationRecord[0].Reason_for_Visit__c,
        'Result not matched'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testUpdateTopicFieldsOnDelete() {
    Test.startTest();
    User coachUser = [
      SELECT Id, Name, FirstName
      FROM User
      WHERE FirstName = 'Coach Test ICT'
    ];
    System.runAs(coachUser) {
      List<Interaction> listOfInteraction = [
        SELECT Id, Reason_for_Visit__c, Actual_Topics__c, Products__c
        FROM Interaction
      ];
      Interaction_Context_Tag__c insertedIct = [
        SELECT Id, Interaction__c, IsDeleted
        FROM Interaction_Context_Tag__c
        WHERE Interaction__c = :listOfInteraction[0].Id
        LIMIT 1
      ];
      delete insertedIct;
      Interaction_Context_Tag__c deletedIct = [
        SELECT Id, IsDeleted
        FROM Interaction_Context_Tag__c
        WHERE Id = :insertedIct.Id
        ALL ROWS
      ];
      System.assertEquals(deletedIct.IsDeleted, true);
    }
    Test.stopTest();
  }
}
