import { LightningElement, wire } from "lwc";
import getUserGenerationSummary from "@salesforce/apex/GenAIAnalyticsService.getUserGenerationSummary";

export default class ClientSummaryAnalytics extends LightningElement {
  data;
  error;
  sortDirection = "asc";
  sortedBy;
  isLoading = true;

  // Generic comparator for lightning-datatable sorting
  sortBy(field, reverse) {
    return (a, b) => {
      let aVal = a[field];
      let bVal = b[field];

      // Normalize null/undefined
      const isNullish = (v) => v === null || v === undefined;
      if (isNullish(aVal) && isNullish(bVal)) return 0;
      if (isNullish(aVal)) return -1 * reverse;
      if (isNullish(bVal)) return 1 * reverse;

      // Handle date/time field explicitly
      if (field === "lastGeneratedTime") {
        aVal = new Date(aVal).getTime();
        bVal = new Date(bVal).getTime();
      }

      // Case-insensitive for strings
      if (typeof aVal === "string" && typeof bVal === "string") {
        aVal = aVal.toLowerCase();
        bVal = bVal.toLowerCase();
      }

      if (aVal > bVal) return 1 * reverse;
      if (aVal < bVal) return -1 * reverse;
      return 0;
    };
  }

  columns = [
    {
      label: "User Segment",
      fieldName: "userSegment",
      type: "text",
      sortable: true
    },
    { label: "User Name", fieldName: "userName", type: "text", sortable: true },
    {
      label: "Weekly Generations",
      fieldName: "weeklyGenerationCount",
      type: "number",
      sortable: true
    },
    {
      label: "Monthly Generations",
      fieldName: "monthlyGenerationCount",
      type: "number",
      sortable: true
    },
    {
      label: "Last Generated",
      fieldName: "lastGeneratedTime",
      type: "date",
      sortable: true,
      typeAttributes: {
        year: "numeric",
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
      }
    }
  ];

  @wire(getUserGenerationSummary)
  wiredSummary({ data, error }) {
    this.isLoading = false;

    if (data) {
      this.data = data;
      this.error = undefined;
    } else if (error) {
      let message = "Unknown error";

      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (error.body && error.body.message) {
        message = error.body.message;
      }

      this.error = message;
      this.data = undefined;
    }
  }

  handleSort(event) {
    const { fieldName: sortedByField, sortDirection } = event.detail;

    // Defensive copy and checks
    const cloneData = Array.isArray(this.data) ? [...this.data] : [];
    const reverse = sortDirection === "asc" ? 1 : -1;

    cloneData.sort(this.sortBy(sortedByField, reverse));

    this.data = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedByField;
  }
}
