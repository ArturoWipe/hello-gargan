# CSS Integration Model

## CSS model standard

* Reserve CSS Gridbox stricly for two dimensional layout cases and non dynamic layouts
> **Why?** As stated in this [article](https://hackernoon.com/the-ultimate-css-battle-grid-vs-flexbox-d40da0449faf) by Per Harald Borgen, CSS Gridbox are layout-first. Meaning that the grid determines the items placement and position. Whereas CSS Flexbox are content-first, meaning that the items can decide how they are placed.

_These guides made by the CSS-Tricks team are the most complete about [CSS Flexbox](https://css-tricks.com/snippets/css/a-guide-to-flexbox/) and [CSS Gridbox](https://css-tricks.com/snippets/css/complete-guide-grid/)_

* Use the box model `margin` property only if you have mastered it
> **Why?** `margin` use is prone to a phenomenom called margin collapse. Lack of knowledge on this particular subject leads to unwanted side effects. Please read these two articles from the [MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Box_Model/Mastering_margin_collapsing) and [Pineco](https://pineco.de/revisiting-margin-collapse/) teams for detailed explanations.

_In a nutshell, we differenciate three skill levels:_
1. _as noted by [Chris Coyier](https://css-tricks.com/good-ol-margin-collapsing/), `margin` is best leave out_
2. _as written by [Harry Roberts](https://csswizardry.com/2012/06/single-direction-margin-declarations/), the ideal use is to restrict the `margin` to single-direction declarations_
3. _as claimed by [Hugo Giraudel](https://twitter.com/HugoGiraudel/status/938342359930163200), when fully mastered, `margin` makes layouting elements much less frustrating_

* Every elements are set to `box-sizing: border-box`
> **Why?** Even if `border-box` is not the default `box-sizing` value, it feels more natural and is advocated for years by the community to be the CSS standard (eg. by [Paul Irish](https://www.paulirish.com/2012/box-sizing-border-box-ftw/) from the Google Chrome core team, or [Chris Coyier](https://css-tricks.com/international-box-sizing-awareness-day/) from the CSS-Tricks team).

* Stick to the `px` unit for every standard lengths, instead of relative units (`em`, `rem`)
> **Why?** Our minds are trained in pixels when it comes to user interfaces, relative units are counter-intuitive by essence. The thorough analyze of Gion Kunz in this [article](https://mindtheshift.wordpress.com/2015/04/02/r-i-p-rem-viva-css-reference-pixel/) relates all the flaws with `rem` and `em`, and should only be used for few specific use cases.

### Useful resources
  * [Understanding CSS z-index](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Positioning/Understanding_z_index) _how stacking elements (w/ or w/o z-index) and stacking contexts work_

## SASS guidelines

* Our guidelines mostly follows the model [proposed](https://sass-guidelin.es) by Hugo Giraudel.
> **Why?** At this day these SASS guidelines are the most structured and popular one. The opinionated key principles and convention picked out by the author, such as the BEM naming, are purely empirical and respect our own conceived ideas. Main difference here, is that we have strictly opposed a *main* and *bootstrap* folders. The reason is that Bootstrap (even the recent v5) is still not compliant with (SASS Modules API)[https://css-tricks.com/introducing-sass-modules/] (which will deprecates the old `@import` API in October 2022)

* We also select the Eduardo Bouca's [approach](https://css-tricks.com/approaches-media-queries-sass/#article-header-id-5) (from the CSS-Tricks team) for media queries specifications
> **Why?** Even it complexifies a little bit media querie declarations, it provides a clear syntax capable of simply dealing with specific screen resolution (eg. "retina" or "x2" screens)

### Useful resources
  * [BEM 101](https://css-tricks.com/bem-101/) _details explanation about the BEM naming convention_
  * [Battling BEM CSS](https://www.smashingmagazine.com/2016/06/battling-bem-extended-edition-common-problems-and-how-to-avoid-them/) _10 common problems and how to avoid them_
  * [Using Sass to control scope with BEM naming](https://css-tricks.com/using-sass-control-scope-bem-naming/) _importance of `$self` operator_
  * [Incomplete List of Mistakes in the Design of CSS](https://wiki.csswg.org/ideas/mistakes) _a list of infuriating details regarding CSS design decisions_
