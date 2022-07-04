/**
 *
 * @author Lance Shi
 * @since 06/2020
 * @description KnowledgeTrigggerHandlerTest is the test class to cover tests for {@link KnowledgeTrigggerHandler}
 */
@isTest
public class KnowledgeTrigggerHandlerTest {
  /**
   * @description testNullReasonForChange is to test the reason for change field has been successfully nulled during creation
   */
  @isTest
  public static void testNullReasonForChange() {
    Knowledge__kav article = new Knowledge__kav();
    article.title = 'TestNullReasonUnit';
    article.urlName = 'TestNullReasonUnit';
    article.Reason_for_Change__c = 'Test Reason';

    insert article;

    article = [
      SELECT Id, Reason_for_Change__c, urlName
      FROM Knowledge__kav
      WHERE Id = :article.Id
    ];
    System.assert(
      (article.Reason_for_Change__c == null) ||
      (article.Reason_for_Change__c == ''),
      'Reason for change of the article should be null/empty.'
    );
    System.assertEquals(
      'testnullreasonunit',
      article.urlName,
      'The article urlName should be as expected.'
    );

    article.urlName = 'UpdatedUrlName';
    update article;

    article = [
      SELECT Id, Reason_for_Change__c, urlName
      FROM Knowledge__kav
      WHERE Id = :article.Id
    ];
    System.assertEquals(
      'updatedurlname',
      article.urlName,
      'The article urlName should be as expected.'
    );
  }
}
