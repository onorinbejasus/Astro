var SkyView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

SkyView = (function(_super) {

  __extends(SkyView, _super);

  SkyView.MOUSE_DOWN = 1;

  SkyView.MOUSE_UP = 0;

  SkyView.mouseState = SkyView.MOUSE_UP;

  SkyView.gridBlocks = 0;

  SkyView.rotation = null;

  SkyView.translation = null;

  SkyView.renderMode = 0;

  SkyView.Math = null;

  function SkyView(options) {
    this.keyPressed = __bind(this.keyPressed, this);
    this.getCoordinate = __bind(this.getCoordinate, this);
    this.getPosition = __bind(this.getPosition, this);
    this.getBoundingBox = __bind(this.getBoundingBox, this);
    this.jump = __bind(this.jump, this);
    this.panScroll = __bind(this.panScroll, this);
    this.panUp = __bind(this.panUp, this);
    this.panMove = __bind(this.panMove, this);
    this.panDown = __bind(this.panDown, this);
    this.render = __bind(this.render, this);
    this.deleteOverlay = __bind(this.deleteOverlay, this);
    this.addOverlay = __bind(this.addOverlay, this);
    this.setScale = __bind(this.setScale, this);    SkyView.__super__.constructor.call(this, options);
    this.mouse_coords = {
      'x': 0,
      'y': 0
    };
    this.translation = [0.0, 0.0, 0.99333];
    this.rotation = [0.0, -0.4, 0.0];
    this.renderMode = this.gl.TRIANGLES;
    this.Math = new math();
    this.overlays = [];
    $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
    $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
    this.render();
    return;
  }

  SkyView.prototype.setScale = function(value) {
    $('#Scale').text(((value + 1) * 15).toFixed(2));
  };

  SkyView.prototype.addOverlay = function(overlay) {
    this.overlays.push(overlay);
  };

  SkyView.prototype.deleteOverlay = function(name) {};

  SkyView.prototype.render = function() {
    var overlay, tile, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
    this.preRender(this.rotation, this.translation);
    _ref = this.overlays;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      overlay = _ref[_i];
      overlay.refresh();
    }
    _ref2 = this.overlays;
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      overlay = _ref2[_j];
      _ref3 = overlay.tiles;
      for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
        tile = _ref3[_k];
        if (tile.getSet()) {
          tile.bind(this.shaderProgram);
          if (overlay.survey === "SDSS") {
            this.gl.enable(this.gl.DEPTH_TEST);
            this.gl.disable(this.gl.BLEND);
          } else {
            this.gl.disable(this.gl.DEPTH_TEST);
            this.gl.enable(this.gl.BLEND);
            this.gl.blendFunc(this.gl.SRC_ALPHA, this.gl.ONE);
          }
          this.gl.uniform1f(this.shaderProgram.alphaUniform, overlay.alpha);
          tile.render(this.renderMode);
        }
      }
    }
  };

  SkyView.prototype.panDown = function(event) {
    this.mouseState = this.MOUSE_DOWN;
    this.mouse_coords.x = event.clientX;
    return this.mouse_coords.y = event.clientY;
  };

  SkyView.prototype.panMove = function(event) {
    var delta_x, delta_y;
    if (this.mouseState === this.MOUSE_DOWN) {
      delta_x = event.clientX - this.mouse_coords.x;
      delta_y = event.clientY - this.mouse_coords.y;
      this.mouse_coords.x = event.clientX;
      this.mouse_coords.y = event.clientY;
      if (delta_y > 0) {
        this.rotation[0] -= delta_y * Config.pan_sensitivity;
      } else if (delta_y < 0) {
        this.rotation[0] += -delta_y * Config.pan_sensitivity;
      }
      if (delta_x > 0) {
        this.rotation[1] -= delta_x * Config.pan_sensitivity;
      } else if (delta_y < 0) {
        this.rotation[1] += -delta_x * Config.pan_sensitivity;
      }
      $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
      return this.render();
    }
  };

  SkyView.prototype.panUp = function(event) {
    return this.mouseState = 0;
  };

  SkyView.prototype.panScroll = function(event) {
    var delta;
    delta = 0;
    if (!event) event = window.event;
    if (event.wheelDelta) {
      delta = event.wheelDelta / 60;
    } else if (event.detail) {
      delta = -event.detail / 2;
    }
    if (delta > 0) {
      this.translation[2] -= Config.scroll_sensitivity;
    } else {
      this.translation[2] += Config.scroll_sensitivity;
    }
    $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
    return this.render();
  };

  SkyView.prototype.jump = function(RA, Dec) {
    this.rotation[1] = -RA;
    this.rotation[0] = -Dec;
    $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
    $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
    return this.render();
  };

  SkyView.prototype.mouseHandler = function() {
    this.hookEvent(this.canvas, "mousedown", this.panDown);
    this.hookEvent(this.canvas, "mouseup", this.panUp);
    this.hookEvent(this.canvas, "mousewheel", this.panScroll);
    return this.hookEvent(this.canvas, "mousemove", this.panMove);
  };

  SkyView.prototype.hookEvent = function(element, eventName, callback) {
    if (typeof element === "string") element = document.getElementById(element);
    if (element === null) return;
    if (element.addEventListener) {
      if (eventName === 'mousewheel') {
        element.addEventListener('DOMMouseScroll', callback, false);
      }
      return element.addEventListener(eventName, callback, false);
    } else if (element.attachEvent) {
      return element.attachEvent("on" + eventName, callback);
    }
  };

  SkyView.prototype.unhookEvent = function(element, eventName, callback) {
    if (typeof element === "string") element = document.getElementById(element);
    if (element === null) return;
    if (element.removeEventListener) {
      if (eventName === 'mousewheel') {
        element.removeEventListener('DOMMouseScroll', callback, false);
      }
      element.removeEventListener(eventName, callback, false);
    } else if (element.detachEvent) {
      element.detachEvent("on" + eventName, callback);
    }
  };

  SkyView.prototype.getBoundingBox = function() {
    var max, min, range;
    max = this.getCoordinate(this.canvas.width, this.canvas.height);
    min = this.getCoordinate(0, 0);
    range = new Object();
    range.maxRA = max.x;
    range.minRA = min.x;
    range.maxDec = max.y;
    range.minDec = min.y;
    return range;
  };

  SkyView.prototype.getPosition = function() {
    var pos;
    pos = new Object;
    pos.ra = -this.rotation[1];
    pos.dec = -this.rotation[0];
    return pos;
  };

  SkyView.prototype.getCoordinate = function(x, y) {
    var Dec, RA, a, b, c, descrim, dir, far, intersection, inverse, matrices, near, origin, phi, raDec, success, t, theta;
    matrices = this.getMatrices();
    near = [];
    far = [];
    dir = [];
    success = GLU.unProject(x, this.gl.viewportHeight - y, 0.0, matrices[0], matrices[1], matrices[2], near);
    success = GLU.unProject(x, this.gl.viewportHeight - y, 1.0, matrices[0], matrices[1], matrices[2], far);
    dir = this.Math.subtract(far, near);
    origin = [0.0, 0.0, 0.0, 1.0];
    inverse = mat4.set(matrices[0], mat4.create());
    inverse = mat4.inverse(inverse);
    origin = this.Math.multiply(origin, inverse);
    dir = this.Math.norm(dir);
    a = this.Math.dot([dir[0], dir[1], dir[2], 1.0], [dir[0], dir[1], dir[2], 1.0]);
    b = this.Math.dot([origin[0], origin[1], origin[2], 0.0], [dir[0], dir[1], dir[2], 1.0]) * 2.0;
    c = this.Math.dot([origin[0], origin[1], origin[2], 0.0], [origin[0], origin[1], origin[2], 0.0]) - 1;
    t = [0, 0];
    descrim = Math.pow(b, 2) - (4.0 * a * c);
    if (descrim >= 0) {
      t[0] = (-b - Math.sqrt(descrim)) / (2.0 * a);
      t[1] = (-b + Math.sqrt(descrim)) / (2.0 * a);
    }
    intersection = this.Math.add(origin, this.Math.mult(dir, t[1]));
    theta = Math.atan(intersection[0] / intersection[2]) * 57.29577951308323;
    RA = theta;
    /*
    		if theta < 270
    			RA = 270 - RA
    		else
    			theta = 360 + (RA-270)
    */
    phi = Math.acos(intersection[1]) * 57.29577951308323;
    Dec = 90 - phi;
    raDec = new Object();
    raDec.x = RA;
    raDec.y = Dec;
    return raDec;
  };

  SkyView.prototype.keyPressed = function(key) {
    switch (String.fromCharCode(key.which)) {
      case 'i':
        this.rotation[0] -= 0.1;
        $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        this.render();
        break;
      case 'k':
        this.rotation[0] += 0.1;
        $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        this.render();
        break;
      case 'l':
        this.rotation[1] += 0.1;
        $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        if (-this.rotation[1] < 0) {
          $('#RA-Dec').text((360 - this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        } else if (-this.rotation[1] > 360) {
          $('#RA-Dec').text((this.rotation[1] + 360).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        }
        this.render();
        break;
      case 'j':
        this.rotation[1] -= 0.1;
        $('#RA-Dec').text((-this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        if (-this.rotation[1] > 360) {
          $('#RA-Dec').text((this.rotation[1] + 360).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        } else if (-this.rotation[1] < 0) {
          $('#RA-Dec').text((360 - this.rotation[1]).toFixed(8) + ", " + (-this.rotation[0]).toFixed(8));
        }
        this.render();
        break;
      case 'w':
        this.translation[2] += 0.001;
        $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
        this.render();
        break;
      case 's':
        this.translation[2] -= 0.001;
        $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
        this.render();
        break;
      case 'W':
        this.translation[2] += 0.01;
        $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
        this.render();
        break;
      case 'S':
        this.translation[2] -= 0.01;
        $('#Scale').text(((-this.translation[2] + 1) * 15).toFixed(2));
        this.render();
        break;
      case 't':
        this.getBoundingBox();
    }
  };

  return SkyView;

})(WebGL);
