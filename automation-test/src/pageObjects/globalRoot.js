"use strict";

var core = require("@utam/core");

async function _utam_get_knowledgeApprovalHistoryDropDownApprove(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.branding-actions.forceActionsDropDownMenuList li:nth-of-type(1) a`
  );
  return _element.findElement(_locator);
}

class GlobalRoot extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getKnowledgeApprovalHistoryDropDownApprove() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_knowledgeApprovalHistoryDropDownApprove(
      driver,
      root
    );
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async approveArticle() {
    const _statement0 =
      await this.__getKnowledgeApprovalHistoryDropDownApprove();
    await _statement0.click();
  }
}

module.exports = GlobalRoot;
