/**
 * @author Ayushi Gupta
 * @since  08/2023
 * @group CCRM, ML
 * @description Diary Comment external query base class
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class DiaryCommentExternalQuery extends ExternalObjectQueryBase {
  /**
   * @description constructor
   */
  public DiaryCommentExternalQuery() {
    this.enableServerPagination = true;
  }
  /**
   * @description wrapper class for response
   */
  public class DiaryCommentCalloutResponse extends ExternalObjectQueryBase.ExternalObjectCalloutResponse {
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
  public override ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    ExternalQueryResult externalQueryResult;
    QueryModeEnum queryMode = prepareCallout(queryContext);
    if (queryMode == QueryModeEnum.RECORD_DETAIL && displayDummyRecord()) {
      externalQueryResult = createDummyExternalRecord(
        this.externalId,
        new Map<String, Object>{
          'Sequence' => this.externalId.substringAfterLast('-')
        }
      );
      return externalQueryResult;
    }
    HttpCalloutResponse response = makeCallout(queryMode, queryContext);
    this.calloutResponse = parseResponse(response.body);
    externalQueryResult = createExternalRecords(this.calloutResponse);
    //Pass pagination token
    externalQueryResult.queryMoreToken = ((DiaryCommentCalloutResponse) this.calloutResponse)
      .conversationControl;
    return externalQueryResult;
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (DiaryCommentCalloutResponse) CalloutModel.deserialize(
      responseBody,
      DiaryCommentCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to diary comment records
   * @param calloutResponse response
   * @return List<Map<String, Object>>
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row;

    DiaryCommentCalloutResponse diaryCommentCalloutResponse = (DiaryCommentCalloutResponse) calloutResponse;
    if (diaryCommentCalloutResponse == null) {
      return result;
    }
    if (String.isBlank(this.parentId) && String.isBlank(this.externalId)) {
      return result;
    }
    for (CommentDetails cd : diaryCommentCalloutResponse.commentDetails) {
      row = new Map<String, Object>{
        'DisplayUrl' => URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        cd.compositeId,
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
        'ModifiedDate' => adjustUTCDateTime(cd.dateChanged)
      };
      if (
        String.isNotBlank(this.parentField) && String.isNotBlank(this.parentId)
      ) {
        row.put('ExternalId', cd.compositeId);
        row.put(this.parentField, this.parentId);
      } else {
        row.put('ExternalId', this.externalId);
      }
      result.externalRecords.add(row);
    }
    return result;
  }

  /**
   * @description Need to display Dummy FA record? return false by default
   * @return true / false
   **/
  @TestVisible
  protected override Boolean displayDummyRecord() {
    return String.isNotBlank(this.externalId) && String.isBlank(this.parentId);
  }

  /**
   * @description Rest API callout to get diary comments
   * @param queryMode QueryMode Enum
   * @param queryContext DataSource QueryContext
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout(
    QueryModeEnum queryMode,
    DataSource.QueryContext queryContext
  ) {
    ARNCService service = new ARNCService();
    Map<String, String> attributes = new Map<String, String>();
    if (
      String.isNotBlank(this.parentField) && String.isNotBlank(this.parentId)
    ) {
      attributes.put(this.parentField, this.parentId);
    }
    attributes.put('offSet', String.valueOf(queryContext.offSet));
    attributes.put('pageSize', String.valueOf(queryContext.maxResults));
    HttpCalloutResponse response = service.queryDiaryComment(
      this.parentField,
      attributes
    );
    return response;
  }
}
