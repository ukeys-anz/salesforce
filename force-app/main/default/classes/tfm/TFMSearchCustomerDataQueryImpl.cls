/**
 * @author Hinduja Upadhyay
 * @since  11/2023
 * @description implementation class to hit mule api to get external object
 */
public with sharing class TFMSearchCustomerDataQueryImpl {
  private static final String COL_HEADER_EXTERNAL_ID = 'ExternalId';
  private static final String COL_HEADER_DISPLAYURL = 'DisplayUrl';
  private static final String COL_HEADER_CREDENTIAL = 'credentialsResId';
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
   * @description method will hit the api and call method to set rows of the object
   * @param refId Service.IdType
   * @param searchText String
   * @return List<Map<String, Object>>
   */
  public static List<Map<String, Object>> getRowsAndHitAPI(
    Service.IdType refId,
    String searchText
  ) {
    List<Map<String, Object>> lstReturnDataset = new List<Map<String, Object>>();
    TFMPersonDigitalIdentityModel model;
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
      if (Test.isRunningTest()) {
        model = TFMPersonDigitalIdentityModel.parse(PERSON_IDENTITY_ROWS_JSON);
      } else {
        model = api.searchCustAPI(staffModel);
      }
      lstReturnDataset = setRowsOfObject(model);
    }
    return lstReturnDataset;
  }

  /**
   * @description method is returing name as first char upper case
   * @param name String
   * @return String
   */
  public static String nameFormat(String name) {
    if (String.isBlank(name)) {
      return '';
    }
    String result = '';
    for (String namePart : name.trim().split(' ')) {
      result += namePart.capitalize() + ' ';
    }
    return result.trim();
  }

  /**
   * @description method is returing date in format 'dd/MM/yyyy hh:mm:ss'
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

  /**
   * @description method is setting the rows from api to external object records
   * @param  result TFMPersonDigitalIdentityModel
   * @return  List<Map<String, Object>>
   */
  public static List<Map<String, Object>> setRowsOfObject(
    TFMPersonDigitalIdentityModel result
  ) {
    List<Map<String, Object>> lstReturnDataset = new List<Map<String, Object>>();
    List<TFMPersonDigitalIdentityModel.Result> lstResult = (List<TFMPersonDigitalIdentityModel.Result>) result.result;
    for (TFMPersonDigitalIdentityModel.Result res : lstResult) {
      Map<String, Object> curRow = new Map<String, Object>();
      curRow.put(UUID, res.id);
      curRow.put(PREFERRED_NAME, res.preferredName);
      curRow.put(MOBILE_NUMBER, res.securityMobile);
      curRow.put(EMAIL, res.securityEmail);
      curRow.put(CREATED_ON, dateFormat(String.valueOf(res.createDateTime)));
      curRow.put(OCV_ID, res.ocvId);
      curRow.put(IAL, res.identityAssuranceLevel);
      curRow.put(STATUS, nameFormat(String.valueOf(res.status)));
      curRow.put(INTERNALUSERID, res.idxInternalUserId);

      List<TFMPersonDigitalIdentityModel.Persona> persona = (List<TFMPersonDigitalIdentityModel.Persona>) res.persona;

      for (TFMPersonDigitalIdentityModel.Persona person : persona) {
        curRow.put(PERSONA_TYPE, nameFormat(String.valueOf(person.type)));
        curRow.put(PERSONA_ID, person.refResourceId);
      }

      List<TFMPersonDigitalIdentityModel.Credential> credential = (List<TFMPersonDigitalIdentityModel.Credential>) res.credential;
      String resouceIds;
      List<String> resourceIdList = new List<String>();
      for (TFMPersonDigitalIdentityModel.Credential cred : credential) {
        if (cred.type == PIN) {
          curRow.put(PIN_STATUS, nameFormat(String.valueOf(cred.status)));
        }
        if (
          cred.type == DEVICE_REG &&
          String.valueOf(cred.appCorrelationId) != null
        ) {
          resourceIdList.add(
            CID +
              String.valueOf(cred.appCorrelationId) +
              '(' +
              String.valueOf(cred.refResourceId) +
              ')'
          );
        } else if (cred.type == DEVICE_REG) {
          resourceIdList.add(DID + String.valueOf(cred.refResourceId));
        }
      }

      resouceIds = string.join(resourceIdList, ',');
      curRow.put(COL_HEADER_CREDENTIAL, resouceIds);
      curRow.put(COL_HEADER_EXTERNAL_ID, res.id);
      curRow.put(COL_HEADER_DISPLAYURL, URL.getOrgDomainURL() + '/' + res.id);
      lstReturnDataset.add(curRow);
    }
    return lstReturnDataset;
  }
}
