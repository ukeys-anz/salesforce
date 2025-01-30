import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

export default class OcrRelatedListViewAllContainer extends LightningElement {
  @wire(CurrentPageReference)
  currentPageRef;

  get recId() {
    return this.currentPageRef?.state?.c__recId;
  }
}
