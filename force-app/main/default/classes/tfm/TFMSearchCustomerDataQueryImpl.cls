/**
 * @author Hinduja Upadhyay
 * @since  11/2023
 * @description implementation class to hit mule api to get external object
 */
public with sharing class TFMSearchCustomerDataQueryImpl {
  private static final String COL_HEADER_EXTERNAL_ID = 'ExternalId';
  private static final String COL_HEADER_DISPLAYURL = 'DisplayUrl';
  private static final String COL_HEADER_UUID = '_id';
  private static final String COL_HEADER_PREFERRED_NAME = 'preferredName';
  private static final String COL_HEADER_MOBILE_NUMBER = 'securityMobile';
  private static final String COL_HEADER_EMAIL = 'securityEmail';
  private static final String COL_HEADER_CREATED_ON = 'createDateTime';
  private static final String COL_HEADER_OCV_ID = 'ocvId';
  private static final String COL_HEADER_IAL = 'identityAssuranceLevel';
  private static final String COL_HEADER_STATUS = 'status';
  private static final String COL_HEADER_PERSONA_TYPE = 'type';
  private static final String COL_HEADER_RESOURCE = '_refResourceId';
  private static final String COL_HEADER_CREDENTIAL = 'credentialsResId';
  private static final String COL_HEADER_APPCORRELATIONID = 'appCorrelationID';
  private static final String COL_HEADER_IDXINTERNALUSER = 'idxInternalUserId';
  private static final String PIN = 'pin';
  private static final String DEVICE_REG = 'device-reg';
  private static final String CID = 'CID-';
  private static final String DID = 'DID-';
  //field name for external obj
  private static final String UUID = 'UUID';
  private static final String PREFERRED_NAME = 'Preferred Name';
  private static final String MOBILE_NUMBER = 'Mobile Number';
  private static final String EMAIL = 'Email';
  private static final String CREATED_ON = 'Created On';
  private static final String OCV_ID = 'OCV ID';
  private static final String IAL = 'IAL (Identity Assurance Level)';
  private static final String STATUS = 'Status';
  private static final String PIN_STATUS = 'PIN Status';
  private static final String PERSONA_ID = 'Persona ID';
  private static final String PERSONA_TYPE = 'Type';
  private static final String INTERNALUSERID = 'Internal User ID';
  private static final String ANZTOKENTYPE = 'staffRqfCustomer';
  private static final String ACTION = 'SearchCustomer';
  private static final String LETTERT = 'T';
  private static final String LETTERZ = 'Z';
  private static final String CREDNTIAL = 'credential';
  private static final String PERSONA = 'persona';
  private static final String ISVALIDACTION = 'isValidAction';
  private static final String RESULT = 'result';
  private static final String DATEFORMAT = 'dd/MM/yyyy hh:mm:ss';
  private static final String LABELTRUE = 'true';
  @TestVisible
  private static final String PERSON_IDENTITY_ROWS_JSON = Service.getStaticResource(
    'mock_PersonDigitalIdentity'
  );

  /**
   * @description method will sync columns for creating external object
   * @return List<DataSource.Table>
   */
  public static List<DataSource.Table> sync() {
    List<DataSource.Table> tables = new List<DataSource.Table>();
    List<DataSource.Column> columns = new List<DataSource.Column>();
    columns.add(DataSource.Column.text(COL_HEADER_EXTERNAL_ID, 255));
    columns.add(DataSource.Column.text(UUID, 255));
    columns.add(DataSource.Column.text(PREFERRED_NAME, 255));
    columns.add(DataSource.Column.text(MOBILE_NUMBER, 255));
    columns.add(DataSource.Column.text(EMAIL, 100));
    columns.add(DataSource.Column.text(CREATED_ON, 100));
    columns.add(DataSource.Column.text(OCV_ID, 100));
    columns.add(DataSource.Column.text(IAL, 100));
    columns.add(DataSource.Column.text(STATUS, 100));
    columns.add(DataSource.Column.text(PIN_STATUS, 100));
    columns.add(DataSource.Column.text(PERSONA_ID, 100));
    columns.add(DataSource.Column.text(INTERNALUSERID, 100));
    columns.add(DataSource.Column.text(PERSONA_TYPE, 100));
    columns.add(DataSource.Column.textarea(COL_HEADER_CREDENTIAL));
    columns.add(DataSource.Column.url(COL_HEADER_DISPLAYURL));
    tables.add(
      DataSource.Table.get(
        'PersonDigitalIdentity',
        COL_HEADER_EXTERNAL_ID,
        columns
      )
    );
    return tables;
  }

  /**
   * @description method will hit the api and create rows for external object
   * @param refId Service.IdType
   * @param searchText String
   * @return List<Map<String, Object>>
   */
  public static List<Map<String, Object>> getRowsAndHitAPI(
    Service.IdType refId,
    String searchText
  ) {
    List<Map<String, Object>> lstReturnDataset = new List<Map<String, Object>>();
    Map<String, Object> jsonResp = new Map<String, Object>();
    Map<String, String> headers = new Map<String, String>();
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.headers = headers;
    staffModel.idType = refId;
    staffModel.idValue = searchText;
    staffModel.anzTokenType = ANZTOKENTYPE;
    staffModel.action = ACTION;
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    headers = api.getValidStaffToken(staffModel);
    if (headers != null && headers.get(ISVALIDACTION) == LABELTRUE) {
      //removing valid action from header
      headers.remove(ISVALIDACTION);
      HttpCalloutResponse response = api.searchCustAPI(staffModel);
      if (Test.isRunningTest()) {
        jsonResp = (Map<String, Object>) JSON.deserializeUntyped(
          PERSON_IDENTITY_ROWS_JSON
        );
      }
      jsonResp = (Map<String, Object>) JSON.deserializeUntyped(response.body);
      List<Object> lstBlog = (List<Object>) jsonResp.get(RESULT);
      for (Object blog : lstBlog) {
        Map<String, Object> curRow = new Map<String, Object>();
        Map<String, Object> resultMap = (Map<String, Object>) blog;
        curRow.put(UUID, resultMap.get(COL_HEADER_UUID));
        curRow.put(PREFERRED_NAME, resultMap.get(COL_HEADER_PREFERRED_NAME));
        curRow.put(MOBILE_NUMBER, resultMap.get(COL_HEADER_MOBILE_NUMBER));
        curRow.put(EMAIL, resultMap.get(COL_HEADER_EMAIL));
        curRow.put(
          CREATED_ON,
          dateFormat(String.valueOf(resultMap.get(COL_HEADER_CREATED_ON)))
        );
        curRow.put(OCV_ID, resultMap.get(COL_HEADER_OCV_ID));
        curRow.put(IAL, resultMap.get(COL_HEADER_IAL));
        curRow.put(
          STATUS,
          nameFormat(String.valueOf(resultMap.get(COL_HEADER_STATUS)))
        );
        curRow.put(INTERNALUSERID, resultMap.get(COL_HEADER_IDXINTERNALUSER));

        List<Object> persona = (List<Object>) resultMap.get(PERSONA);

        for (Object person : persona) {
          Map<String, Object> personaMap = (Map<String, Object>) person;
          curRow.put(
            PERSONA_TYPE,
            nameFormat(String.valueOf(personaMap.get(COL_HEADER_PERSONA_TYPE)))
          );
          curRow.put(PERSONA_ID, personaMap.get(COL_HEADER_RESOURCE));
        }

        List<Object> credential = (List<Object>) resultMap.get(CREDNTIAL);
        String resouceIds;
        List<String> resourceIdList = new List<String>();
        for (Object cred : credential) {
          Map<String, Object> credMap = (Map<String, Object>) cred;
          if (credMap.get(COL_HEADER_PERSONA_TYPE) == PIN) {
            curRow.put(
              PIN_STATUS,
              nameFormat(String.valueOf(credMap.get(COL_HEADER_STATUS)))
            );
          }
          if (
            credMap.get(COL_HEADER_PERSONA_TYPE) == DEVICE_REG &&
            String.valueOf(credMap.get(COL_HEADER_APPCORRELATIONID)) != null
          ) {
            resourceIdList.add(
              CID +
              String.valueOf(credMap.get(COL_HEADER_APPCORRELATIONID)) +
              '(' +
              String.valueOf(credMap.get(COL_HEADER_RESOURCE)) +
              ')'
            );
          } else if (credMap.get(COL_HEADER_PERSONA_TYPE) == DEVICE_REG) {
            resourceIdList.add(
              DID + String.valueOf(credMap.get(COL_HEADER_RESOURCE))
            );
          }
        }

        resouceIds = string.join(resourceIdList, ',');
        curRow.put(COL_HEADER_CREDENTIAL, resouceIds);
        curRow.put(COL_HEADER_EXTERNAL_ID, resultMap.get(COL_HEADER_UUID));
        curRow.put(
          COL_HEADER_DISPLAYURL,
          URL.getOrgDomainURL() +
          '/' +
          resultMap.get(COL_HEADER_UUID)
        );
        lstReturnDataset.add(curRow);
      }
      return lstReturnDataset;
    }

    return lstReturnDataset;
  }

  /**
   * @description method is returing name as first char upper case
   * @param name String
   * @return String
   */
  public static String nameFormat(String name) {
    String result = '';
    if (name != null && name != '') {
      for (String iter : name.split('[ ]+')) {
        if (iter != null && iter != '') {
          if (iter.length() > 1) {
            result +=
              iter.substring(0, 1).toUpperCase() +
              iter.substring(1, iter.length()) +
              ' ';
          } else {
            result += iter.substring(0, 1).toUpperCase() + ' ';
          }
        }
      }
      result = result.substring(0, result.length() - 1);
    }
    return result;
  }

  /**
   * @description method is returing name as first char upper case
   * @param createdDate String
   * @return String
   */
  public static String dateFormat(String createdDate) {
    String toConvert = createdDate;
    toConvert = toConvert.replace(LETTERT, ' ').replace(LETTERZ, '');
    DateTime dt = DateTime.valueOf(toConvert);
    String dateStr = dt.format(DATEFORMAT);
    return dateStr;
  }
}
