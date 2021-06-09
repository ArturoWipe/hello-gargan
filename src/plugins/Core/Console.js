"use strict";
/**
 * Get Creation Date
 * @return {string}
 */
exports.getCreationDate = function() {
  return new Date().toLocaleTimeString()
}
/**
 * Bullet CSS
 * @type {string}
 */
exports.bulletCSS = 'color: %s; padding: 4px 5px; font-weight: bold;'
/**
 * Callee CSS
 * @type {string}
 */
exports.calleeCSS = 'color: #FFFFFF; background: %s; padding: 4px 5px; font-size: 10px;'
/**
 * Creation Date CSS
 * @type {string}
 */
exports.creationDateCSS = 'font-size: 9px; padding: 4px 5px;'
