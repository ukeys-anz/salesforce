import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_modal(driver, root) {
  let _element = root;
  const _locator = _By.css(`.uiContainerManager`);
  return _element.findElement(_locator);
}

async function _utam_get_deleteButton(driver, root) {
  let _element = await _utam_get_modal(driver, root);
  const _locator = _By.css(`[title='Delete']`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_modalDetail(driver, root) {
  let _element = await _utam_get_modal(driver, root);
  const _locator = _By.css(`.detail`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

export default class RootPageModal extends _UtamBaseRootPageObject {
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

  async __getModal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modal(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDeleteButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_deleteButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getModalDetail() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalDetail(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async userHasNoPermissionToDeleteChatterPost() {
    const _statement0 = await this.getDeleteButton();
    if (_statement0 === null) {
      return null;
    }
    await _statement0.click();
    await this.waitFor(async () => {
      const _statement0 = await this.getModalDetail();
      if (_statement0 === null) {
        return null;
      }
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    const _statement2 = await this.getModalDetail();
    if (_statement2 === null) {
      return null;
    }
    const _result2 = await _statement2.getText();
    const _matcher2 =
      _result2 === "You do not have permission to delete this comment";
    return _matcher2;
  }
}
