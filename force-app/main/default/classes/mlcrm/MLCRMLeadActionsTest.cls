/**
 * @author Ashish Kumar
 * @since 05/2023
 * @description MLCRM Lead Action is the test class for MLCRM Lead Actions Class functionality.
 */
@isTest
public class MLCRMLeadActionsTest {
  @testSetup
  static void setup() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    User mlUser1 = MLCRMTestDataFactory.createMLCRMBaseUser();
    mlUser1.lastName = 'MLCRM1';
    update mlUser1;
    User adminUser = MLCRMTestDataFactory.createAdminUser();
    //Create Test Lead Records
    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlUser,
        true
      );
      Territory__Share objShare = new Territory__Share();
      objShare.parentId = lstOfTerritory[0].Id;
      objShare.accesslevel = 'Edit';
      objShare.userOrgroupid = mlUser1.Id;
      insert objShare;
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser1.Id,
        lstOfTerritory[0].Id
      );
      Test.startTest();
      MLCRMTestDataFactory.createManualLeadRecords(10, mlUser);
      Test.stopTest();
    }
  }
  @isTest
  static void validateDefualtExpityDate() {
    User objUser = [SELECT Id FROM User WHERE LastName = :'MLCRM'];
    System.runAs(objUser) {
      Test.startTest();
      List<Lead> lstOfLead = [
        SELECT Id, Expiry_Date__c
        FROM Lead
        WHERE RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];
      for (Lead objLead : lstOfLead) {
        String dayName = DateTimeUtils.getDay(
          System.today()
            .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate))
        );
        switch on dayName {
          when 'Sat' {
            System.assertEquals(
              objLead.Expiry_Date__c,
              System.today()
                .addDays(
                  Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 2
                )
            );
          }
          when 'Sun' {
            System.assertEquals(
              objLead.Expiry_Date__c,
              System.today()
                .addDays(
                  Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 1
                )
            );
          }
          when else {
            System.assertEquals(
              objLead.Expiry_Date__c,
              System.today()
                .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate))
            );
          }
        }
      }
      Test.stopTest();
    }
  }

  // Test Method to validate if lead has territory field populated during creation.
  @isTest
  static void validateLeadTerritory() {
    User objUser = [SELECT Id FROM User WHERE LastName = :'MLCRM'];
    User objUser2 = [SELECT Id FROM User WHERE LastName = 'MLCRM1'];
    System.runAs(objUser) {
      Test.startTest();
      List<Lead> lstOfLead = [
        SELECT Id, Territory__c
        FROM Lead
        WHERE RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];
      List<User_Territory__c> lstOfUserTerritory = [
        SELECT Id, Territory__c
        FROM User_Territory__c
        WHERE ML_Role__c = 'Franchise Owner'
      ];
      for (Lead objLead : lstOfLead) {
        System.Assert(objLead.Territory__c != null);
        System.assertEquals(
          lstOfUserTerritory[0].Territory__c,
          objLead.Territory__c
        );
      }
    }

    System.runAs(objUser2) {
      List<Lead> lstOfLead = [
        SELECT Id, Territory__c
        FROM Lead
        WHERE RecordTypeId = :MLCRMConstants.MLCRM_LEAD_RT_ID
      ];
      System.assertEquals(10, lstOfLead.size());
    }
    Test.stopTest();
  }
}
