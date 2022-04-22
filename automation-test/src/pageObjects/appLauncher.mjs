import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement,
  EditableUtamElement as _EditableUtamElement
} from "@utam/core";

async function _utam_get_appLauncher(driver, root) {
  let _element = root;
  const _locator = _By.css(`div[class*='appLauncher'][role='navigation']`);
  return _element.findElement(_locator);
}

async function _utam_get_menu(driver, root) {
  let _element = root;
  const _locator = _By.css(`one-app-launcher-menu`);
  return _element.findElement(_locator);
}

async function _utam_get_searchBar(driver, root) {
  let _element = await _utam_get_menu(driver, root);
  const _locator = _By.css(`one-app-launcher-search-bar`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lightningInput(driver, root) {
  let _element = await _utam_get_searchBar(driver, root);
  const _locator = _By.css(`lightning-input`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_searchInput(driver, root) {
  let _element = await _utam_get_lightningInput(driver, root);
  const _locator = _By.css(`input`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_searchItem(driver, root) {
  let _element = await _utam_get_menu(driver, root);
  const _locator = _By.css(`one-app-launcher-menu-item`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_searchItemLink(driver, root) {
  let _element = await _utam_get_searchItem(driver, root);
  const _locator = _By.css(`a[role='option']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_currentApp(driver, root) {
  let _element = root;
  const _locator = _By.css(`.appName span`);
  return _element.findElement(_locator);
}

export default class AppLauncher extends _UtamBaseRootPageObject {
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

  async getAppLauncher() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_appLauncher(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getMenu() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_menu(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getSearchBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_searchBar(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLightningInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lightningInput(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getSearchInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_searchInput(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getSearchItem() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_searchItem(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getSearchItemLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_searchItemLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getCurrentApp() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_currentApp(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async isCurrentApp(appName) {
    const _statement0 = await this.getCurrentApp();
    const _result0 = await _statement0.getText();
    const _matcher0 = _result0 === appName;
    return _matcher0;
  }

  async redirectToApp(appName) {
    const _statement0 = await this.getAppLauncher();
    await _statement0.click();
    await this.waitFor(async () => {
      const _result0 = await this.getSearchInput();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement2 = await this.getSearchInput();
    await _statement2.clearAndType(appName);
    await this.waitFor(async () => {
      const _result0 = await this.getSearchItemLink();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement4 = await this.getSearchItemLink();
    await _statement4.click();
  }
}
