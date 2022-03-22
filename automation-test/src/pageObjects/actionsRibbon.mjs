import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionRenderer from "./../pageObjects/actionRenderer";

async function _utam_get_actionRendererWithTitle(driver, root, titleString) {
  let _element = root;
  const _locator = _By.css(
    `runtime_platform_actions-action-renderer[title='${titleString}']`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class ActionsRibbon extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getActionRendererWithTitle(titleString) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actionRendererWithTitle(
      driver,
      root,
      titleString
    );
    element = new _ActionRenderer(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async waitForRenderedAction(titleString) {
    const _result0 = await this.waitFor(async () => {
      const _result0 = await this.getActionRendererWithTitle(titleString);
      return _result0;
    });
    return _result0;
  }
}
