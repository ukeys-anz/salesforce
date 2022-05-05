import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  EditableUtamElement as _EditableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

async function _utam_get_modalHeader(driver, root) {
  let _element = root;
  const _locator = _By.css(`.modal-header`);
  return _element.findElement(_locator);
}

async function _utam_get_modalBody(driver, root) {
  let _element = root;
  const _locator = _By.css(`.modal-body`);
  return _element.findElement(_locator);
}

async function _utam_get_ownerMenuButton(driver, root) {
  let _element = await _utam_get_modalBody(driver, root);
  const _locator = _By.css(`a.entityMenuTrigger`);
  return _element.findElement(_locator);
}

async function _utam_get_searchBox(driver, root) {
  let _element = await _utam_get_modalBody(driver, root);
  const _locator = _By.css(`input[title*='Search']`);
  return _element.findElement(_locator);
}

async function _utam_get_searchResult(driver, root, resultTitle) {
  let _element = await _utam_get_modalBody(driver, root);
  const _locator = _By.css(`.listContent li a div[title='${resultTitle}']`);
  return _element.findElement(_locator);
}

async function _utam_get_modalFooter(driver, root) {
  let _element = root;
  const _locator = _By.css(`.modal-footer`);
  return _element.findElement(_locator);
}

async function _utam_get_changeOwnerButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = _By.css(`button[name='change owner']`);
  return _element.findElement(_locator);
}

async function _utam_get_ownerMenuList(driver, root) {
  let _element = root;
  const _locator = _By.css(`div.entityMenuList`);
  return _element.findElement(_locator);
}

async function _utam_get_ownerType(driver, root, ownerType) {
  let _element = await _utam_get_ownerMenuList(driver, root);
  const _locator = _By.css(`a[title='${ownerType}']`);
  return _element.findElement(_locator);
}

export default class ChangeOwnerModal extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
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
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getModalHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalHeader(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getModalBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getOwnerMenuButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_ownerMenuButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getSearchBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = _createUtamMixinCtor(
      _ClickableUtamElement,
      _EditableUtamElement
    );
    let element = await _utam_get_searchBox(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getSearchResult(resultTitle) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_searchResult(driver, root, resultTitle);
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

  async getChangeOwnerButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_changeOwnerButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getOwnerMenuList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_ownerMenuList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getOwnerType(ownerType) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_ownerType(driver, root, ownerType);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async clickOwnerTypeDropDown() {
    const _statement0 = await this.__getOwnerMenuButton();
    await _statement0.click();
  }

  async selectOwnerType(ownerType) {
    const _statement0 = await this.getOwnerType(ownerType);
    await _statement0.click();
  }

  async clickSearchBox() {
    const _statement0 = await this.__getSearchBox();
    await _statement0.click();
  }

  async search(username) {
    const _statement0 = await this.__getSearchBox();
    await _statement0.clearAndType(username);
  }

  async selectUser(resultTitle) {
    const _statement0 = await this.__getSearchResult(resultTitle);
    await _statement0.click();
  }

  async save() {
    const _statement0 = await this.getChangeOwnerButton();
    await _statement0.click();
  }
}
