"use strict";

var core = require("@utam/core");
var _RecordHomeTemplateDesktop2 = require("./../pageObjects/recordHomeTemplateDesktop2");
var _RecordPageDecorator = require("./../pageObjects/recordPageDecorator");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordHomeTemplateDesktop2__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordHomeTemplateDesktop2
);
var _RecordPageDecorator__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordPageDecorator);

async function _utam_get_adgRollup(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.adg-rollup-wrapped`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_flexipageModule(driver, root) {
  let _element = await _utam_get_adgRollup(driver, root);
  const _locator = core.By.css(`.forcegenerated-flexipage-module`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_decorator(driver, root) {
  let _element = await _utam_get_flexipageModule(driver, root);
  const _locator = core.By.css(`record_flexipage-record-page-decorator`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class CoachesWorkbenchFinancialAccountRecordHomeFlexipage extends core.UtamBaseRootPageObject {
  constructor(
    driver,
    element,
    locator = core.By.css(
      `section[class='tabContent active oneConsoleTab'] section[class='tabContent active oneConsoleTab'] one-record-home-flexipage2`
    )
  ) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getAdgRollup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_adgRollup(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFlexipageModule() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_flexipageModule(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDecorator() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_decorator(driver, root);
    element = new _RecordPageDecorator__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFinancialAccountRecordPage() {
    const _statement0 = await this.getDecorator();
    const _statement1 = await _statement0.getEventBroker();
    const _result2 = await _statement1.getGeneratedTemplate(
      _RecordHomeTemplateDesktop2__default["default"]
    );
    return _result2;
  }

  async getFinancialAccountTabset() {
    const _statement0 = await this.getFinancialAccountRecordPage();
    const _statement1 = await _statement0.getTabset2();
    const _result2 = await _statement1.getTabset();
    return _result2;
  }
}

module.exports = CoachesWorkbenchFinancialAccountRecordHomeFlexipage;
