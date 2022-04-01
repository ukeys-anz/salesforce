import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutEventBroker from "./../pageObjects/recordLayoutEventBroker";
import _LwcDetailPanel from "./../pageObjects/lwcDetailPanel";

async function _utam_get_eventBroker(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-record-layout-event-broker`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lwcDetailPanel(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-lwc-detail-panel`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class ModalLwcDetailPanelWrapper extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getEventBroker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_eventBroker(driver, root);
    element = new _RecordLayoutEventBroker(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getLwcDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lwcDetailPanel(driver, root);
    element = new _LwcDetailPanel(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
