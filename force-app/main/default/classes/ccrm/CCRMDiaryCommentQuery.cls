/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Diary Comment external query base class
 */
@SuppressWarnings(
  'PMD.AvoidDeeplyNestedIfStmts, PMD.CognitiveComplexity,PMD.StdCyclomaticComplexity'
)
public with sharing class CCRMDiaryCommentQuery extends CCRMExternalObjectQueryBase {
  /**
   * @description wrapper class for response
   */
  public class DiaryCommentCalloutResponse {
    public String conversationControl;
    public Integer totalComments;
    public Integer commentsCount;
    public String moreComments;
    public PermanentComment permanentComment;
    public List<CommentDetails> commentDetails;
  }
  /**
   * @description wrapper class for response
   */
  public class PermanentComment {
    public Integer branch;
    public DateTime datePlaced;
    public DateTime dateChanged;
    public String operatorId;
    public String comment;
  }
  /**
   * @description wrapper class for response
   */
  public class CommentDetails {
    public Integer branch;
    public DateTime datePlaced;
    public String timePlaced;
    public DateTime dateChanged;
    public String operatorId;
    public DateTime dateExpires;
    public String comment;
    public String workQueue;
    public String cycleCode;
    public DateTime datePrompt;
    public String customerReviewFlag;
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public override virtual CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    this.queryContext = queryContext;
    this.tableSelection = queryContext.TableSelection;
    getParent();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    prepareCallout();
    try {
      HttpCalloutResponse response = makeCallout();
      if (
        String.isBlank(this.parentId) && (String.isNotBlank(this.externalId))
      ) {
        Map<String, Object> row = new Map<String, Object>();
        row.put('ExternalId', this.externalId);
        row.put('AdditionalInformation', 'No further information available');
        result.queryResult.add(row);
        return result;
      }
      if (response.successful && response.body != null) {
        DiaryCommentCalloutResponse calloutResponse = (DiaryCommentCalloutResponse) System.JSON.deserialize(
          response.body,
          DiaryCommentCalloutResponse.class
        );
        result = createFinancialAccounts(calloutResponse);
        //Pass pagination token
        result.queryMoreToken = calloutResponse.conversationControl;
        setNextPageId(result.queryMoreToken);
      } else {
        Logger.error('Error : ' + response.error);
        Logger.saveLog();
      }
    } catch (Exception e) {
      Logger.error('Error : ' + e.getMessage());
      Logger.saveLog();
    }
    return result;
  }
  /**
   * @description Transform API response to diary comment records
   * @param calloutResponse response
   * @return List<Map<String, Object>>
   */
  public CCRMExternalObjectQueryBase.ExternalQueryResult createFinancialAccounts(
    DiaryCommentCalloutResponse calloutResponse
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row = new Map<String, Object>();
    Integer index = 0;
    if (calloutResponse != null) {
      if (
        calloutResponse?.permanentComment != null &&
        String.isNotEmpty(calloutResponse?.permanentComment?.comment)
      ) {
        CCRMDiaryCommentQuery.PermanentComment perComment = calloutResponse.permanentComment;
        row = new Map<String, Object>();
        index++;
        if (
          String.isNotBlank(this.parentId) ||
          (String.isNotBlank(this.externalId) &&
          this.externalId == 'DiaryComment-' + index)
        ) {
          if (
            String.isNotBlank(this.parent) && String.isNotBlank(this.parentId)
          ) {
            String externalId = 'DiaryComment-' + index;
            row.put('ExternalId', externalId);
            row.put(this.parent, this.parentId);
          } else {
            row.put('ExternalId', this.externalId);
          }
          row.put('Permanent', true);
          row.put('Branch', calloutResponse.permanentComment.branch);
          row.put(
            'DatePlaced',
            formatDate(calloutResponse.permanentComment.datePlaced)
          );
          row.put(
            'ModifiedDate',
            adjustUTCDateTime(calloutResponse.permanentComment.dateChanged)
          );
          row.put('Operator', calloutResponse.permanentComment.operatorId);
          row.put('Description', calloutResponse.permanentComment.comment);
          row.put(
            'DisplayUrl',
            URL.getOrgDomainUrl().toExternalForm() + '/DiaryComment-' + index
          );
          result.queryResult.add(row);
        }
      }
      for (CommentDetails cd : calloutResponse.commentDetails) {
        row = new Map<String, Object>();
        index++;

        if (
          String.isNotBlank(this.parent) && String.isNotBlank(this.parentId)
        ) {
          String externalId = 'DiaryComment-' + index;
          row.put('ExternalId', externalId);
          row.put(this.parent, this.parentId);
        } else {
          row.put('ExternalId', this.externalId);
        }
        if (
          String.isNotBlank(this.parentId) ||
          (String.isNotBlank(this.externalId) &&
          this.externalId == 'DiaryComment-' + index)
        ) {
          row.put(
            'DisplayUrl',
            URL.getOrgDomainUrl().toExternalForm() + '/DiaryComment-' + index
          );
          row.put('Description', cd.comment);
          row.put('ExpiryDate', formatDate(cd.dateExpires));
          row.put('Branch', cd.branch);
          row.put('Operator', cd.operatorId);
          row.put('DatePlaced', formatDateTime(cd.datePlaced));
          row.put('WorkQueue', cd.workQueue);
          row.put('CycleCode', cd.cycleCode);
          row.put('PromptDate', adjustUTCDateTime(cd.datePrompt));
          row.put(
            'CustomerReview',
            cd.customerReviewFlag == 'Y' ? true : false
          );
          row.put('ModifiedDate ', adjustUTCDateTime(cd.dateChanged));
          result.queryResult.add(row);
        }
      }
    }
    return result;
  }

  /**
   * @description Parse query filters and prepare for API calls
   * @param
   */
  protected override void prepareCallout() {
    parseFilters(this.parent);
  }

  /**
   * @description Rest API callout to get financial accounts by product codes and account numbers
   * @param
   * @return HttpCalloutResponse
   */
  protected override HttpCalloutResponse makeCallout() {
    CCRMARNCService service = new CCRMARNCService();
    Map<String, String> attributes = new Map<String, String>();
    if (String.isNotBlank(this.parent) && String.isNotBlank(this.parentId)) {
      attributes.put(this.parent, this.parentId);
    }
    String nextPageId = getNextPageId();
    HttpCalloutResponse response = service.queryDiaryComment(
      this.parent,
      attributes,
      nextPageId
    );
    return response;
  }
  /**
   * @description get next page Id for pagination
   * @return String next page Id
   */
  private String getNextPageId() {
    if (this.queryContext.offset == 0) {
      return null;
    }
    String cacheKey = getNextPageIdCacheKey();
    if (String.isNotBlank(cacheKey)) {
      Cache.SessionPartition sessionPart = Cache.Session.getPartition(
        'local.DataPartition'
      );
      return String.valueOf(sessionPart.get(cacheKey));
    } else {
      return null;
    }
  }

  /**
   * @description Set next page Id for pagination
   * @param queryMoreToken Next page Id
   */
  private void setNextPageId(String queryMoreToken) {
    String cacheKey = getNextPageIdCacheKey();
    if (String.isNotBlank(cacheKey)) {
      Cache.SessionPartition sessionPart = Cache.Session.getPartition(
        'local.DataPartition'
      );
      if (String.isBlank(queryMoreToken)) {
        sessionPart.remove(cacheKey);
      } else {
        sessionPart.put(cacheKey, queryMoreToken);
      }
    }
  }

  /**
   * @description get next page Id session cache key
   * @return String Cache key
   */
  private String getNextPageIdCacheKey() {
    if (String.isNotBlank(this.parentId)) {
      String key = this.parentId.right(
          this.parentId.length() - this.parentId.indexOf('|') - 1
        )
        .remove('-')
        .remove('_');
      return 'QueryMoreToken' + key;
    } else {
      return null;
    }
  }
}
