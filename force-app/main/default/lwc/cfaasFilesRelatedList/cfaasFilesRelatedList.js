import { api, LightningElement, wire, track } from "lwc";
import { getRelatedListRecords } from "lightning/uiRelatedListApi";
import { handleErrorShowToast, handleErrors } from "c/utils";
import { NavigationMixin } from "lightning/navigation";
import getCFaaSDocument from "@salesforce/apex/CFaaSController.getCFaaSDocument";
import previewCFaaSFilesPermission from "@salesforce/customPermission/ANZx_CFaaS_View_Files";
import ACCOUNT_OBJECT from "@salesforce/schema/Account";
import RESIDENTIAL_LOAN_APP_OBJECT from "@salesforce/schema/ResidentialLoanApplication";
import FINANCIAL_ACCOUNT_OBJECT from "@salesforce/schema/FinServ__FinancialAccount__c";
import CFAAS_FILE_OBJECT from "@salesforce/schema/CFaaS_File__c";
import DOCUMENT_ID_FIELD from "@salesforce/schema/CFaaS_File__c.Document_Id__c";
import FILE_NAME_FIELD from "@salesforce/schema/CFaaS_File__c.File_Name__c";
import FILE_EXTENSION_FIELD from "@salesforce/schema/CFaaS_File__c.File_Extension__c";
import DATE_CREATED_FIELD from "@salesforce/schema/CFaaS_File__c.Date_Created__c";
import SECURITY_CLASSIFICATION_FIELD from "@salesforce/schema/CFaaS_File__c.Security_Classification__c";
import CUSTOMER_OCV_ID_FIELD from "@salesforce/schema/CFaaS_File__c.Customer__r.OCV_Id__c";
import RESIDENTIAL_LOAN_OCV_ID_FIELD from "@salesforce/schema/CFaaS_File__c.Residential_Loan_Id__r.Account.OCV_Id__c";
import FINANCIAL_ACCOUNT_OCV_ID_FIELD from "@salesforce/schema/CFaas_File__c.Financial_Account__r.FinServ__PrimaryOwner__r.OCV_Id__c";

const MAX_RECORD_COUNT = 2000;
const RECORD_PAGE_ROW_SIZE = 5;
const EXPANDED_VIEW_DEFAULT_ROW_SIZE = 20;
const RELATED_LIST_ID = "CFaaS_Files__r";
const COMPONENT_TYPE = "standard__component";
const COMPONENT_NAME = "c__CFaaSFileRelatedListSubtab";
const FIELD_API_NAME_ATT = "fieldApiName";
const CFAAS_OBJECT_PREFIX = CFAAS_FILE_OBJECT.objectApiName + ".";
const CUSTOMER_LIST_TITLE = "Customer Files";
const RESIDENTIAL_LOAN_LIST_TITLE = "Loan Files";
const FINANCIAL_ACCOUNT_LIST_TITLE = "Financial Account Files";
const COLUMNS = [
  {
    label: "File Name",
    fieldName: "fileName",
    type: "customUrl",
    typeAttributes: {
      tooltip: { fieldName: "fileName" },
      label: { fieldName: "fileName" },
      value: { fieldName: "fileName" },
      rowdata: { fieldName: "rowdata" }
    },
    cellAttributes: {
      class: "slds-text-align_left slds-truncate"
    },
    hideDefaultActions: true
  },
  {
    label: "Date Created",
    fieldName: "dateCreated",
    type: "date",
    typeAttributes: {
      year: "numeric",
      month: "numeric",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    },
    sortable: true,
    hideDefaultActions: true
  },
  {
    label: "Extension",
    fieldName: "fileExtension",
    hideDefaultActions: true,
    initialWidth: 90
  }
];

const FIELDS = [
  CFAAS_OBJECT_PREFIX + DOCUMENT_ID_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + FILE_NAME_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + FILE_EXTENSION_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + DATE_CREATED_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + SECURITY_CLASSIFICATION_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + CUSTOMER_OCV_ID_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + RESIDENTIAL_LOAN_OCV_ID_FIELD[FIELD_API_NAME_ATT],
  CFAAS_OBJECT_PREFIX + FINANCIAL_ACCOUNT_OCV_ID_FIELD[FIELD_API_NAME_ATT]
];

