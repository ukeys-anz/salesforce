/**
 * @author       : Naman Garg
 * @since        : Feb 2025
 * @description  : CommercialCOIActions is the actions class for CommercialCOIActions.
 **/
@isTest
public class CommercialCOIActionsTest {
  static Circle_Of_Influence__c getCOIRecord(Id coiId, String lastName) {
    Circle_Of_Influence__c coiRecord = (Circle_Of_Influence__c) TestUtil.setFields(
      new Circle_Of_Influence__c(Id = coiId, Last_Name__c = lastName),
      new Map<String, Object>{ 'Name__c' => lastName }
    );
    return coiRecord;
  }

  @isTest
  static void populateCOINameOnInsertTest() {
    //GIVEN List of COI records
    List<Circle_Of_Influence__c> records = new List<Circle_Of_Influence__c>{
      new Circle_Of_Influence__c(
        Id = Lib_FakeIdGenerator.getMockId(Circle_Of_Influence__c.SObjectType),
        First_Name__c = 'Ricky',
        Last_Name__c = 'Pointing'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialCOIActions.populateCOINameOnInsert(records);
    Test.stopTest();

    //THEN It should populate the Name
    Assert.areEqual(
      'Ricky Pointing',
      records[0].Name,
      'Name should get populated on COI records during insertion.'
    );
  }

  @isTest
  static void populateCOINameOnUpdateTest() {
    //GIVEN List of COI records and old map
    Id coiId = Lib_FakeIdGenerator.getMockId(
      Circle_Of_Influence__c.SObjectType
    );
    List<Circle_Of_Influence__c> records = new List<Circle_Of_Influence__c>{
      getCOIRecord(coiId, 'Ricky')
    };

    Map<Id, Circle_Of_Influence__c> oldMap = new Map<Id, Circle_Of_Influence__c>{
      coiId => getCOIRecord(coiId, 'James')
    };

    //WHEN calling a method
    Test.startTest();
    CommercialCOIActions.populateCOINameOnUpdate(records, oldMap);
    Test.stopTest();

    //THEN It should populate the Name
    Assert.areEqual(
      'Ricky',
      records[0].Name,
      'Name should get populated on COI records during updation.'
    );
  }

  @isTest
  static void integrationTest() {
    //GIVEN List of COI records
    List<Circle_Of_Influence__c> records = new List<Circle_Of_Influence__c>{
      new Circle_Of_Influence__c(
        First_Name__c = 'Thomas',
        Last_Name__c = 'Edward',
        RecordTypeId = RTCOI.companyMember
      )
    };

    //WHEN inserting records
    Test.startTest();
    insert records;
    Test.stopTest();

    Circle_Of_Influence__c getCOIRecord = [
      SELECT Id, Name
      FROM Circle_Of_Influence__c
      WHERE Id = :records[0].Id
      LIMIT 1
    ];

    //THEN it should populate the Name
    Assert.areEqual(
      'Thomas Edward',
      getCOIRecord.Name,
      'Name should get populated on COI records on insertion'
    );
  }
}
