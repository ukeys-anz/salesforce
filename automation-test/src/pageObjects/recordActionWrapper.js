"use strict";

var core = require("@utam/core");
var _ChangeRecordTypeFooter = require("./../pageObjects/changeRecordTypeFooter");
var _ModalLwcDetailPanelWrapper = require("./../pageObjects/modalLwcDetailPanelWrapper");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ChangeRecordTypeFooter__default = /*#__PURE__*/ _interopDefaultLegacy(
  _ChangeRecordTypeFooter
);
var _ModalLwcDetailPanelWrapper__default = /*#__PURE__*/ _interopDefaultLegacy(
  _ModalLwcDetailPanelWrapper
);

async function _utam_get_body(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.actionBody`);
  return _element.findElement(_locator);
}

async function _utam_get_detailsPanelContainer(driver, root) {
  let _element = await _utam_get_body(driver, root);
  const _locator = core.By.css(`:scope > *:first-child`);
  return _element.findElement(_locator);
}

async function _utam_get_footer(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.inlineFooter`);
  return _element.findElement(_locator);
}

async function _utam_get_footerContent(driver, root) {
  let _element = await _utam_get_footer(driver, root);
  const _locator = core.By.css(`:scope > *:first-child`);
  return _element.findElement(_locator);
}

class RecordActionWrapper extends core.UtamBaseRootPageObject {
  constructor(
    driver,
    element,
    locator = core.By.css(`.oneRecordActionWrapper`)
  ) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.getRoot();
      await _statement0.isPresent();
      const _result1 = await _statement0.containsElement(
        core.By.css(`.actionBody`)
      );
      return _result1;
    });
    return _result0;
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_body(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDetailsPanelContainer(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailsPanelContainer(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async __getFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_footer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFooterContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_footerContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async waitForFooter() {
    const _result0 = await this.waitFor(async () => {
      const _result0 = await this.__getFooter();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    return _result0;
  }

  async waitForChangeRecordFooter() {
    const _result0 = await this.waitFor(async () => {
      await this.__getFooter();
      const _result1 = await this.getFooterContent(
        _ChangeRecordTypeFooter__default["default"]
      );
      return _result1;
    });
    return _result0;
  }

  async getRecordForm() {
    const _statement0 = await this.waitFor(async () => {
      const _result0 = await this.getDetailsPanelContainer(
        _ModalLwcDetailPanelWrapper__default["default"]
      );
      return _result0;
    });
    const _statement1 = await _statement0.getLwcDetailPanel();
    const _statement2 = await _statement1.getBaseRecordForm();
    const _result3 = await _statement2.waitForLoad();
    return _result3;
  }
}

module.exports = RecordActionWrapper;
