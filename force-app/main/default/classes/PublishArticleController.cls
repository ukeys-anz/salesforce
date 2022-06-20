/**
 * @author Lance
 * @since Jan 2022
 * @description  Publish Knowledge Article with validation
 */

public with sharing class PublishArticleController {
  /**
   * @description Publish Knowledge Article with validation
   * @param recordId The knowledge version ID
   */
  @AuraEnabled
  public static void publishWithValidation(Id recordId) {
    Knowledge__kav knowledgeVersion;
    if (Schema.sObjectType.Knowledge__kav.isQueryable()) {
      knowledgeVersion = [
        SELECT Id, KnowledgeArticleId, PublishStatus
        FROM Knowledge__kav
        WHERE Id = :recordId
      ];
    }

    List<knowledge__DataCategorySelection> dcList;
    if (Schema.sObjectType.knowledge__DataCategorySelection.isQueryable()) {
      dcList = [
        SELECT Id, DataCategoryName, parentId
        FROM knowledge__DataCategorySelection
        WHERE parentId = :knowledgeVersion.Id
      ];
    }

    if (dcList.isEmpty()) {
      throw new AuraHandledException(
        'You n​​​​eed to add one or more category tags to publish this article.'
      );
    }

    if (knowledgeVersion.PublishStatus != 'Draft') {
      throw new AuraHandledException(
        'This article is already published. To update, you need to create a draft version of this article to edit and then publish.'
      );
    }
    KbManagement.PublishingService.publishArticle(
      knowledgeVersion.KnowledgeArticleId,
      true
    );
  }
}
