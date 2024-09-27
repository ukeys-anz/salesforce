import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class StreamingMonitorModal extends LightningModal {
  @api eventData;

  handleOkay() {
    this.close("okay");
  }

  get isPlatformEvent() {
    return this.eventData?.channel?.endsWith("__e");
  }

  get deepViewFieldList() {
    if (!this.isPlatformEvent) {
      return [];
    }

    let payload = JSON.parse(this.eventData?.payload);
    const filtered = Object.keys(payload)
      .filter((key) => key.endsWith("__c"))
      .map((item) => ({ label: item, value: item }));

    return filtered;
  }

  handleFieldChange(event) {
    let selectedField = event.target.value;
    let payload = JSON.parse(this.eventData?.payload);
    try {
      this.refs.deepViewData.value = JSON.stringify(
        JSON.parse(payload[selectedField]),
        null,
        4
      );
    } catch {
      this.refs.deepViewData.value =
        "Please select a valid field contains JSON data";
    }
  }
}
