import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcDetailPanel from "./../pageObjects/lwcDetailPanel";

async function _utam_get_detailPanel(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-lwc-detail-panel`);
  return _element.findElement(_locator);
}

export default class Tab2 extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailPanel(driver, root);
    element = new _LwcDetailPanel(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
