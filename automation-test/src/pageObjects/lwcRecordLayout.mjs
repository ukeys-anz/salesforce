import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Highlights2 from "./../pageObjects/highlights2";
import _RecordLayoutSection from "./../pageObjects/recordLayoutSection";

async function _utam_get_forcegeneratedRecordLayout2(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forcegenerated-record-layout2`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_generatedContent(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = _By.css(`:scope > *:first-child`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_generatedContentLists(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = _By.css(`:scope > *`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_highlights2(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = _By.css(`records-highlights2`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_sectionss(driver, root) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = _By.css(`records-record-layout-section`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_section(driver, root, indexStartingOne) {
  let _element = await _utam_get_forcegeneratedRecordLayout2(driver, root);
  const _locator = _By.css(
    `records-record-layout-section:nth-of-type(${indexStartingOne})`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcRecordLayout extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getForcegeneratedRecordLayout2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
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
    element = new _Highlights2(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSections() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_sectionss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _RecordLayoutSection(driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getSection(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_section(driver, root, indexStartingOne);
    element = new _RecordLayoutSection(driver, element);
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
