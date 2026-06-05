import { LightningElement, api, wire, track } from "lwc";
import getAgentActionHistory from "@salesforce/apex/AgentActionHistoryController.getAgentActionHistory";

export default class AgentActionHistory extends LightningElement {
  @api recordId;
  @api displayMode = "Detail View";

  @track data = [];

  // Columns for Detail View
  detailColumns = [
    { label: "Action Name", fieldName: "Name" },
    { label: "Agent Name", fieldName: "Agent_Name__c" },
    { label: "Action", fieldName: "Action__c" },
    {
      label: "Created Date",
      fieldName: "CreatedDate",
      type: "date",
      typeAttributes: {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
      }
    }
  ];

  // Columns for List View (compact)
  listColumns = [
    {
      label: "Action Name",
      fieldName: "Name",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Agent Name",
      fieldName: "Agent_Name__c",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Action",
      fieldName: "Action__c",
      wrapText: true,
      hideDefaultActions: true
    },
    {
      label: "Action Date",
      fieldName: "CreatedDate",
      wrapText: true,
      hideDefaultActions: true,
      type: "date",
      typeAttributes: {
        year: "numeric",
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
      }
    }
  ];

  @wire(getAgentActionHistory, {
    recordId: "$recordId",
    displayMode: "$displayMode"
  })
  wiredHistory({ error, data }) {
    if (data) {
      this.data = data;
    } else if (error) {
      console.error("Error fetching agent action history", error);
    }
  }

  get isDetailView() {
    return this.displayMode === "Detail View";
  }

  get isListView() {
    return this.displayMode === "List View";
  }

  get columns() {
    return this.isDetailView ? this.detailColumns : this.listColumns;
  }

  get recordCount() {
    return this.data?.histories?.length || 0;
  }

  get hasData() {
    return this.data?.histories?.length > 0;
  }

  get tableClass() {
    return this.displayMode === "List View"
      ? "slds-table_striped"
      : "slds-table_cell-buffer";
  }
}
