import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_picklistItem(driver, root, picklistItemIndex) {
  let _element = root;
  const _locator = _By.css(
    `li[class='uiMenuItem uiRadioMenuItem']:nth-of-type(${picklistItemIndex})`
  );
  return _element.findElement(_locator);
}

export default class CoachesWorkbenchCaseCreationFormPicklist extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getPicklistItem(picklistItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_picklistItem(driver, root, picklistItemIndex);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async selectPicklistItem(picklistItemIndex) {
    await this.waitFor(async () => {
      const _result0 = await this.getPicklistItem(picklistItemIndex);
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement1 = await this.getPicklistItem(picklistItemIndex);
    await _statement1.click();
  }
}
