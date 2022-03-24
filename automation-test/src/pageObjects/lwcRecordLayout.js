"use strict";

var core = require("@utam/core");
var _Highlights2 = require("./../pageObjects/highlights2");
var _RecordLayoutSection = require("./../pageObjects/recordLayoutSection");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Highlights2__default = /*#__PURE__*/ _interopDefaultLegacy(_Highlights2);
var _RecordLayoutSection__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordLayoutSection
);

async function _utam_get_forcegeneratedRecordLayout2(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forcegenerated-record-layout2`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_generatedContent(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = core.By.css(`:scope > *:first-child`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_generatedContentLists(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = core.By.css(`:scope > *`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_highlights2(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = core.By.css(`records-highlights2`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_sectionss(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = core.By.css(`records-record-layout-section`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_section(driver, root, indexStartingOne) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = core.By.css(
    `records-record-layout-section:nth-of-type(${indexStartingOne})`
  );
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcRecordLayout extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getForcegeneratedRecordLayout2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getGeneratedContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_generatedContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getGeneratedContentList(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_generatedContentLists(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ContainerCtor(driver, element);
    });
    return elements;
  }

  async getHighlights2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_highlights2(driver, root);
    element = new _Highlights2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSections() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_sectionss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _RecordLayoutSection__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getSection(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_section(driver, root, indexStartingOne);
    element = new _RecordLayoutSection__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getItem(indexStartingOne, rowIndex, itemIndex) {
    const _statement0 = await this.waitFor(async () => {
      const _result0 = await this.getSection(indexStartingOne);
      return _result0;
    });
    const _statement1 = await _statement0.getRow(rowIndex);
    const _result2 = await _statement1.getItem(itemIndex);
    return _result2;
  }

  async waitForHighlights2() {
    const _result0 = await this.waitFor(async () => {
      const _result0 = await this.getHighlights2();
      return _result0;
    });
    return _result0;
  }
}

module.exports = LwcRecordLayout;
