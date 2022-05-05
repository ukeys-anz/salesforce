import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  EditableUtamElement as _EditableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AlohaPage from "./../pageObjects/alohaPage";

async function _utam_get_label(driver, root) {
  let _element = root;
  const _locator = _By.css(`.label span:nth-child(1)`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_readOnlylabel(driver, root) {
  let _element = root;
  const _locator = _By.css(`.slds-form-element__label`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_picklist(driver, root) {
  let _element = root;
  const _locator = _By.css(`a[role='button']`);
  return _element.findElement(_locator);
}

async function _utam_get_number(driver, root) {
  let _element = root;
  const _locator = _By.css(`input[class*='uiInputSmartNumber']`);
  return _element.findElement(_locator);
}

async function _utam_get_text(driver, root) {
  let _element = root;
  const _locator = _By.css(`input[type='text']`);
  return _element.findElement(_locator);
}

async function _utam_get_textarea(driver, root) {
  let _element = root;
  const _locator = _By.css(`textarea[role='textbox']`);
  return _element.findElement(_locator);
}

async function _utam_get_lookup(driver, root) {
  let _element = root;
  const _locator = _By.css(`input[role='combobox']`);
  return _element.findElement(_locator);
}

async function _utam_get_itemBody(driver, root) {
  let _element = root;
  const _locator = _By.css(`.itemBody`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_editButton(driver, root) {
  let _element = await _utam_get_itemBody(driver, root);
  if (!_element) {
    return null;
  }
  const _locator = _By.css(`.editButton`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_bodyIframe(driver, root) {
  let _element = await _utam_get_itemBody(driver, root);
  if (!_element) {
    return null;
  }
  const _locator = _By.css(`force-aloha-page`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_lookupResult(driver, root) {
  let _element = root;
  const _locator = _By.css(`.listContent li a`);
  return _element.findElement(_locator);
}

async function _utam_get_lookupResultByTitle(driver, root, resultTile) {
  let _element = root;
  const _locator = _By.css(
    `.listContent li a div[class*='primaryLabel'][title='${resultTile}']`
  );
  return _element.findElement(_locator);
}

export default class RecordCreationFormField extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLabel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_label(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getReadOnlylabel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_readOnlylabel(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getPicklist() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_picklist(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getNumber() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_number(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getText() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_text(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getTextarea() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_textarea(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getLookup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = _createUtamMixinCtor(
      _ClickableUtamElement,
      _EditableUtamElement
    );
    let element = await _utam_get_lookup(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getItemBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_itemBody(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getEditButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_editButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getBodyIframe() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_bodyIframe(driver, root);
    if (!element) {
      return null;
    }
    element = new _AlohaPage(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getLookupResult() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_lookupResult(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getLookupResultByTitle(resultTile) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_lookupResultByTitle(driver, root, resultTile);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getLabel() {
    const _statement0 = await this.__getLabel();
    if (_statement0 === null) {
      return null;
    }
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getReadOnlyLabel() {
    const _statement0 = await this.__getReadOnlylabel();
    if (_statement0 === null) {
      return null;
    }
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async expandPicklist() {
    const _statement0 = await this.__getPicklist();
    await _statement0.click();
  }

  async editNumber(numberStr) {
    const _statement0 = await this.__getNumber();
    await _statement0.clearAndType(numberStr);
  }

  async editText(text) {
    const _statement0 = await this.__getText();
    await _statement0.clearAndType(text);
  }

  async editTextarea(text) {
    const _statement0 = await this.__getTextarea();
    await _statement0.clearAndType(text);
  }

  async clickLookup() {
    const _statement0 = await this.__getLookup();
    await _statement0.click();
  }

  async searchLookup(searchTerm) {
    const _statement0 = await this.__getLookup();
    await _statement0.clearAndType(searchTerm);
  }

  async selectLookupResult() {
    const _statement0 = await this.__getLookupResult();
    await _statement0.click();
  }

  async selectLookupResultByTitle(resultTile) {
    const _statement0 = await this.__getLookupResultByTitle(resultTile);
    await _statement0.click();
  }

  async editBody() {
    const _statement0 = await this.__getEditButton();
    if (_statement0 === null) {
      return null;
    }
    await _statement0.click();
  }
}
