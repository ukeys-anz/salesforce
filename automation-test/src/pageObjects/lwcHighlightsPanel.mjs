import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcRecordLayout from "./../pageObjects/lwcRecordLayout";

async function _utam_get_recordLayout(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-lwc-record-layout`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcHighlightsPanel extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getRecordLayout() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_recordLayout(driver, root);
    element = new _LwcRecordLayout(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActions() {
    const _statement0 = await this.waitFor(async () => {
      const _result0 = await this.getRecordLayout();
      return _result0;
    });
    const _statement1 = await _statement0.waitForHighlights2();
    const _result2 = await _statement1.getActionsRibbon();
    return _result2;
  }
}
