import { api, LightningElement, wire } from "lwc";
import { SimpleToast } from "c/utils";
import {
  getRecord,
  getFieldValue,
  notifyRecordUpdateAvailable
} from "lightning/uiRecordApi";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { CloseActionScreenEvent } from "lightning/actions";
import getOppLineItems from "@salesforce/apex/CommercialOpportunityController.getOppLineItems";
import publishCaseToPega from "@salesforce/apex/CommercialOpportunityController.publishCaseToPega";
//Opportunity Fields
import OPP_ACCOUNT_ID from "@salesforce/schema/Opportunity.AccountId";
import OPP_ACCOUNT_NAME from "@salesforce/schema/Opportunity.Account.Name";
import OPP_ACCOUNT_SOURCE_SYSTEM_ID from "@salesforce/schema/Opportunity.Account.Source_System_ID__c";
import OPP_ACCOUNT_SOURCE_SYSTEM_NAME from "@salesforce/schema/Opportunity.Account.Source_System_Name__c";
import OPP_BROKER_NAME from "@salesforce/schema/Opportunity.Broker_Name__c";
import OPP_CIRCLE_OF_INFLUENCE from "@salesforce/schema/Opportunity.Circle_Of_Influence__c";
import OPP_CLG_LINKAGE from "@salesforce/schema/Opportunity.CLG__c";
import OPP_CLG_LINKAGE_NAME from "@salesforce/schema/Opportunity.CLG__r.Name";
import OPP_CLG_LINKAGE_SOURCE_SYSTEMID from "@salesforce/schema/Opportunity.CLG__r.Source_System_ID__c";
import OPP_CLG_LINKAGE_SOURCE_SYSTEMNAME from "@salesforce/schema/Opportunity.CLG__r.Source_System_Name__c";
import OPP_CUSTOMER_NEEDS from "@salesforce/schema/Opportunity.Customer_Needs__c";
import OPP_ID from "@salesforce/schema/Opportunity.Opportunity_ID__c";
import OPP_INDUSTRY from "@salesforce/schema/Opportunity.Industry__c";
import OPP_LEAD_SOURCE from "@salesforce/schema/Opportunity.LeadSource";
import OPP_NAME from "@salesforce/schema/Opportunity.Name";
import OPP_NEW_TO_BANK from "@salesforce/schema/Opportunity.New_to_Bank__c";
import OPP_OWNER from "@salesforce/schema/Opportunity.OwnerId";
import OPP_OWNER_NAME from "@salesforce/schema/Opportunity.Owner.Name";
import OPP_PEGA_CASE_ID from "@salesforce/schema/Opportunity.Pega_Case_Unique_Identifier__c";
import OPP_SECONDARY_NEEDS from "@salesforce/schema/Opportunity.Secondary_Customer_Needs__c";
import OPP_SPECIALISATION from "@salesforce/schema/Opportunity.Specialisation__c";
import OPP_TRANSACTION_BANKING_PROCESS from "@salesforce/schema/Opportunity.Transaction_Banking_Process__c";
//OpportunityLineItem Fields
import OLI_PRODUCT2_ID from "@salesforce/schema/OpportunityLineItem.Product2.Id";
import OLI_PRODUCT2_NAME from "@salesforce/schema/OpportunityLineItem.Product2.Name";
import OLI_PRODUCT2_TYPE from "@salesforce/schema/OpportunityLineItem.Product2.Type";
import OLI_PRODUCT2_CODE from "@salesforce/schema/OpportunityLineItem.Product2.ProductCode";
import OLI_PRODUCT2_SUBCODE from "@salesforce/schema/OpportunityLineItem.Product2.Sub_Product_Code__c";
//Related Entity Fields (FinServ__AccountAccountRelation__c)
import REL_ENTITY_ACCOUNT_ID from "@salesforce/schema/FinServ__AccountAccountRelation__c.FinServ__Account__c";
import REL_ENTITY_ACCOUNT_NAME from "@salesforce/schema/FinServ__AccountAccountRelation__c.FinServ__Account__r.Name";
import REL_ENTITY_CUSTOMER_TYPE from "@salesforce/schema/FinServ__AccountAccountRelation__c.FinServ__Account__r.RecordType.Name";
import REL_ENTITY_SOURCE_SYSTEMID from "@salesforce/schema/FinServ__AccountAccountRelation__c.FinServ__Account__r.Source_System_ID__c";
import REL_ENTITY_SOURCE_SYSTEMNAME from "@salesforce/schema/FinServ__AccountAccountRelation__c.FinServ__Account__r.Source_System_Name__c";

