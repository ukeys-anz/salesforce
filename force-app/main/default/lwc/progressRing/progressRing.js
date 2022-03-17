import { LightningElement, api, track } from "lwc";

export default class ProgressRing extends LightningElement {
  @api progress = 0;
  @api showPercent;
  @api emoticon;
  @api size = "small";
  @api image;

  @track progressStyle;
  @track ringSize = 40;
  @track displayPercent;
  @track stroke = 2.52;

  connectedCallback() {
    //Handle the size of the ring
    switch (this.size) {
      case "small":
        this.ringSize = 40;
        this.stroke = 2.52;
        break;
      case "medium":
        this.ringSize = 75;
        this.stroke = 4.65;
        break;
      default:
        this.ringSize = 75;
        this.stroke = 4.65;
    }

    //Calculate the progress to fill
    this.progressStyle = Math.round(this.progress * this.stroke) + " 999";
  }
}
