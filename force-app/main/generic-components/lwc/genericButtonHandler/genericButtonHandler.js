import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import RoleName from "@salesforce/schema/User.UserRole.Name";
import getConfig from "@salesforce/apex/GenericController.getConfig";
import { CurrentPageReference } from "lightning/navigation";

export default class GenericButtonHandler extends LightningElement {
  componentConstructor;
  displayComponent;
  userId = Id;
  @wire(CurrentPageReference) currentPageRef;
  _userRole;

  _cardData;
  @api
  get cardData() {
    return this._cardData;
  }
  set cardData(cardData) {
    return (this._cardData = cardData);
  }

  _cardConfig;
  @api
  get cardConfig() {
    return this._cardConfig;
  }
  set cardConfig(cardConfig) {
    return (this._cardConfig = cardConfig);
  }

  get userRole() {
    return this._userRole;
  }
  set userRole(userRole) {
    return (this._userRole = userRole);
  }

  get resolvedConfigName() {
    return this.currentPageRef?.state?.c__configName || this.configName;
  }

  async connectedCallback() {
    await this.initialise();
  }

  async initialise() {
    try {
      await this.initialiseConfig();
    } catch (error) {
      console.error("GenericButtonHandler Error:", error.message);
    }
  }

  async initialiseConfig() {
    const configName = this.resolvedConfigName;
    if (configName) {
      const result = await getConfig({ configName: configName });
      this.cardConfig = JSON.parse(result);
      this.showButton(this.cardConfig);
      return;
    }

    throw new Error(`No configuration found: configName="${configName}"`);
  }

  async showButton(cardConfig) {
    if (
      cardConfig.button !== null &&
      cardConfig.button.roles.includes(this.userRole)
    ) {
      const ctor = await import(`c/${cardConfig.button.component}`);
      this.componentConstructor = ctor.default;
    }
  }

  @wire(getRecord, { recordId: Id, fields: [RoleName] })
  userDetails({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      if (data.fields.UserRole.value != null) {
        this._userRole = data.fields.UserRole.value.fields.Name.value;
      }
    }
  }
}
