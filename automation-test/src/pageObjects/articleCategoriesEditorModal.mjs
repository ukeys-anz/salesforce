import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

async function _utam_get_knowledgeMultiSelectTable(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceKnowledgeMultiSelectTable`);
  return _element.findElement(_locator);
}

async function _utam_get_tableBody(driver, root) {
  let _element = await _utam_get_knowledgeMultiSelectTable(driver, root);
  const _locator = _By.css(`tbody`);
  return _element.findElement(_locator);
}

async function _utam_get_firstOption(driver, root) {
  let _element = await _utam_get_tableBody(driver, root);
  const _locator = _By.css(`tr:nth-of-type(1)`);
  return _element.findElement(_locator);
}

async function _utam_get_firstOptionSelector(driver, root) {
  let _element = await _utam_get_firstOption(driver, root);
  const _locator = _By.css(`input[type='checkbox']`);
  return _element.findElement(_locator);
}

async function _utam_get_modalFooter(driver, root) {
  let _element = root;
  const _locator = _By.css(`.slds-modal__footer`);
  return _element.findElement(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = _By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

export default class ArticleCategoriesEditorModal extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getKnowledgeMultiSelectTable() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_knowledgeMultiSelectTable(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTableBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_tableBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFirstOption() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_firstOption(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFirstOptionSelector() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_firstOptionSelector(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getModalFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalFooter(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_saveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async selectFirstCategory() {
    const _statement0 = await this.__getFirstOptionSelector();
    await _statement0.click();
    const _statement1 = await this.__getSaveButton();
    await _statement1.click();
  }
}
