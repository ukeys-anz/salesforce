({
  doInit: function (cmp, event, helper) {
    var currentPageRef = cmp.get("v.pageReference");
    var URLname =
      currentPageRef && currentPageRef.state
        ? currentPageRef.state.c__vizUrlValue
        : "";
    cmp.set("v.vizUrlValue", URLname);
  },
  handlePageChange: function (cmp, evt, hlp) {
    var currentPageRef = cmp.get("v.pageReference");
    var URLname =
      currentPageRef && currentPageRef.state
        ? currentPageRef.state.c__vizUrlValue
        : "";
    cmp.set("v.vizUrlValue", URLname);
  }
});