export default class CfaasFilesRelatedList extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objectApiName;
  @track isLoading = true;
  @track showSpinner;
  records;
  displayRecords;
  displayRecordCount;
  error;
  columns = COLUMNS;
  defaultSortDirection = "desc";
  sortDirection = "desc";
  sortedBy = "dateCreated";

  @wire(getRelatedListRecords, {
    parentRecordId: "$recordId",
    relatedListId: RELATED_LIST_ID,
    fields: FIELDS,
    pageSize: MAX_RECORD_COUNT
  })
  wireRecords({ error, data }) {
    if (data?.records?.length > 0) {
      let tempRecords = [];
      let filteredRecords = this.filterFilesLinkedToMultipleObjects(
        data.records
      );

      filteredRecords.forEach((row) => {
        tempRecords.push({
          rowdata: {
            id: row.id,
            documentId: row.fields.Document_Id__c.value,
            securityClassification: row.fields.Security_Classification__c.value,
            ocvId: this.getOCVIdValue(row)
          },
          fileName: row.fields.File_Name__c.value,
          dateCreated: row.fields.Date_Created__c.value,
          fileExtension: row.fields.File_Extension__c.value
        });
      });

      this.records = tempRecords;
      this.records.sort(
        this.sortBy(this.sortedBy, this.sortDirection === "asc" ? 1 : -1)
      );

      if (this.records.length > 0) {
        this.setDisplayRecords();
      }
    } else if (error) {
      this.handleError(error);
    }
    this.isLoading = false;
  }

  connectedCallback() {
    this.isLoading = true;
  }

  renderedCallback() {
    this.allowLazyLoading();
    this.setComponentTitle();
    this.setExtensionColumnWidth();
  }

  setDisplayRecords() {
    // display only the first 5 records if in record page
    this.displayRecordCount = this.objectApiName
      ? RECORD_PAGE_ROW_SIZE
      : EXPANDED_VIEW_DEFAULT_ROW_SIZE;

    this.displayRecords = this.objectApiName
      ? this.records.slice(0, RECORD_PAGE_ROW_SIZE)
      : this.records.slice(0, EXPANDED_VIEW_DEFAULT_ROW_SIZE);
  }

  setComponentTitle() {
    switch (this.objectApiName) {
      case ACCOUNT_OBJECT.objectApiName:
        this.title = CUSTOMER_LIST_TITLE;
        break;
      case RESIDENTIAL_LOAN_APP_OBJECT.objectApiName:
        this.title = RESIDENTIAL_LOAN_LIST_TITLE;
        break;
      case FINANCIAL_ACCOUNT_OBJECT.objectApiName:
        this.title = FINANCIAL_ACCOUNT_LIST_TITLE;
        break;
      default:
        break;
    }
  }

  setExtensionColumnWidth() {
    if (!this.objectApiName) {
      //remove initialwidth in Extension column if LWC is opened as subtab
      for (const col of this.columns) {
        if (col.fieldName === "fileExtension") {
          col.initialWidth = "";
          break;
        }
      }
    }
  }

  allowLazyLoading() {
    let element = this.template.querySelector(".div-data-table");

    //remove div height (used for lazy loading) if the component is in the record page
    if (element && !this.objectApiName) {
      element.style = "height: 600px";
    }
  }

  getOCVIdValue(row) {
    let ocvIdValue;
    let objectPageName = this.objectApiName ?? this.getObjectNameByTitle();

    switch (objectPageName) {
      case RESIDENTIAL_LOAN_APP_OBJECT.objectApiName:
        ocvIdValue =
          row.fields.Residential_Loan_Id__r.value?.fields.Account?.value.fields
            .OCV_ID__c.value;
        break;
      case ACCOUNT_OBJECT.objectApiName:
        ocvIdValue = row.fields.Customer__r.value?.fields.OCV_ID__c.value;
        break;
      case FINANCIAL_ACCOUNT_OBJECT.objectApiName:
        ocvIdValue =
          row.fields.Financial_Account__r.value?.fields.FinServ__PrimaryOwner__r
            ?.value.fields.OCV_ID__c.value;
        break;
      default:
        break;
    }

    return ocvIdValue;
  }

  getObjectNameByTitle() {
    let objectApiName;

    switch (this.title) {
      case CUSTOMER_LIST_TITLE:
        objectApiName = ACCOUNT_OBJECT.objectApiName;
        break;
      case RESIDENTIAL_LOAN_LIST_TITLE:
        objectApiName = RESIDENTIAL_LOAN_APP_OBJECT.objectApiName;
        break;
      case FINANCIAL_ACCOUNT_LIST_TITLE:
        objectApiName = FINANCIAL_ACCOUNT_OBJECT.objectApiName;
        break;
      default:
        break;
    }

    return objectApiName;
  }

  // Filter to ensure files related to both Customer AND Loan or Finance Account,
  // should ONLY display on the Loan App or Finance Account
  filterFilesLinkedToMultipleObjects(ogRecords) {
    return ogRecords.filter((item) => {
      return this.title === CUSTOMER_LIST_TITLE &&
        item.fields.Customer__r.value &&
        (item.fields.Residential_Loan_Id__r?.value ||
          item.fields.Financial_Account__r?.value)
        ? false
        : true;
    });
  }

  handleFilePreview(event) {
    if (previewCFaaSFilesPermission) {
      this.showSpinner = true;
      const selectedFile = event.detail;

      try {
        getCFaaSDocument({
          ocvId: selectedFile.ocvId,
          docId: selectedFile.documentId,
          cfaasFileId: selectedFile.id,
          securityClassification: selectedFile.securityClassification
        })
          .then((result) => {
            this.showSpinner = false;
            this.showFilePreviewModal(result);
          })
          .catch((error) => {
            this.showSpinner = false;
            this.handleError(error);
          });
      } catch (error) {
        this.handleError(error);
        this.showSpinner = false;
      }
    } else {
      handleErrorShowToast(
        this,
        "Error",
        "",
        "You need an extra permission level to preview documents.",
        "pester"
      );
    }
  }

  showFilePreviewModal(contentDocId) {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "filePreview"
      },
      state: {
        selectedRecordId: contentDocId
      }
    });
  }

  //Accept other field sorting just in case there's a need to be sorted in the future
  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  loadMoreData() {
    if (!this.objectApiName) {
      if (this.displayRecordCount >= this.records.length) {
        return;
      }

      this.displayRecordCount += EXPANDED_VIEW_DEFAULT_ROW_SIZE;
      this.displayRecords = this.records.slice(0, this.displayRecordCount);
    }
  }

  navigateToRelatedListSubTab() {
    this[NavigationMixin.Navigate]({
      type: COMPONENT_TYPE,
      attributes: {
        componentName: COMPONENT_NAME
      },
      state: {
        c__recordId: this.recordId,
        c__cmpTitle: this.title
      }
    });
  }

  handleError = (error) => {
    const errorMessage = handleErrors.call(this, error);

    handleErrorShowToast(this, "Error", "", errorMessage, "pester");
  };
}
