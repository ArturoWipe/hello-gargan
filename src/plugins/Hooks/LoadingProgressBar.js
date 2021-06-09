'use strict';
/**
 * @name showTopbar
 * @return
 */
exports.showTopbar = function() {
  window.topbar.show();
}
/**
 * @name hideTopbar
 * @return
 */
exports.hideTopbar = function() {
  window.topbar.hide();
}
/**
 * @name configTopbar
 * @param {object} params
 * @param {object.string} className
 * @param {object.number} thickness
 * @param {object.string} color
 * @param {object.*} boxShadow
 *    <object.value0: undefined>
 *    <object.value0: string>
 * @return
 */
exports.configTopbar = function(params) {
  return function() {
    window.topbar.config({
      autoRun: true,
      barThickness: params.thickness,
      barColors: {
        '0': params.color
      },
      shadowBlur: params.boxShadow.value0 ?
        4 :
        0,
      shadowColor: params.boxShadow.value0 ?
        params.boxShadow.value0 :
        'none',
      className: params.className,
    });
  };
}