const OPP_FIELDS = [
  OPP_NAME,
  OPP_ACCOUNT_ID,
  OPP_ACCOUNT_NAME,
  OPP_ACCOUNT_SOURCE_SYSTEM_ID,
  OPP_ACCOUNT_SOURCE_SYSTEM_NAME,
  OPP_CUSTOMER_NEEDS,
  OPP_SECONDARY_NEEDS,
  OPP_ID,
  OPP_INDUSTRY,
  OPP_LEAD_SOURCE,
  OPP_SPECIALISATION,
  OPP_NEW_TO_BANK,
  OPP_OWNER,
  OPP_OWNER_NAME,
  OPP_BROKER_NAME,
  OPP_CIRCLE_OF_INFLUENCE,
  OPP_CLG_LINKAGE,
  OPP_CLG_LINKAGE_NAME,
  OPP_CLG_LINKAGE_SOURCE_SYSTEMID,
  OPP_CLG_LINKAGE_SOURCE_SYSTEMNAME,
  OPP_PEGA_CASE_ID,
  OPP_TRANSACTION_BANKING_PROCESS
];

export default class PublishToPega extends LightningElement {
  @api recordId;
  isLoading = false;
  pegaCaseId;
  oppAccountId = null;
  relatedListFilter = {};
  toast = new SimpleToast(this);
  entityProductMapping;

  //Opportunity Record
  oppData = {};
  oppFields = [
    {
      name: OPP_NAME,
      label: "Opportunity Name"
    },
    {
      name: OPP_ACCOUNT_ID,
      label: "Customer Name"
    },
    {
      name: OPP_CUSTOMER_NEEDS,
      label: "Customer Needs"
    },
    {
      name: OPP_SECONDARY_NEEDS,
      label: "Secondary Needs"
    },
    {
      name: OPP_INDUSTRY,
      label: "Industry"
    },
    {
      name: OPP_LEAD_SOURCE,
      label: "Lead Source"
    },
    {
      name: OPP_SPECIALISATION,
      label: "Specialisation"
    },
    {
      name: OPP_NEW_TO_BANK,
      label: "New to Bank"
    },
    {
      name: OPP_OWNER,
      label: "Opportunity Owner"
    },
    {
      name: OPP_BROKER_NAME,
      label: "Broker Name"
    },
    {
      name: OPP_CIRCLE_OF_INFLUENCE,
      label: "Circle of Influence"
    },
    {
      name: OPP_CLG_LINKAGE,
      label: "CLG Linkage"
    },
    {
      name: OPP_TRANSACTION_BANKING_PROCESS,
      label: "Transaction Banking Process"
    }
  ];
  //Products Related List
  productsData = [];
  productsFields = [
    {
      fieldName: OLI_PRODUCT2_NAME.fieldApiName,
      label: "Product Name",
      type: "text",
      hideDefaultActions: true
    },
    {
      fieldName: OLI_PRODUCT2_CODE.fieldApiName,
      label: "Product Code",
      type: "text",
      hideDefaultActions: true
    },
    {
      fieldName: OLI_PRODUCT2_SUBCODE.fieldApiName,
      label: "Product SubCode",
      type: "text",
      hideDefaultActions: true
    }
  ];
  //CLG Related Entity
  entityData = [];
  entityFields = [
    {
      fieldName: REL_ENTITY_ACCOUNT_NAME.fieldApiName,
      label: "Name",
      type: "text",
      hideDefaultActions: true
    },
    {
      fieldName: REL_ENTITY_CUSTOMER_TYPE.fieldApiName,
      label: "Type",
      type: "text",
      hideDefaultActions: true
    },
    {
      fieldName: REL_ENTITY_SOURCE_SYSTEMID.fieldApiName,
      label: "Source System ID",
      type: "text",
      hideDefaultActions: true
    },
    {
      fieldName: REL_ENTITY_SOURCE_SYSTEMNAME.fieldApiName,
      label: "Source System Name",
      type: "text",
      hideDefaultActions: true
    }
  ];

  // CLASSNAMES
  get headerClassNames() {
    return [
      "slds-text-heading_small",
      "slds-text-align_center",
      "slds-m-around_medium"
    ];
  }
  get formViewDivClassNames() {
    return [
      "slds-form-element",
      "slds-form-element_horizontal",
      "slds-m-around_none",
      "slds-p-around_none",
      "slds-text-align_left",
      "slds-grid slds-border_top"
    ];
  }
  get formLabelClassNames() {
    return [
      "slds-form-element__label",
      "slds-col",
      "slds-form-element_1-col",
      "custom-label",
      "slds-var-p-around_medium"
    ];
  }
  get formOutputFieldClassNames() {
    return [
      "slds-form-element__control",
      "slds-p-left_none",
      "slds-m-top_x-small",
      "slds-m-left_xx-small"
    ];
  }

