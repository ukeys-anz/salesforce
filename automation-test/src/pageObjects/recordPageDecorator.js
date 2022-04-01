"use strict";

var core = require("@utam/core");
var _RecordHomeTemplateDesktop2 = require("./../pageObjects/recordHomeTemplateDesktop2");
var _RecordLayoutEventBroker = require("./../pageObjects/recordLayoutEventBroker");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordHomeTemplateDesktop2__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordHomeTemplateDesktop2
);
var _RecordLayoutEventBroker__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordLayoutEventBroker
);

async function _utam_get_templateDesktop2(driver, root) {
  let _element = root;
  const _locator = core.By.css(`flexipage-record-home-template-desktop2`);
  return _element.findElement(_locator);
}

async function _utam_get_eventBroker(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-record-layout-event-broker`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class RecordPageDecorator extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTemplateDesktop2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_templateDesktop2(driver, root);
    element = new _RecordHomeTemplateDesktop2__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }

  async getEventBroker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_eventBroker(driver, root);
    element = new _RecordLayoutEventBroker__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = RecordPageDecorator;
