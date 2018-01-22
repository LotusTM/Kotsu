/* global Element, DOMTokenList, NodeList */

// This is sad file where tortured souls dwells

// Polyfill `Element.matches` for older browsers, including IE11 and lower
// @source https://developer.mozilla.org/en/docs/Web/API/Element/matches
if (!Element.prototype.matches) {
  Element.prototype.matches =
    Element.prototype.matchesSelector ||
    Element.prototype.mozMatchesSelector ||
    Element.prototype.msMatchesSelector ||
    Element.prototype.oMatchesSelector ||
    Element.prototype.webkitMatchesSelector ||
    function (s) {
      const matches = (this.document || this.ownerDocument).querySelectorAll(s)
      let i = matches.length

      while (--i >= 0 && matches.item(i) !== this) {}
      return i > -1
    }
}

// Polyfill `Element.closest` for IE9+
// @source https://developer.mozilla.org/en-US/docs/Web/API/Element/closest
if (!Element.prototype.closest) {
  Element.prototype.closest = function (s) {
    var el = this
    if (!document.documentElement.contains(el)) return null
    do {
      if (el.matches(s)) return el
      el = el.parentElement || el.parentNode
    } while (el !== null)
    return null
  }
}

// Polyfill Element.classList for IE9 and add missing features in IE10
// @source https://developer.mozilla.org/en/docs/Web/API/Element/classList
;(function () {
  // helpers
  var regExp = function (name) {
    return new RegExp('(^| )' + name + '( |$)')
  }
  var forEach = function (list, fn, scope) {
    for (var i = 0; i < list.length; i++) {
      fn.call(scope, list[i])
    }
  }

  // class list object with basic methods
  function ClassList (element) {
    this.element = element
  }

  ClassList.prototype = {
    add: function () {
      forEach(arguments, function (name) {
        if (!this.contains(name)) {
          this.element.className += this.element.className.length > 0 ? ' ' + name : name
        }
      }, this)
    },
    remove: function () {
      forEach(arguments, function (name) {
        this.element.className = this.element.className.replace(regExp(name), ' ')
      }, this)
    },
    toggle: function (name) {
      return this.contains(name) ? (this.remove(name), false) : (this.add(name), true)
    },
    contains: function (name) {
      return regExp(name).test(this.element.className)
    },
    // bonus..
    replace: function (oldName, newName) {
      this.remove(oldName)
      this.add(newName)
    }
  }

  // IE8/9, Safari
  if (!('classList' in Element.prototype)) {
    Object.defineProperty(Element.prototype, 'classList', {
      get: function () {
        return new ClassList(this)
      }
    })
  }

  // replace() support for others
  if (window.DOMTokenList && DOMTokenList.prototype.replace == null) {
    DOMTokenList.prototype.replace = ClassList.prototype.replace
  }
})()

// Polyfill not iterable NodeList in older browsers
if (!NodeList.prototype.forEach) {
  NodeList.prototype.forEach = Array.prototype.forEach
}