  get showEntityProductMapping() {
    return this.entityData?.length > 0 && this.productsData?.length > 0;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: OPP_FIELDS
  })
  wireOpportunity({ error, data }) {
    if (error) {
      this.toast.error(
        "An error occurred while loading Opportunity record, please try again.",
        error
      );
    }
    if (data) {
      this.oppData = data;
      this.oppAccountId = getFieldValue(data, OPP_CLG_LINKAGE);
      this.pegaCaseId = getFieldValue(data, OPP_PEGA_CASE_ID);
      this.getRelatedOppLineItems();
    }
  }

  @wire(getRelatedListRecords, {
    parentRecordId: "$oppAccountId",
    relatedListId: "FinServ__RelatedToAccounts__r",
    //Note: need to provide the fields as strings due to SF limitation with getRelatedListRecords
    fields: [
      "FinServ__AccountAccountRelation__c.FinServ__Account__c",
      "FinServ__AccountAccountRelation__c.FinServ__Account__r.Name",
      "FinServ__AccountAccountRelation__c.FinServ__Account__r.Source_System_ID__c",
      "FinServ__AccountAccountRelation__c.FinServ__Account__r.Source_System_Name__c",
      "FinServ__AccountAccountRelation__c.FinServ__Account__r.RecordType.Name"
    ]
    //where: "$relatedListFilter"
  })
  wireRelatedEntities({ error, data }) {
    if (error) {
      this.toast.error(
        "An error occurred while loading related entity records, please try again.",
        error
      );
    }
    if (data) {
      this.entityData = data?.records?.map((rec) => {
        return {
          ...rec,
          [REL_ENTITY_ACCOUNT_ID.fieldApiName]: rec.id,
          [REL_ENTITY_ACCOUNT_NAME.fieldApiName]: getFieldValue(
            rec,
            REL_ENTITY_ACCOUNT_NAME
          ),
          [REL_ENTITY_CUSTOMER_TYPE.fieldApiName]: getFieldValue(
            rec,
            REL_ENTITY_CUSTOMER_TYPE
          ),
          [REL_ENTITY_SOURCE_SYSTEMID.fieldApiName]: getFieldValue(
            rec,
            REL_ENTITY_SOURCE_SYSTEMID
          ),
          [REL_ENTITY_SOURCE_SYSTEMNAME.fieldApiName]: getFieldValue(
            rec,
            REL_ENTITY_SOURCE_SYSTEMNAME
          )
        };
      });
    }
  }

  // Note: @wire getRelatedListRecords does NOT work with OpportunityLineItems related records;
  // https://salesforce.stackexchange.com/questions/400652/unable-to-get-opportunitylineitem-using-uirelatedlistapi
  async getRelatedOppLineItems() {
    try {
      this.isLoading = true;
      const fetchedRecords = await getOppLineItems({
        opportunityId: this.recordId
      });

      this.productsData = fetchedRecords?.map((rec) => {
        return {
          ...rec,
          [OLI_PRODUCT2_ID.fieldApiName]: rec.Product2.Id,
          [OLI_PRODUCT2_NAME.fieldApiName]: rec.Product2.Name,
          [OLI_PRODUCT2_TYPE.fieldApiName]: rec.Product2.Type,
          [OLI_PRODUCT2_CODE.fieldApiName]: rec.Product2.ProductCode,
          [OLI_PRODUCT2_SUBCODE.fieldApiName]: rec.Product2.Sub_Product_Code__c
        };
      });
    } catch (error) {
      this.toast.error(
        "An error occurred while retrieving the selected products, please try again.",
        error
      );
    } finally {
      this.isLoading = false;
    }
  }

  handleEntityProductMappingChange(e) {
    this.entityProductMapping = e.target.value;
  }

  handleSubmit() {
    //don't proceed if pega case exists or if required fields are not populated
    if (this.pegaCaseExists() || !this.requiredFieldsPopulated()) {
      this.isLoading = false;
      return;
    }
    this.invokePublishCaseToPega();
  }

  pegaCaseExists() {
    if (!this.pegaCaseId) {
      return false;
    }
    const pegaCaseLink = getFieldValue(this.oppData, OPP_PEGA_CASE_ID);
    this.toast.error(
      `Pega Case is already created. Please refer ${pegaCaseLink} to view details.`
    );
    return true;
  }

  requiredFieldsPopulated() {
    //TODO: Confirm all fields that need to be validated
    if (
      !getFieldValue(this.oppData, OPP_NEW_TO_BANK) ||
      !getFieldValue(this.oppData, OPP_TRANSACTION_BANKING_PROCESS) ||
      this.productsData?.length === 0
    ) {
      this.toast.error(
        `One or more required fields are missing: New to Bank, Transaction Banking Process, and/or Selected Products`
      );
      return false;
    }

    if (
      this.entityData?.length > 0 &&
      this.refs.relEntitiesTable.getSelectedRows().length === 0
    ) {
      this.toast.error(
        `Please select at least one related entity from the CLG related entities table.`
      );
      return false;
    }

    if (
      this.refs.relEntitiesTable.getSelectedRows().length > 0 &&
      !this.entityProductMapping
    ) {
      this.toast.error(`Please enter the legal entities and product notes.`);
      return false;
    }
    return true;
  }

  async invokePublishCaseToPega() {
    this.isLoading = true;
    const selectedEntities = this.refs.relEntitiesTable.getSelectedRows();
    const selectedEntityIds = selectedEntities.map((rec) => rec.id);

    try {
      await publishCaseToPega({
        opportunityId: this.recordId,
        relatedEntityIds: selectedEntityIds,
        entityProductMapping: this.entityProductMapping
      });
      this.toast.success("The case was created to Pega successfully.");
      notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      this.dispatchEvent(new CloseActionScreenEvent());
    } catch (error) {
      this.toast.error(
        "An error occurred while creating case to Pega, please try again.",
        error
      );
    } finally {
      this.isLoading = false;
    }
  }
}
