"use strict";

var core = require("@utam/core");
var _KnowledgeRecordPage = require("./../pageObjects/knowledgeRecordPage");
var _CaseRecordPage = require("./../pageObjects/caseRecordPage");
var _AccountRecordPage = require("./../pageObjects/accountRecordPage");
var _FinancialAccountRecordPage = require("./../pageObjects/financialAccountRecordPage");
var _QualityAssessmentRecordPage = require("./../pageObjects/qualityAssessmentRecordPage");
var _RecordPageDecorator = require("./../pageObjects/recordPageDecorator");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _KnowledgeRecordPage__default =
  /*#__PURE__*/ _interopDefaultLegacy(_KnowledgeRecordPage);
var _CaseRecordPage__default =
  /*#__PURE__*/ _interopDefaultLegacy(_CaseRecordPage);
var _AccountRecordPage__default =
  /*#__PURE__*/ _interopDefaultLegacy(_AccountRecordPage);
var _FinancialAccountRecordPage__default = /*#__PURE__*/ _interopDefaultLegacy(
  _FinancialAccountRecordPage
);
var _QualityAssessmentRecordPage__default = /*#__PURE__*/ _interopDefaultLegacy(
  _QualityAssessmentRecordPage
);
var _RecordPageDecorator__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordPageDecorator);

async function _utam_get_oneRecordHomeFlexipage2(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.active.lafPageHost one-record-home-flexipage2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_adgRollup(driver, root) {
  let _element = await _utam_get_oneRecordHomeFlexipage2(driver, root);
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

async function _utam_get_knowledgeFlexipage(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.active.lafPageHost .flexipagePage`);
  return _element.findElement(_locator);
}

class RecordPage extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    return _result0;
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getOneRecordHomeFlexipage2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_oneRecordHomeFlexipage2(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
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

  async __getKnowledgeFlexipage() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_knowledgeFlexipage(driver, root);
    element = new _KnowledgeRecordPage__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getRecordLayoutBroker() {
    const _statement0 = await this.getDecorator();
    const _result1 = await _statement0.getEventBroker();
    return _result1;
  }

  async getCaseRecordPage() {
    const _statement0 = await this.getRecordLayoutBroker();
    const _result1 = await _statement0.getGeneratedTemplate(
      _CaseRecordPage__default["default"]
    );
    return _result1;
  }

  async getAccountRecordPage() {
    const _statement0 = await this.getRecordLayoutBroker();
    const _result1 = await _statement0.getGeneratedTemplate(
      _AccountRecordPage__default["default"]
    );
    return _result1;
  }

  async getFinancialAccountRecordPage() {
    const _statement0 = await this.getRecordLayoutBroker();
    const _result1 = await _statement0.getGeneratedTemplate(
      _FinancialAccountRecordPage__default["default"]
    );
    return _result1;
  }

  async getQualityAssessmentRecordPage() {
    const _statement0 = await this.getRecordLayoutBroker();
    const _result1 = await _statement0.getGeneratedTemplate(
      _QualityAssessmentRecordPage__default["default"]
    );
    return _result1;
  }

  async getKnowledgeRecordPage() {
    const _result0 = await this.__getKnowledgeFlexipage();
    return _result0;
  }
}

module.exports = RecordPage;
