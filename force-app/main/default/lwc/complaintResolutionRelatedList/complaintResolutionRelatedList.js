import { LightningElement, api, wire, track } from "lwc";
import getComplaintResolution from "@salesforce/apex/ComplaintResolutionController.getComplaintResolution";
import { refreshApex } from "@salesforce/apex";
import { navigate, handleWireError, showToast } from "c/utils";
import { deleteRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";

const actions = [
  { label: "Edit", name: "edit" },
  { label: "Delete", name: "delete" }
];

const COLUMNs = [
  {
    label: "Complaint ID",
    fieldName: "caseLink",
    type: "url",
    initialWidth: 150,
    typeAttributes: {
      label: { fieldName: "caseNumber" },
      target: "_blank"
    }
  },
  {
    label: "Date Received",
    fieldName: "dateReceived",
    type: "date",
    initialWidth: 150
  },
  { label: "Owner", fieldName: "caseOwner", type: "text", initialWidth: 150 },
  { label: "Status", fieldName: "caseStatus", type: "text", initialWidth: 150 },
  {
    label: "Issue Type",
    fieldName: "caseType",
    type: "text",
    initialWidth: 150
  },
  {
    label: "Subsequent Issue Type",
    fieldName: "subsequentIssue",
    type: "text",
    initialWidth: 150
  },
  {
    label: "Complaint Outcome",
    fieldName: "complaintOutcome",
    type: "text",
    initialWidth: 150
  },
  {
    label: "Complaint Remedy",
    fieldName: "complaintRemedy",
    type: "text",
    initialWidth: 150
  },
  {
    label: "Total Financial Amount",
    fieldName: "totalFinancialAmount",
    type: "currency",
    initialWidth: 150
  },
  {
    type: "action",
    typeAttributes: { rowActions: actions }
  }
];

const Page_Size = 10;

export default class ComplaintResolutionRelatedList extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  columns = COLUMNs;
  alldata = [];
  @track visibledata = [];
  @track error;
  totalPages = 1;
  page = 1;

  @wire(getComplaintResolution, { accountId: "$recordId" })
  wiredGetComplaintResolution({ data, error }) {
    if (data) {
      this.alldata = data.map((complaint) => {
        return {
          caseId: complaint.Id || "",
          caseLink: complaint.Id ? "/" + complaint.Id : "",
          caseNumber: complaint.CaseNumber || "",
          dateReceived: complaint.IDR_Date_Received__c || "",
          caseOwner: complaint.Owner.Name || "",
          caseStatus: complaint.Status || "",
          caseType: complaint.Type || "",
          subsequentIssue: complaint.IDR_Subsequent_Issue__c || "",
          complaintOutcome: complaint.IDR_Complaint_Outcome__c || "",
          totalFinancialAmount: complaint.IDR_Total_Financial_Amount__c || "0",
          complaintRemedy:
            complaint?.Complaint_Resolutions__r?.[0]?.IDR_Complaint_Remedy__c ||
            ""
        };
      });

      this.totalPages = Math.ceil(this.alldata.length / Page_Size);
      this.updateVisibleData();
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.alldata = [];
      this.visibledata = [];
    }
  }

  updateVisibleData() {
    const start = (this.page - 1) * Page_Size;
    const end = start + Page_Size;
    this.visibledata = this.alldata.slice(start, end);
  }

  handlePrevious() {
    if (this.page > 1) {
      this.page -= 1;
      this.updateVisibleData();
    }
  }

  handleNext() {
    if (this.page < this.totalPages) {
      this.page += 1;
      this.updateVisibleData();
    }
  }
  get isFirstPage() {
    return this.page === 1;
  }

  get isLastPage() {
    return this.page === this.totalPages;
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "delete":
        this.deleteRow(row.caseId);
        break;
      case "edit":
        this.editRow(row.caseId);
        break;
      default:
    }
  }

  deleteRow(caseId) {
    deleteRecord(caseId)
      .then(() => {
        showToast(this, "Success", "Case deleted successfully!", "", "success");
        return refreshApex(this.wiredGetComplaintResolution);
      })
      .catch((error) => {
        handleWireError(
          this,
          error.body.output.errors[0].message || "Case not deleted",
          error
        );
      });
  }

  editRow(caseId) {
    const attributes = {
      objectApiName: "Case",
      actionName: "edit",
      recordId: caseId
    };
    navigate(this, "standard__recordPage", attributes);
  }
  handleNewCase() {
    const attributes = {
      objectApiName: "Case",
      actionName: "new"
    };
    navigate(this, "standard__objectPage", attributes);
  }
}
