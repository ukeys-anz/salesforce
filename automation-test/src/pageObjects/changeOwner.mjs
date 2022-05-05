import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_changeOwnerButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button-icon.change-owner-trigger`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class ChangeOwner extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getChangeOwnerButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_changeOwnerButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async clickButton() {
    const _statement0 = await this.getChangeOwnerButton();
    await _statement0.click();
  }
}
