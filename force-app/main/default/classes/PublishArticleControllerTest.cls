/**
 * @author Lance
 * @since Jan 2022
 * @description Tests for PublishArticleController
 */

@isTest
public with sharing class PublishArticleControllerTest {
  /**
   * @description testPublish tests the knowledge article is published successfully when data category is present.
   */
  @isTest
  public static void testPublish() {
    User contentUser = TestUtil.createTestUserWithProfile('ANZx Standard User');
    contentUser.UserPermissionsKnowledgeUser = true;
    List<String> contentPSs = new List<String>{
      'Knowledge_Base_Author',
      'SFDX_Deploy'
    };
    List<PermissionSet> contentPsList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :contentPSs
    ];

    insert contentUser;
    List<PermissionSetAssignment> contentPsaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : contentPsList) {
      contentPsaList.add(TestUtil.createPSAssignment(contentUser.id, ps.Id));
    }
    insert contentPsaList;
    System.runAs(contentUser) {
      Knowledge__kav article = new Knowledge__kav();
      article.title = 'TestNullReasonUnit';
      article.urlName = 'TestNullReasonUnit';
      article.Reason_for_Change__c = 'Test Reason';

      insert article;

      knowledge__DataCategorySelection kds = new knowledge__DataCategorySelection();
      kds.parentId = article.Id;
      kds.DataCategoryName = 'About_ANZ_Plus';
      kds.DataCategoryGroupName = 'Get_Help';
      insert kds;

      PublishArticleController.publishWithValidation(article.Id);
      article = [
        SELECT Id, PublishStatus, urlName
        FROM Knowledge__kav
        WHERE Id = :article.Id
      ];

      System.assertEquals(
        'Online',
        article.PublishStatus,
        'Article status should be as expected.'
      );
    }

  }

  /**
   * @description testPublishWithValidationError tests error is thrown when no data category is populated
   */
  @isTest
  public static void testPublishWithValidationError() {
    Knowledge__kav article = new Knowledge__kav();
    article.title = 'TestNullReasonUnit';
    article.urlName = 'TestNullReasonUnit';
    article.Reason_for_Change__c = 'Test Reason';

    insert article;

    Exception exp;

    try {
      PublishArticleController.publishWithValidation(article.Id);
      System.assert(false, 'Failed to prevent against user publishing article');
    } catch (Exception e) {
      exp = e;
    }

    System.assertEquals(
      'Script-thrown exception',
      exp.getMessage(),
      'Error message should be as expected.'
    );
  }
}
