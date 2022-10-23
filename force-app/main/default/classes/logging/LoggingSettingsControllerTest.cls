/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Test class for LoggingSettingsController (@link LoggingSettingsController)
 */
@isTest
public with sharing class LoggingSettingsControllerTest {
  @isTest
  static void testUserSetting() {
    Profile engineerProfile = CommonUtil.getProfileByName(
      'Minimum Access - Salesforce'
    );
    UserRole engineerRole = CommonUtil.getUserRoleByDevName('Engineer');
    User engineerUser = (User) FakerFactory.make(new FakerUserFactory());
    engineerUser.FirstName = 'Engineer';
    engineerUser.ProfileId = engineerProfile.Id;
    engineerUser.UserRoleId = engineerRole.Id;
    insert engineerUser;

    Boolean isSecureLogEnabled;
    String defaultLoggingLevel;
    String defaultSaveMethod;
    Test.startTest();
    System.runAs(engineerUser) {
      LoggingSettings__c userCustomSetting = new LoggingSettings__c(
        // DefaultSaveMethod__c = deliberately not set for testing purpose
        DefaultLoggingLevel__c = 'ERROR',
        // SecureLogEnabled__c = = deliberately not set for testing purpose
        SetupOwnerId = engineerUser.Id
      );
      insert userCustomSetting;

      isSecureLogEnabled = LoggingSettingsController.isSecureLogEnabled();
      defaultLoggingLevel = LoggingSettingsController.getDefaultLoggingLevel();
      defaultSaveMethod = LoggingSettingsController.getDefaultSaveMethod();
    }
    Test.stopTest();
    System.assertEquals(
      false,
      isSecureLogEnabled,
      'Secured Log setting should be false as this is the default value.'
    );
    System.assertEquals(
      'ERROR',
      defaultLoggingLevel,
      'Default logging level should be ERROR as this is the default value.'
    );
    System.assertEquals(
      'EVENT_BUS',
      defaultSaveMethod,
      'Default save method should be EVENT_BUS as this is the default value.'
    );
  }

  @isTest
  static void testProfileSetting() {
    Profile anzxStandardProfile = CommonUtil.getProfileByName(
      'ANZx Standard User'
    );
    User coachUser = (User) FakerFactory.make(new FakerUserFactory());
    coachUser.FirstName = 'Engineer';
    coachUser.ProfileId = anzxStandardProfile.Id;
    insert coachUser;
    // Create custom setting at profile level
    LoggingSettings__c profileCustomSetting = new LoggingSettings__c(
      DefaultSaveMethod__c = 'QUEUABLE',
      // DefaultLoggingLevel__c = deliberately not set for testing purpose
      // SecureLogEnabled__c = deliberately not set for testing purpose
      SetupOwnerId = anzxStandardProfile.Id
    );
    insert profileCustomSetting;

    Boolean isSecureLogEnabled;
    String defaultLoggingLevel;
    String defaultSaveMethod;
    Test.startTest();
    System.runAs(coachUser) {
      isSecureLogEnabled = LoggingSettingsController.isSecureLogEnabled();
      defaultLoggingLevel = LoggingSettingsController.getDefaultLoggingLevel();
      defaultSaveMethod = LoggingSettingsController.getDefaultSaveMethod();
    }
    Test.stopTest();
    System.assertEquals(
      false,
      isSecureLogEnabled,
      'Secured Log setting should be false as this is the default value.'
    );
    System.assertEquals(
      'ERROR',
      defaultLoggingLevel,
      'Default logging level should be ERROR as this is the default value.'
    );
    System.assertEquals(
      'QUEUABLE',
      defaultSaveMethod,
      'Default save method should match.'
    );
  }

  @isTest
  static void testOrgSetting() {
    // Create custom setting at org level
    Organization currentOrg = [SELECT Id FROM Organization LIMIT 1];
    LoggingSettings__c orgCustomSetting = new LoggingSettings__c(
      DefaultSaveMethod__c = 'QUEUEABLE',
      DefaultLoggingLevel__c = 'DEBUG',
      SecureLogEnabled__c = true,
      SetupOwnerId = currentOrg.Id
    );
    insert orgCustomSetting;

    Boolean isSecureLogEnabled;
    String defaultLoggingLevel;
    String defaultSaveMethod;
    Test.startTest();
    isSecureLogEnabled = LoggingSettingsController.isSecureLogEnabled();
    defaultLoggingLevel = LoggingSettingsController.getDefaultLoggingLevel();
    defaultSaveMethod = LoggingSettingsController.getDefaultSaveMethod();
    Test.stopTest();
    System.assertEquals(
      true,
      isSecureLogEnabled,
      'Secured Log setting should be true.'
    );
    System.assertEquals(
      'DEBUG',
      defaultLoggingLevel,
      'Default logging level should be DEBUG.'
    );
    System.assertEquals(
      'QUEUEABLE',
      defaultSaveMethod,
      'Default save method should match.'
    );
  }

  @isTest
  static void testSetUserSettings() {
    LoggingSettings__c setting = new LoggingSettings__c(
      DefaultSaveMethod__c = 'QUEUEABLE',
      DefaultLoggingLevel__c = 'INFO',
      SecureLogEnabled__c = true,
      SetupOwnerId = UserInfo.getUserId()
    );
    Test.startTest();
    LoggingSettingsController.setUserSettings(setting);
    Test.stopTest();
    System.assertEquals(
      true,
      LoggingSettingsController.isSecureLogEnabled(),
      'Secured Log setting should be true.'
    );
    System.assertEquals(
      'INFO',
      LoggingSettingsController.getDefaultLoggingLevel(),
      'Default logging level should match.'
    );
    System.assertEquals(
      'QUEUEABLE',
      LoggingSettingsController.getDefaultSaveMethod(),
      'Default save method should match.'
    );
  }

  /**
   * @description Returns the engineer user
   * @return The engineer user
   */
  private static User queryUser() {
    return [SELECT Id FROM User WHERE Firstname = 'Engineer_Test' LIMIT 1];
  }
}
