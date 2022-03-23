"use strict";

var core = require("@utam/core");
var _RecordLayoutEventBroker = require("./../pageObjects/recordLayoutEventBroker");
var _LwcDetailPanel = require("./../pageObjects/lwcDetailPanel");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordLayoutEventBroker__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordLayoutEventBroker
);
var _LwcDetailPanel__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcDetailPanel
);

async function _utam_get_eventBroker(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-record-layout-event-broker`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lwcDetailPanel(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-lwc-detail-panel`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class ModalLwcDetailPanelWrapper extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getEventBroker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_eventBroker(driver, root);
    element = new _RecordLayoutEventBroker__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getLwcDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lwcDetailPanel(driver, root);
    element = new _LwcDetailPanel__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = ModalLwcDetailPanelWrapper;
