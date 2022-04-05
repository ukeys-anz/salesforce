"use strict";

var core = require("@utam/core");
var _CoachesWorkbenchAccountRecordHomeTemplateDesktop2 = require("./../pageObjects/coachesWorkbenchAccountRecordHomeTemplateDesktop2");
var _RecordPageDecorator = require("./../pageObjects/recordPageDecorator");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _CoachesWorkbenchAccountRecordHomeTemplateDesktop2__default =
  /*#__PURE__*/ _interopDefaultLegacy(
    _CoachesWorkbenchAccountRecordHomeTemplateDesktop2
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

class CoachesWorkbenchAccountRecordHomeFlexipage extends core.UtamBaseRootPageObject {
  constructor(
    driver,
    element,
    locator = core.By.css(`one-record-home-flexipage2`)
  ) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      await _statement0.isPresent();
      const _result1 = await _statement0.containsElement(
        core.By.css(`.adg-rollup-wrapped`),
        true
      );
      return _result1;
    });
    return _result0;
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

  async getRecordHomeTemplateDesktop2() {
    const _statement0 = await this.getDecorator();
    const _statement1 = await _statement0.getEventBroker();
    const _statement2 = await _statement1.waitForTemplate();
    const _result3 = await _statement2.getGeneratedTemplate(
      _CoachesWorkbenchAccountRecordHomeTemplateDesktop2__default["default"]
    );
    return _result3;
  }

  async getFinancialDetails() {
    const _statement0 = await this.getRecordHomeTemplateDesktop2();
    const _result1 = await _statement0.getFinancialDetails();
    return _result1;
  }

  async getChatterPanel() {
    const _statement0 = await this.getRecordHomeTemplateDesktop2();
    const _result1 = await _statement0.getChatterPanel();
    return _result1;
  }
}

module.exports = CoachesWorkbenchAccountRecordHomeFlexipage;
