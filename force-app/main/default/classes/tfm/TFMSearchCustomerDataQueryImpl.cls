/**
 * @author Hinduja Upadhyay
 * @since  11/2023
 * @description implementation class to hit mule api to get external object
 */
public with sharing class TFMSearchCustomerDataQueryImpl {
  /**
   * @description method will sync columns for creating external object
   * @return List<DataSource.Table>
   */
  public static List<DataSource.Table> sync() {
    List<DataSource.Table> tables = new List<DataSource.Table>();
    List<DataSource.Column> columns = new List<DataSource.Column>();
    columns.add(
      DataSource.Column.text(TFMConstants.COL_HEADER_EXTERNAL_ID, 255)
    );
    columns.add(DataSource.Column.text(TFMConstants.UUID, 255));
    columns.add(DataSource.Column.text(TFMConstants.PREFERRED_NAME, 255));
    columns.add(DataSource.Column.text(TFMConstants.MOBILE_NUMBER, 255));
    columns.add(DataSource.Column.text(TFMConstants.EMAIL, 100));
    columns.add(DataSource.Column.text(TFMConstants.CREATED_ON, 100));
    columns.add(DataSource.Column.text(TFMConstants.OCV_ID, 100));
    columns.add(DataSource.Column.number(TFMConstants.IAL, 100, 0));
    columns.add(DataSource.Column.text(TFMConstants.STATUS, 100));
    columns.add(DataSource.Column.text(TFMConstants.PIN_STATUS, 100));
    columns.add(DataSource.Column.text(TFMConstants.PIN_REF_ID, 100));
    columns.add(DataSource.Column.text(TFMConstants.PERSONA_ID, 100));
    columns.add(DataSource.Column.text(TFMConstants.INTERNALUSERID, 100));
    columns.add(DataSource.Column.text(TFMConstants.PERSONA_TYPE, 100));
    columns.add(DataSource.Column.textarea(TFMConstants.COL_HEADER_CREDENTIAL));
    columns.add(DataSource.Column.url(TFMConstants.COL_HEADER_DISPLAYURL));
    tables.add(
      DataSource.Table.get(
        'PersonDigitalIdentity',
        TFMConstants.COL_HEADER_EXTERNAL_ID,
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
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = refId;
    staffModel.idValue = searchText;
    staffModel.anzTokenType = TFMConstants.ANZTOKENTYPE;
    if (refId == Service.IdType.IDENTIFIER) {
      staffModel.realm = TFMConstants.ANZ_REALM_SYSTEM_VALUE;
      staffModel.anzTokenType = TFMConstants.ANZ_STAFF_TOKEN_TYPE;
    }
    TFMSearchCustomerAPIRepository api = new TFMSearchCustomerAPIRepository();
    model = api.searchCustAPI(staffModel);
    lstReturnDataset = setRowsOfObject(model, refId);
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
    toConvert = toConvert.replace(TFMConstants.LETTERT, ' ')
      .replace(TFMConstants.LETTERZ, '');
    DateTime dt = DateTime.valueOf(toConvert);
    String dateStr = dt.format(TFMConstants.DATEFORMAT);
    return dateStr;
  }

  /**
   * @description method is setting the rows from api to external object records
   * @param  result TFMPersonDigitalIdentityModel
   * @param refId Service.IdType
   * @return  List<Map<String, Object>>
   */
  public static List<Map<String, Object>> setRowsOfObject(
    TFMPersonDigitalIdentityModel result, Service.IdType refId
  ) {
    String resouceIds;
    List<Map<String, Object>> lstReturnDataset = new List<Map<String, Object>>();
    List<TFMPersonDigitalIdentityModel.Result> lstResult = (List<TFMPersonDigitalIdentityModel.Result>) result.result;
    for (TFMPersonDigitalIdentityModel.Result res : lstResult) {
      Map<String, Object> curRow = new Map<String, Object>();
      curRow.put(TFMConstants.UUID, res.id);
      curRow.put(TFMConstants.PREFERRED_NAME, res.preferredName ?? res.id);
      curRow.put(TFMConstants.OCV_ID, res.ocvId);
      curRow.put(TFMConstants.STATUS, nameFormat(String.valueOf(res.status)));
      curRow.put(TFMConstants.MOBILE_NUMBER, res.securityMobile ?? String.valueOf(res.archivedIdentifiers[0]));
      curRow.put(TFMConstants.COL_HEADER_EXTERNAL_ID, res.id);
      curRow.put(
        TFMConstants.COL_HEADER_DISPLAYURL,
        URL.getOrgDomainURL() + '/' + res.id
      );
      if (refId != Service.IdType.IDENTIFIER) {
        curRow.put(TFMConstants.EMAIL, res.securityEmail);
        curRow.put(
          TFMConstants.CREATED_ON,
          dateFormat(String.valueOf(res.createDateTime))
        );
        curRow.put(TFMConstants.IAL, Integer.valueOf(res.identityAssuranceLevel));
        curRow.put(TFMConstants.INTERNALUSERID, res.idxInternalUserId);
        List<TFMPersonDigitalIdentityModel.Persona> persona = (List<TFMPersonDigitalIdentityModel.Persona>) res.persona;
        List<TFMPersonDigitalIdentityModel.Credential> credential = (List<TFMPersonDigitalIdentityModel.Credential>) res.credential;
        curRow.putAll(addPersonaId(persona));
        curRow.putAll(addPinStatus(credential));
        resouceIds = getResourceIds(credential);
        curRow.put(TFMConstants.COL_HEADER_CREDENTIAL, resouceIds);
      }
      lstReturnDataset.add(curRow);
    }
    return lstReturnDataset;
  }

  /**
   * @description method is setting the persona data in rows
   * @param  persona List<TFMPersonDigitalIdentityModel.Persona Persona List
   * @return  Map<String, Object>
   */
  private static Map<String, Object> addPersonaId(
    List<TFMPersonDigitalIdentityModel.Persona> persona
  ) {
    Map<String, Object> curRow = new Map<String, Object>();
    for (TFMPersonDigitalIdentityModel.Persona person : persona) {
      curRow.put(
        TFMConstants.PERSONA_TYPE,
        nameFormat(String.valueOf(person.type))
      );
      curRow.put(TFMConstants.PERSONA_ID, person.refResourceId);
    }
    return curRow;
  }
  /**
   * @description method is setting pin status data in row
   * @param  credential List<TFMPersonDigitalIdentityModel.Credential>
   * @return  Map<String, Object>
   */
  private static Map<String, Object> addPinStatus(
    List<TFMPersonDigitalIdentityModel.Credential> credential
  ) {
    Map<String, Object> curRow = new Map<String, Object>();
    for (TFMPersonDigitalIdentityModel.Credential cred : credential) {
      if (cred.type == TFMConstants.PIN) {
        curRow.put(
          TFMConstants.PIN_STATUS,
          nameFormat(String.valueOf(cred.status))
        );
        curRow.put(TFMConstants.PIN_REF_ID, String.valueOf(cred.refResourceId));
      }
    }
    return curRow;
  }
  /**
   * @description method is getting ResourceIds from result json
   * @param  credential List<TFMPersonDigitalIdentityModel.Credential>
   * @return List<Map<String, Object>>
   */
  private static String getResourceIds(
    List<TFMPersonDigitalIdentityModel.Credential> credential
  ) {
    List<String> resourceIdList = new List<String>();
    for (TFMPersonDigitalIdentityModel.Credential cred : credential) {
      if (cred.type != TFMConstants.DEVICE_REG) {
        continue;
      }
      String appCorrelationId = String.valueOf(cred.appCorrelationId);
      String refResourceId = String.valueOf(cred.refResourceId);
      if (String.isNotBlank(appCorrelationId)) {
        resourceIdList.add(
          TFMConstants.CID + appCorrelationId + '(' + refResourceId + ')'
        );
      } else {
        resourceIdList.add(TFMConstants.DID + refResourceId);
      }
    }
    return String.join(resourceIdList, ',');
  }
}
