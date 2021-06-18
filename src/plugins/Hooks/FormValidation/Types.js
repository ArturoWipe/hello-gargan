'use strict';
/**
 *  Email Pattern
 *        - provide a custom pattern based on regexp for email validation [1]
 *        - regexp based on RFC 2822 simplified version (see FCT-68) [2]
 *  @link https://validatejs.org/#validators-email [1]
 *  @link https://gist.github.com/gregseth/5582254 [2]
 *  @type {RegExp}
 */
 exports.emailPattern = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;
