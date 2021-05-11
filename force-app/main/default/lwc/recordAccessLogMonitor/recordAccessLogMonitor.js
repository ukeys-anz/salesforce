import { LightningElement, api } from "lwc";
import Id from "@salesforce/user/Id";

import createLog from "@salesforce/apex/RecordAccessLogController.createLog";

export default class RecordAccessLogMonitor extends LightningElement {
  @api recordId;
  @api objectApiName;
  userId = Id;
  browser;

  connectedCallback() {
    //Get the browser and version currently used
    this.browser = (function () {
      var ua = navigator.userAgent,
        tem,
        M =
          ua.match(
            /(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i
          ) || [];
      if (/trident/i.test(M[1])) {
        tem = /\brv[ :]+(\d+)/g.exec(ua) || [];
        return "IE " + (tem[1] || "");
      }
      if (M[1] === "Chrome") {
        tem = ua.match(/\b(OPR|Edge)\/(\d+)/);
        if (tem != null) return tem.slice(1).join(" ").replace("OPR", "Opera");
      }
      M = M[2] ? [M[1], M[2]] : [navigator.appName, navigator.appVersion, "-?"];
      if ((tem = ua.match(/version\/(\d+)/i)) != null) M.splice(1, 1, tem[1]);
      return M.join(" ");
    })();

    createLog({
      browserDetails: this.browser,
      objectName: this.objectApiName,
      recordId: this.recordId,
      userId: this.userId
    });
  }
}
