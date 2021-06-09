'use strict';
/**
 * Create Toast Wrapper for each call made to show a Toast
 * @param {string} randomId
 * @returns
 */
exports.createToastWrapper = function(randomId) {
  return function() {
    var container = document.querySelector('#toast-container');
    var wrapper = document.createElement('div');

    wrapper.id = randomId;

    container.appendChild(wrapper);
  }
}
/**
 * Generate random ID for future Toast Wrapper
 * @returns {string}
 */
exports.generateRandomId = function() {
  return 'toast-wrapper-' + (new Date() * 1);
}
/**
 * Programmaticaly show a Bootstrap Toast
 * Remove itself from the DOM when closed
 * @returns
 */
exports.showToast = function() {
  $('#toast-container div:last-child .toast')
    .toast('show')
    .on('hidden.bs.toast', function() {
      var container = this.parentNode;

      container.parentNode.removeChild(container);
    });
}
