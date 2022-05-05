"use strict";

var core = require("@utam/core");
var _BaseRecordForm = require("./../pageObjects/baseRecordForm");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BaseRecordForm__default =
  /*#__PURE__*/ _interopDefaultLegacy(_BaseRecordForm);

async function _utam_get_modalDetailPanelWrapper(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-modal-lwc-detail-panel-wrapper`);
  return _element.findElement(_locator);
}

async function _utam_get_modalDetailPanel(driver, root) {
  let _element = await _utam_get_modalDetailPanelWrapper(driver, root);
  const _locator = core.By.css(`records-lwc-detail-panel`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_modalBaseRecordForm(driver, root) {
  let _element = await _utam_get_modalDetailPanel(driver, root);
  const _locator = core.By.css(`records-base-record-form`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_relatedListDetailPanelWrapper(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-related-list-lwc-detail-panel-wrapper`);
  return _element.findElement(_locator);
}

async function _utam_get_relatedListDetailPanel(driver, root) {
  let _element = await _utam_get_relatedListDetailPanelWrapper(driver, root);
  const _locator = core.By.css(`records-lwc-detail-panel`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_relatedListBaseRecordForm(driver, root) {
  let _element = await _utam_get_relatedListDetailPanel(driver, root);
  const _locator = core.By.css(`records-base-record-form`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcRecordCreationForm extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`.active.lafPageHost`)) {
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

  async __getModalDetailPanelWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalDetailPanelWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getModalDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalDetailPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getModalBaseRecordForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_modalBaseRecordForm(driver, root);
    element = new _BaseRecordForm__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getRelatedListDetailPanelWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_relatedListDetailPanelWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRelatedListDetailPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_relatedListDetailPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRelatedListBaseRecordForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_relatedListBaseRecordForm(driver, root);
    element = new _BaseRecordForm__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = LwcRecordCreationForm;
