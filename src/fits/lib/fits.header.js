// Generated by CoffeeScript 1.3.3
(function() {
  var Header, Module, VerifyCards,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Module = require('./fits.module');

  VerifyCards = require('./fits.header.verify');

  Header = (function(_super) {

    __extends(Header, _super);

    Header.keywordPattern = /([\w_-]+)\s*=?\s*(.*)/;

    Header.nonStringPattern = /([^\/]*)\s*\/*(.*)/;

    Header.stringPattern = /'(.*)'\s*\/*(.*)/;

    Header.arrayPattern = /([A-Za-z]+)(\d+)/;

    Header.include(VerifyCards);

    function Header() {
      var method, name, _ref;
      this.verifyCard = {};
      _ref = this.Functions;
      for (name in _ref) {
        method = _ref[name];
        this.verifyCard[name] = this.proxy(method);
      }
      this.cards = {};
      this.cardIndex = 0;
    }

    Header.prototype.get = function(key) {
      if (this.contains(key)) {
        return this.cards[key];
      } else {
        return console.warn("Header does not contain the key " + key);
      }
    };

    Header.prototype.getIndex = function(key) {
      if (this.contains(key)) {
        return this.cards[key][0];
      } else {
        return console.warn("Header does not contain the key " + key);
      }
    };

    Header.prototype.getComment = function(key) {
      if (this.contains(key)) {
        if (this.cards[key][2] != null) {
          return this.cards[key][2];
        } else {
          return console.warn("" + key + " does not contain a comment");
        }
      } else {
        return console.warn("Header does not contain the key " + key);
      }
    };

    Header.prototype.getComments = function() {
      if (this.contains('COMMENT')) {
        return this.cards['COMMENT'];
      } else {
        return console.warn("Header does not contain any COMMENT fields");
      }
    };

    Header.prototype.getHistory = function() {
      if (this.contains('HISTORY')) {
        return this.cards['HISTORY'];
      } else {
        return console.warn("Header does not contain any HISTORY fields");
      }
    };

    Header.prototype.set = function(key, value, comment) {
      this.cards[key] = comment ? [this.cardIndex, value, comment] : [this.cardIndex, value];
      return this.cardIndex += 1;
    };

    Header.prototype.setComment = function(comment) {
      if (!this.contains("COMMENT")) {
        this.cards["COMMENT"] = [];
        this.cardIndex += 1;
      }
      return this.cards["COMMENT"].push(comment);
    };

    Header.prototype.setHistory = function(history) {
      if (!this.contains("HISTORY")) {
        this.cards["HISTORY"] = [];
        this.cardIndex += 1;
      }
      return this.cards["HISTORY"].push(history);
    };

    Header.prototype.contains = function(keyword) {
      return this.cards.hasOwnProperty(keyword);
    };

    Header.prototype.readCard = function(line) {
      var array, comment, index, key, keyToVerify, match, value, _ref, _ref1, _ref2, _ref3, _ref4;
      match = line.match(Header.keywordPattern);
      if (match == null) {
        return;
      }
      _ref = match.slice(1), key = _ref[0], value = _ref[1];
      if (key === "COMMENT" || key === "HISTORY") {
        match[1] = value.trim();
      } else if (value[0] === "'") {
        match = value.match(Header.stringPattern);
        match[1] = match[1].trim();
      } else {
        match = value.match(Header.nonStringPattern);
        match[1] = (_ref1 = match[1][0]) === "T" || _ref1 === "F" ? match[1].trim() : parseFloat(match[1]);
      }
      match[2] = match[2].trim();
      _ref2 = match.slice(1), value = _ref2[0], comment = _ref2[1];
      keyToVerify = key;
      _ref3 = [false, void 0], array = _ref3[0], index = _ref3[1];
      match = key.match(Header.arrayPattern);
      if (match != null) {
        keyToVerify = match[1];
        _ref4 = [true, match[2]], array = _ref4[0], index = _ref4[1];
      }
      if (this.verifyCard.hasOwnProperty(keyToVerify)) {
        value = this.verifyCard[keyToVerify](value, array, index);
      }
      switch (key) {
        case "COMMENT":
          return this.setComment(value);
        case "HISTORY":
          return this.setHistory(value);
        default:
          this.set(key, value, comment);
          return this.__defineGetter__(key, function() {
            return this.cards[key][1];
          });
      }
    };

    Header.prototype.hasDataUnit = function() {
      if (this["NAXIS"] === 0) {
        return false;
      } else {
        return true;
      }
    };

    return Header;

  })(Module);

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Header;
  }

}).call(this);
