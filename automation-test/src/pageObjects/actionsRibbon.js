"use strict";

var core = require("@utam/core");
var _ActionRenderer = require("./../pageObjects/actionRenderer");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ActionRenderer__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ActionRenderer);

async function _utam_get_actionRendererWithTitle(driver, root, titleString) {
  let _element = root;
  const _locator = core.By.css(
    `runtime_platform_actions-action-renderer[title='${titleString}']`
  );
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class ActionsRibbon extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
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
    element = new _ActionRenderer__default["default"](driver, element);
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

module.exports = ActionsRibbon;
