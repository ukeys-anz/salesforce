import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_rowCell(driver, root, cellIndex) {
  let _element = root;
  const _locator = _By.css(`td:nth-of-type(${cellIndex})`);
  return _element.findElement(_locator);
}

async function _utam_get_rowHeader(driver, root) {
  let _element = root;
  const _locator = _By.css(`th`);
  return _element.findElement(_locator);
}

async function _utam_get_rowHeaderLink(driver, root) {
  let _element = await _utam_get_rowHeader(driver, root);
  const _locator = _By.css(`a`);
  return _element.findElement(_locator);
}

export default class ListViewRow extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getRowCell(cellIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_rowCell(driver, root, cellIndex);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRowHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_rowHeader(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRowHeaderLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_rowHeaderLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getContentByRowCellIndex(cellIndex) {
    const _statement0 = await this.__getRowCell(cellIndex);
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getRowHeaderContent() {
    const _statement0 = await this.__getRowHeader();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async clickRowHeader() {
    const _statement0 = await this.__getRowHeaderLink();
    await _statement0.click();
  }
}
