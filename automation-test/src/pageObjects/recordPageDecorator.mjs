import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordHomeTemplateDesktop2 from "./../pageObjects/recordHomeTemplateDesktop2";
import _RecordLayoutEventBroker from "./../pageObjects/recordLayoutEventBroker";

async function _utam_get_templateDesktop2(driver, root) {
  let _element = root;
  const _locator = _By.css(`flexipage-record-home-template-desktop2`);
  return _element.findElement(_locator);
}

async function _utam_get_eventBroker(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-record-layout-event-broker`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class RecordPageDecorator extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTemplateDesktop2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_templateDesktop2(driver, root);
    element = new _RecordHomeTemplateDesktop2(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getEventBroker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_eventBroker(driver, root);
    element = new _RecordLayoutEventBroker(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
