import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { navigate } from "c/utils";

export default class ReleaseLogLink extends NavigationMixin(LightningElement) {
  handleClick() {
    this.navigateToTabPage();
  }

  navigateToTabPage() {
    // Navigate to a Release_Notes custom tab
    const attributes = {
      apiName: "Release_Notes"
    };
    navigate(this, "standard__navItemPage", attributes);
  }
}
