/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Diary Comment external query base class
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class CCRMDiaryCommentQuery extends CCRMExternalObjectQueryBase {
  /**
   * @description constructor
   */
  public CCRMDiaryCommentQuery() {
    this.enableServerPagination = true;
  }
  /**
   * @description wrapper class for response
   */
  public class DiaryCommentCalloutResponse {
    public String conversationControl;
    public Integer totalComments;
    public Integer commentsCount;
    public String moreComments;
    public List<CommentDetails> commentDetails;
    public String lastIndex;
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
    public String compositeId;
    public String itemSubKey;
    public String sequenceNumber;
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result + queryMoreToken
   */
  public override virtual CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    super.execute(queryContext);
    getParent();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    prepareCallout();
    try {
      if (
        String.isBlank(this.parentId) && (String.isNotBlank(this.externalId))
      ) {
        Map<String, Object> row = new Map<String, Object>();
        row.put('ExternalId', this.externalId);
        row.put('AdditionalInformation', 'No further information available');
        row.put('Sequence', this.externalId.substringAfterLast('-'));
        result.queryResult.add(row);
        return result;
      }
      HttpCalloutResponse response = makeCallout();
      if (response.successful && response.body != null) {
        DiaryCommentCalloutResponse calloutResponse = (DiaryCommentCalloutResponse) System.JSON.deserialize(
          response.body,
          DiaryCommentCalloutResponse.class
        );
        result = createDiaryComments(calloutResponse);
        //Pass pagination token
        result.queryMoreToken = calloutResponse.conversationControl;
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
  private CCRMExternalObjectQueryBase.ExternalQueryResult createDiaryComments(
    DiaryCommentCalloutResponse calloutResponse
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row = new Map<String, Object>();
    if (calloutResponse == null) {
      return result;
    }
    if (String.isBlank(this.parentId) && String.isBlank(this.externalId)) {
      return result;
    }
    for (CommentDetails cd : calloutResponse.commentDetails) {
      row = new Map<String, Object>{
        'Sequence' => cd.sequenceNumber,
        'Permanent' => cd.itemSubKey.contains('PERMA') ? true : false,
        'Description' => cd.comment,
        'ExpiryDate' => formatDate(cd.dateExpires),
        'Branch' => cd.branch,
        'Operator' => cd.operatorId,
        'DatePlaced' => cd.itemSubKey.contains('PERMA')
          ? formatDate(cd.datePlaced)
          : formatDateTime(cd.datePlaced),
        'WorkQueue' => cd.workQueue,
        'CycleCode' => cd.cycleCode,
        'PromptDate' => adjustUTCDateTime(cd.datePrompt),
        'CustomerReview' => cd.customerReviewFlag == 'Y' ? true : false,
        'ModifiedDate' => adjustUTCDateTime(cd.dateChanged),
        'DisplayUrl' => URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        cd.compositeId
      };
      if (String.isNotBlank(this.parent) && String.isNotBlank(this.parentId)) {
        row.put('ExternalId', cd.compositeId);
        row.put(this.parent, this.parentId);
      } else {
        row.put('ExternalId', this.externalId);
      }

      result.queryResult.add(row);
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
   * @description Rest API callout to get diary comments
   * @param
   * @return HttpCalloutResponse
   */
  protected override HttpCalloutResponse makeCallout() {
    CCRMARNCService service = new CCRMARNCService();
    Map<String, String> attributes = new Map<String, String>();
    if (String.isNotBlank(this.parent) && String.isNotBlank(this.parentId)) {
      attributes.put(this.parent, this.parentId);
    }
    attributes.put('offSet', String.valueOf(this.queryContext.offSet));
    attributes.put('pageSize', String.valueOf(this.queryContext.maxResults));
    HttpCalloutResponse response = service.queryDiaryComment(
      this.parent,
      attributes
    );
    return response;
  }
}
