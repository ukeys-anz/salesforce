import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialAccountParent from "./../pageObjects/lwcFinancialAccountParent";

async function _utam_get_financialAccountParent(driver, root) {
  let _element = root;
  const _locator = _By.css(`c-financial-account-parent`);
  return _element.findElement(_locator);
}

export default class FinancialAccountTab extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFinancialAccountParent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialAccountParent(driver, root);
    element = new _LwcFinancialAccountParent(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
