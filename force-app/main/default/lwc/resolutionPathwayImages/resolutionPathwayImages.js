import { LightningElement, api } from "lwc";

import IMGS from "@salesforce/resourceUrl/ResolutionPathway";
export default class resolutionPathwayImages extends LightningElement {
  @api imageName;
  @api imageWidth;
  @api imageHeight;
  get imageURL() {
    return IMGS + "/" + this.imageName;
  }
}
