/**
 * @author Naman Garg
 * @since  12/2024
 * @description Commercial AMBIT Request Model
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public class CommercialAMBITRequestModel {
  private static final String CRM_SF = 'CRM-SF';
  private static final String CUSTOMER_MASTER = 'CUSTOMERMASTER';
  private static final String TPMI_SAO = 'TPMI-SAO';
  private static final String CAP = 'CAP';
  private static final String CUSTOMER_MASTER1 = 'Customer Master';
  private static final String PRODUCT_ROWID = 'ProductRowId';
  private static final String AUD = 'AUD';
  private static final String CUSTOMER_ID = 'CustomerId';

  public DCOpportunityPackage DCOpportunityPackage;

  /**
   * @description model for DCOpportunityPackage
   */
  public class DCOpportunityPackage {
    public OpportunityEntity Opportunity;
    public PartyInformation PartyInformation;

    public UserToImpersonateForDefaults UserToImpersonateForDefaults;

    /**
     * @description Constructor for DCOpportunityPackage
     * @param oppRec Opportunity rec
     * @param oppLineItemId Opportunity Line Item Id
     */
    public DCOpportunityPackage(Opportunity oppRec, Id oppLineItemId) {
      this.Opportunity = new OpportunityEntity(oppRec, oppLineItemId);
      this.PartyInformation = new PartyInformation(
        oppRec.Account?.Source_System_ID__c,
        CUSTOMER_MASTER,
        CUSTOMER_ID
      );
      this.UserToImpersonateForDefaults = new UserToImpersonateForDefaults(
        oppRec.OpportunityTeamMembers?.User.Lan_Id__c ?? ''
      );
    }
  }

  /**
   * @description model for Opportunity
   */
  public class OpportunityEntity {
    public OpportunityId OpportunityId;
    public SalesLeadId SalesLeadId;
    public SecondarySalesLeadId SecondarySalesLeadId;
    public Source Source;
    public CurrencyId CurrencyId;
    public AiiExtSysRefs AiiExtSysRefs;
    public BrokerId BrokerId;
    public String Name;

    /**
     * @description Constructor for Opportunity Entity
     * @param oppRec
     * @param oppLineItemId
     */
    public OpportunityEntity(opportunity oppRec, String oppLineItemId) {
      this.Name = oppRec.Opp_Id__c;
      this.OpportunityId = new OpportunityId(
        (String) oppRec.Opp_Id__c,
        CRM_SF,
        PRODUCT_ROWID
      );
      this.CurrencyId = new CurrencyId(AUD);
      this.SalesLeadId = new SalesLeadId(oppRec.Owner.Lan_Id__c);
      this.SecondarySalesLeadId = new SecondarySalesLeadId(
        oppRec.OpportunityTeamMembers?.User.Lan_Id__c ?? ''
      );
      this.Source = new Source(CRM_SF);
      this.AiiExtSysRefs = new AiiExtSysRefs(
        (String) oppLineItemId,
        CRM_SF,
        PRODUCT_ROWID
      );
      this.BrokerId = new BrokerId(
        oppRec.Broker_Name__r.AssetFinanceTPMISAO__c,
        CUSTOMER_MASTER,
        TPMI_SAO
      );
    }
  }

  /**
   * @description model for OpportunityId
   */
  public class OpportunityId {
    public String ExtSysObjRef;
    public String ExtSysName;
    public String ExtSysObjType;

    /**
     * @description Constructor for OpportunityId
     * @param extSysObjRef External System Object Reference
     * @param extSysName External System Name
     * @param extSysObjType External System Object Type
     */
    public OpportunityId(
      String extSysObjRef,
      String extSysName,
      String extSysObjType
    ) {
      this.ExtSysObjRef = extSysObjRef;
      this.ExtSysName = extSysName;
      this.ExtSysObjType = extSysObjType;
    }
  }

  /**
   * @description model for CurrencyId
   */
  public class CurrencyId {
    public String FkCode;

    /**
     * @description Constructor for CurrencyId
     * @param fkCode
     */
    public CurrencyId(String fkCode) {
      this.FkCode = fkCode;
    }
  }

  /**
   * @description model for SalesLeadId
   */
  public class SalesLeadId {
    public String Username;

    /**
     * @description Constructor for SalesLeadId
     * @param userName Lan Id of Opp Owner
     */
    public SalesLeadId(String userName) {
      this.Username = userName;
    }
  }

  /**
   * @description model for SecondarySalesLeadId
   */
  public class SecondarySalesLeadId {
    public String Username;

    /**
     * @description Constructor for SecondarySalesLeadId
     * @param userName Lan Id of Opp Team Member
     */
    public SecondarySalesLeadId(String userName) {
      this.Username = userName;
    }
  }

  /**
   * @description model for Source
   */
  public class Source {
    public String XTLookupValue;

    /**
     * @description Constructor for Source
     * @param xtLookupValue
     */
    public Source(String xtLookupValue) {
      this.XTLookupValue = xtLookupValue;
    }
  }

  /**
   * @description model for BrokerId
   */
  public class BrokerId {
    public AiiExtSysRefs AiiExtSysRefs;
    /**
     * @description Constructor for BrokerId
     * @param extSysObjRef External System Object Reference
     * @param extSysName External System Name
     * @param extSysObjType External System Object Type
     */
    public BrokerId(
      String extSysObjRef,
      String extSysName,
      String extSysObjType
    ) {
      this.AiiExtSysRefs = new AiiExtSysRefs(
        extSysObjRef,
        extSysName,
        extSysObjType
      );
    }
  }

  /**
   * @description model for PartyInformation
   */
  public class PartyInformation {
    public PartyId PartyId;
    public CustomFields CustomFields;
    /**
     * @description Constructor for PartyInformation
     * @param extSysObjRef External System Object Reference
     * @param extSysName External System Name
     * @param extSysObjType External System Object Type
     */
    public PartyInformation(
      String extSysObjRef,
      String extSysName,
      String extSysObjType
    ) {
      this.PartyId = new PartyId(extSysObjRef, extSysName, extSysObjType);
      this.CustomFields = new CustomFields();
    }
  }

  /**
   * @description model for PartyId
   */
  public class PartyId {
    public AiiExtSysRefs AiiExtSysRefs;
    /**
     * @description Constructor for PartyId
     * @param extSysObjRef External System Object Reference
     * @param extSysName External System Name
     * @param extSysObjType External System Object Type
     */
    public PartyId(
      String extSysObjRef,
      String extSysName,
      String extSysObjType
    ) {
      this.AiiExtSysRefs = new AiiExtSysRefs(
        extSysObjRef,
        extSysName,
        extSysObjType
      );
    }
  }

  /**
   * @description model for AiiExtSysRefs
   */
  public class AiiExtSysRefs {
    public DCIdByIdOrAiiExtSysRef DCIdByIdOrAiiExtSysRef;
    /**
     * @description Constructor for AiiExtSysRefs
     * @param extSysObjRef External System Object Reference
     * @param extSysName External System Name
     * @param extSysObjType External System Object Type
     */
    public AiiExtSysRefs(
      String extSysObjRef,
      String extSysName,
      String extSysObjType
    ) {
      this.DCIdByIdOrAiiExtSysRef = new DCIdByIdOrAiiExtSysRef(
        extSysObjRef,
        extSysName,
        extSysObjType
      );
    }
  }

  /**
   * @description model for DCIdByIdOrAiiExtSysRef
   */
  public class DCIdByIdOrAiiExtSysRef {
    public String ExtSysObjRef;
    public String ExtSysName;
    public String ExtSysObjType;

    /**
     * @description Constructor for DCIdByIdOrAiiExtSysRef
     * @param extSysObjRef External System Object Reference
     * @param extSysName External System Name
     * @param extSysObjType External System Object Type
     */
    public DCIdByIdOrAiiExtSysRef(
      String extSysObjRef,
      String extSysName,
      String extSysObjType
    ) {
      this.ExtSysObjRef = extSysObjRef;
      this.ExtSysName = extSysName;
      this.ExtSysObjType = extSysObjType;
    }
  }

  /**
   * @description model for CustomFields
   */
  public class CustomFields {
    public DCCustomField DCCustomField;
    /**
     * @description Constructor for CustomFields
     */
    public CustomFields() {
      this.DCCustomField = new DCCustomField(CUSTOMER_MASTER1, CAP);
    }
  }

  /**
   * @description model for DCCustomField
   */
  public class DCCustomField {
    public String FieldName;
    public String FieldValue;

    /**
     * @description Constructor for DCCustomField
     * @param fieldName
     * @param fieldValue
     */
    public DCCustomField(String fieldName, String fieldValue) {
      this.FieldName = fieldName;
      this.FieldValue = fieldValue;
    }
  }

  /**
   * @description model for UserToImpersonateForDefaults
   */
  public class UserToImpersonateForDefaults {
    public string UserName;
    /**
     * @description Constructor for UserToImpersonateForDefaults
     * @param userName
     */
    public UserToImpersonateForDefaults(String userName) {
      this.UserName = userName;
    }
  }

  /**
   * @description Constructor for CommercialAMBITRequestModel
   * @param oppRec Opportunity rec
   * @param oppLineItemId Opportunity Line Item Id
   */
  public CommercialAMBITRequestModel(Opportunity oppRec, Id oppLineItemId) {
    this.DCOpportunityPackage = new DCOpportunityPackage(oppRec, oppLineItemId);
  }
}
