(function() {
  var rootModule,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  $(function() {
    $(document).on("mousedown.adjust-bar", ".adjust-button", function(event) {
      var barEl, currentPos, totalHeight;
      barEl = $(this).closest('.adjust-bar');
      totalHeight = barEl.height() / window.resizeRate;
      currentPos = parseInt($(this).css('top').replace('px', ''));
      barEl.data('parentHeight', totalHeight);
      barEl.data('adjustState', true);
      barEl.data('adjustStartPosition', currentPos);
      return barEl.data('adjustStartEventY', (event.pageY - $('.container').offset().top) / window.resizeRate);
    });
    $(document).on("mousemove.adjust-bar", ".adjust-bar", function(event) {
      var currentPos, currentPosResized, deltaPos, totalHeight;
      if (!$(this).data('adjustState')) {
        return;
      }
      totalHeight = $(this).data('parentHeight');
      deltaPos = (event.pageY - $('.container').offset().top) / window.resizeRate - $(this).data('adjustStartEventY');
      currentPos = $(this).data('adjustStartPosition') + deltaPos;
      if (currentPos < 0 || currentPos > totalHeight) {
        return;
      }
      currentPosResized = currentPos;
      $(this).find('.adjust-button').css('top', currentPosResized + "px");
      $(this).data('value', Math.max(Math.min(1 - parseFloat(currentPos) / (parseFloat(totalHeight) - 1), 1), 0));
      return $(this).trigger('change');
    });
    return $(document).on("mouseup.adjust-bar", function(event) {
      return $('.adjust-bar').each(function() {
        if ($(this).data('adjustState')) {
          return $(this).data('adjustState', false);
        }
      });
    });
  });

  window.GameServer = function(gamecallback) {
    var enable_record, game_number, game_partners, game_role, game_specs, is_connected, isspeaking, jiazuplayernum, on_baofei, on_checked, on_close, on_enterroom, on_error, on_gameover, on_gamestart, on_jiazu, on_killed, on_login, on_open, on_putong, on_roomplayer, on_sha, on_shangmai, on_shangzuo, on_shayan, on_speaker, on_speakover, on_startvote, on_startvoteinsidepk, on_startvoteoutsidepk, on_voted, on_xiamai, on_xiazuo, on_yan, passwd, passwd_en, putongplayernum, rec, sendaudio, stat, that, user, ws, wsclose, wserror, wsmessage, wsopen;
    this.wsurl = "ws://localhost:8080/vlgsocket/game";
    that = this;
    stat = 0;
    user = null;
    passwd_en = null;
    passwd = null;
    isspeaking = false;
    putongplayernum = null;
    jiazuplayernum = null;
    game_role = null;
    game_number = null;
    game_specs = 0;
    game_partners = [];
    enable_record = false;
    ws = null;
    is_connected = false;
    this.enterputong = function(roomid) {
      roomid = Number(roomid);
      if (stat === 1 && roomid >= 0 && roomid < putongplayernum) {
        ws.send("action enter putong " + roomid);
        return 0;
      } else {
        return 1;
      }
    };
    this.enterjiazu = function(roomid) {
      roomid = Number(roomid);
      if (stat === 1 && roomid >= 0 && roomid < jiazuplayernum) {
        ws.send("action enter jiazu " + roomid);
        return 0;
      } else {
        return 1;
      }
    };
    this.shangmai = function() {
      if (stat !== 2 && stat !== 4) {
        return 1;
      }
      ws.send("action shangmai");
      return 0;
    };
    this.xiamai = function() {
      if (stat !== 3 && stat !== 5) {
        return 1;
      }
      ws.send("action xiamai");
      return 0;
    };
    this.shangzuo = function() {
      if (stat !== 2 && stat !== 3) {
        return 1;
      }
      ws.send("action shangzuo");
      return 0;
    };
    this.xiazuo = function() {
      if (stat !== 4 && stat !== 5) {
        return 1;
      }
      ws.send("action xiazuo");
      return 0;
    };
    this.quitroom = function() {
      if (stat !== 2) {
        return 1;
      }
      stat = 1;
      ws.send("action quit");
      return 0;
    };
    this.login = function(u, p) {
      if (stat !== 0) {
        return 1;
      }
      user = u;
      passwd = p;
      ws.send("query key");
      return 0;
    };
    this.query_roomputong = function() {
      if (stat === 0) {
        return 1;
      }
      ws.send("query roomputong");
      return 0;
    };
    this.query_roomjiazu = function() {
      if (stat === 0) {
        return 1;
      }
      ws.send("query roomjiazu");
      return 0;
    };
    on_login = gamecallback.onlogin;
    on_putong = gamecallback.onputong;
    on_jiazu = gamecallback.onjiazu;
    on_enterroom = gamecallback.onenterroom;
    on_roomplayer = gamecallback.onroomplayer;
    on_speaker = gamecallback.onspeaker;
    on_open = gamecallback.onopen;
    on_close = gamecallback.onclose;
    on_error = gamecallback.onerror;
    on_shangzuo = gamecallback.onshangzuo;
    on_xiazuo = gamecallback.onxiazuo;
    on_shangmai = gamecallback.onshangmai;
    on_xiamai = gamecallback.onxiamai;
    on_gamestart = gamecallback.ongamestart;
    on_gameover = gamecallback.ongameover;
    on_speakover = gamecallback.onspeakover;
    on_baofei = gamecallback.onbaofei;
    on_killed = gamecallback.ondaylight;
    on_checked = gamecallback.onchecked;
    on_voted = gamecallback.onvoted;
    on_startvote = gamecallback.onstartvote;
    on_startvoteinsidepk = gamecallback.onstartvoteinsidepk;
    on_startvoteoutsidepk = gamecallback.onstartvoteoutsidepk;
    on_sha = gamecallback.onsha;
    on_yan = gamecallback.onyan;
    on_shayan = gamecallback.onshayan;
    sendaudio = function(blob) {
      if (enable_record) {
        return ws.send(blob);
      }
    };
    rec = new Qrecorder(sendaudio);
    wsopen = function(evt) {
      is_connected = true;
      on_open(evt);
    };
    wsclose = function(evt) {
      is_connected = false;
      on_close(evt);
    };
    wsmessage = function(evt) {
      var audio, bb, equal_list, i, k, l, len, len1, len2, m, mess, n, nn, num, o, p, player_list, players, playerstatus, q, r, s, ss, t, v, x, xx;
      if (typeof evt.data !== "string") {
        bb = evt.data;
        audio = new Audio();
        audio.src = window.URL.createObjectURL(bb);
        audio.play();
        return;
      }
      mess = evt.data.split(" ");
      switch (mess[0]) {
        case "pubkey":
          passwd_en = passwd;
          return ws.send("login " + user + " " + passwd_en);
        case "login":
          ss = Number(mess[1]);
          on_login(ss);
          if (ss === 0) {
            stat = 1;
            ws.send("query roomputong");
            return ws.send("query roomjiazu");
          }
          break;
        case "roomputong":
          n = new Array();
          nn = mess[1].split('_');
          for (l = 0, len = nn.length; l < len; l++) {
            k = nn[l];
            n.push(Number(k));
          }
          putongplayernum = n.length;
          return on_putong(n);
        case "roomjiazu":
          n = new Array();
          nn = mess[1].split('_');
          for (o = 0, len1 = nn.length; o < len1; o++) {
            k = nn[o];
            n.push(Number(k));
          }
          jiazuplayernum = n.length;
          return on_jiazu(n);
        case "enter":
          ss = Number(mess[1]);
          on_enterroom(ss);
          if (ss === 0) {
            return stat = 2;
          }
          break;
        case "roomplayer":
          p = new Array();
          s = new Array();
          m = mess[1].split("#");
          for (i = q = 0; q <= 2; i = ++q) {
            ss = m[i].split(";");
            players = new Array();
            playerstatus = new Array();
            for (v = 0, len2 = ss.length; v < len2; v++) {
              k = ss[v];
              if (k.length === 0) {
                continue;
              }
              t = k.split(",");
              players.push(t[0]);
              playerstatus.push(t[1]);
            }
            p.push(players);
            s.push(playerstatus);
          }
          return on_roomplayer(p, s);
        case "shangzuo":
          r = Number(mess[1]);
          if (r === 0) {
            if (stat === 2) {
              stat = 4;
            } else if (stat === 3) {
              stat = 5;
            }
          }
          return on_shangzuo(r);
        case "xiazuo":
          r = Number(mess[1]);
          if (r === 0) {
            if (stat === 4) {
              stat = 2;
            } else if (stat === 5) {
              stat = 3;
            }
          }
          return on_xiazuo(r);
        case "shangmai":
          r = Number(mess[1]);
          if (r === 0) {
            if (stat === 2) {
              stat = 3;
            } else if (stat === 4) {
              stat = 5;
            }
          }
          return on_shangmai(r);
        case "xiamai":
          r = Number(mess[1]);
          if (r === 0) {
            if (stat === 3) {
              stat = 2;
            } else if (stat === 5) {
              stat = 4;
            }
          }
          return on_xiamai(r);
        case "speakover":
          if (stat === 3) {
            stat = 2;
          } else if (stat === 5) {
            stat = 4;
          } else if (stat === 7) {
            stat = 6;
          }
          return on_speakover();
        case "speaker":
          r = mess[1];
          t = Number(mess[2]);
          if (r === '#') {
            if (stat === 3) {
              stat = 2;
            } else if (stat === 5) {
              stat = 4;
            } else if (stat === 7) {
              stat = 6;
            }
          }
          return on_speaker(r, t);
        case "gamestart":
          game_specs = Number(mess[1]);
          player_list = mess[2].split("_");
          game_role = Number(mess[3]);
          game_number = Number(mess[4]);
          game_partners = mess[5] && (mess[5].length > 0) ? (function() {
            var len3, ref, results, y;
            ref = mess[5].split('_');
            results = [];
            for (y = 0, len3 = ref.length; y < len3; y++) {
              n = ref[y];
              results.push(Number(n));
            }
            return results;
          })() : [];
          if (stat === 4 || stat === 5) {
            stat = 6;
          }
          return on_gamestart();
        case "gameover":
          x = Number(mess[1]);
          s = Number(mess[2]);
          game_role = null;
          game_number = null;
          if (stat === 6 || stat === 7 || stat === 8) {
            stat = 2;
          }
          return on_gameover(x, s);
        case "sha":
          return on_sha();
        case "yan":
          return on_yan();
        case "shayan":
          return on_shayan();
        case "someonebaofei":
          x = Number(mess[1]);
          if ((x === game_number) && (stat === 6 || stat === 7)) {
            stat = 8;
          }
          return on_baofei(x);
        case "killed":
          x = Number(mess[1]);
          if (x > 0) {
            if ((x === game_number) && (stat === 6 || stat === 7)) {
              stat = 8;
            }
            return on_killed(x);
          } else {
            return on_killed(null);
          }
          break;
        case "voted":
          x = Number(mess[1]);
          if ((x === game_number) && (stat === 6 || stat === 7)) {
            stat = 8;
          }
          equal_list = void 0;
          if (x === 0) {
            equal_list = (function() {
              var len3, ref, results, y;
              ref = mess[2].split('_');
              results = [];
              for (y = 0, len3 = ref.length; y < len3; y++) {
                num = ref[y];
                results.push(num);
              }
              return results;
            })();
            x = null;
          }
          return on_voted(x, equal_list);
        case "checked":
          x = Number(mess[1] || null);
          r = Number(mess[2]);
          return on_checked(x, r);
        case "startvote":
          return on_startvote();
        case "startvoteinsidepk":
          xx = (function() {
            var len3, ref, results, y;
            ref = mess[1].split('_');
            results = [];
            for (y = 0, len3 = ref.length; y < len3; y++) {
              n = ref[y];
              results.push(Number(n));
            }
            return results;
          })();
          return on_startvoteinsidepk(xx);
        case "startvoteoutsidepk":
          xx = (function() {
            var len3, ref, results, y;
            ref = mess[1].split('_');
            results = [];
            for (y = 0, len3 = ref.length; y < len3; y++) {
              n = ref[y];
              results.push(Number(n));
            }
            return results;
          })();
          return on_startvoteoutsidepk(xx);
        default:
          break;
      }
    };
    wserror = function(evt) {
      is_connected = false;
      on_error(evt);
    };
    this.connect = function(wsurl) {
      ws = new WebSocket(wsurl || this.wsurl);
      ws.onopen = wsopen;
      ws.onclose = wsclose;
      ws.onmessage = wsmessage;
      ws.onerror = wserror;
      ws.binaryType = "blob";
    };
    this.isConnected = function() {
      return is_connected;
    };
    this.isLoggedIn = function() {
      return is_connected && (stat !== 0);
    };
    this.isShangzuo = function() {
      return (stat === 4) || (stat === 5) || (stat === 6) || (stat === 7) || (stat === 8);
    };
    this.isShangmai = function() {
      return (stat === 3) || (stat === 5) || (stat === 7);
    };
    this.myRole = function() {
      return game_role;
    };
    this.myNumber = function() {
      return game_number;
    };
    this.inGame = function() {
      return stat === 6 || stat === 7 || stat === 8;
    };
    this.gameInfo = function() {
      var info;
      info = {
        role: game_role,
        number: game_number,
        specs: game_specs,
        partners: game_partners
      };
      return info;
    };
    this.isDead = function() {
      return stat === 8;
    };
    this.kill = function(number) {
      if (!(game_role === window.GameServer.ROLE_KILLER)) {
        return 2;
      }
      if (this.isDead()) {
        return 1;
      }
      ws.send("action sha " + number);
      return 0;
    };
    this.check = function(number) {
      if (!(game_role === window.GameServer.ROLE_COP)) {
        return 2;
      }
      if (this.isDead()) {
        return 1;
      }
      ws.send("action yan " + number);
      return 0;
    };
    this.vote = function(number) {
      if (this.isDead()) {
        return 1;
      }
      ws.send("action vote " + number);
      return 0;
    };
    this.baofei = function() {
      ws.send("action baofei");
      return 0;
    };
    this.end_speak = function() {
      ws.send("action speakend");
      return 0;
    };
    this.startrec = function() {
      if (enable_record) {
        return rec.startrec();
      }
    };
    this.stoprec = function() {
      if (enable_record) {
        return rec.stoprec();
      }
    };
  };

  window.GameServer.ROLE_COP = 0;

  window.GameServer.ROLE_KILLER = 1;

  window.GameServer.ROLE_VILLAGER = 2;

  window.GameServer.RESULT_KILLERS_DIED = 1;

  window.GameServer.RESULT_COPS_DIED = 2;

  window.GameServer.RESULT_VILLAGERS_DIED = 3;

  $(function() {
    var e;
    try {
      window.AudioContext = window.AudioContext || window.webkitAudioContext;
      navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia;
      return window.URL = window.URL || window.webkitURL;
    } catch (error) {
      e = error;
      return console.log(e);
    }
  });

  window.Qrecorder = function(process) {
    var _check_and_start_timer, audioData, audio_context, config, input, mediaerror, rec, rec2, recorder, start, started, startmedia, stop, timer;
    audio_context = null;
    recorder = null;
    input = null;
    started = false;
    timer = null;
    config = {};
    config.sampleBits = 16;
    config.sampleRate = 44100 / 6;
    audioData = {
      size: 0,
      buffer: [],
      inputSampleRate: 44100 / 6,
      inputSampleBits: 16,
      outputSampleRate: config.sampleRate,
      oututSampleBits: config.sampleBits,
      input: function(data) {
        this.buffer.push(data);
        this.size += data.length;
      },
      compress: function() {
        var compression, data, index, item_buffer, j, l, len, length, offset, ref, result;
        data = new Float32Array(this.size);
        offset = 0;
        ref = this.buffer;
        for (l = 0, len = ref.length; l < len; l++) {
          item_buffer = ref[l];
          data.set(item_buffer, offset);
          offset += item_buffer.length;
        }
        return data;
        compression = parseInt(this.inputSampleRate / this.outputSampleRate);
        length = data.length / compression;
        result = new Float32Array(length);
        index = 0;
        j = 0;
        while (index < length) {
          result[index] = data[j];
          j += compression;
          index++;
        }
        return result;
      },
      encodeWAV: function() {
        var abyte, buffer, bytes, channelCount, data, dataLength, l, len, len1, o, offset, ref, ref1, s, sampleBits, sampleRate, val, writeString;
        sampleRate = Math.min(this.inputSampleRate, this.outputSampleRate);
        sampleBits = Math.min(this.inputSampleBits, this.oututSampleBits);
        bytes = this.compress();
        dataLength = bytes.length * (sampleBits / 8);
        buffer = new ArrayBuffer(44 + dataLength);
        data = new DataView(buffer);
        channelCount = 1;
        offset = 0;
        writeString = function(str) {
          var ch, i, l, len, results;
          results = [];
          for (i = l = 0, len = str.length; l < len; i = ++l) {
            ch = str[i];
            results.push(data.setUint8(offset + i, str.charCodeAt(i)));
          }
          return results;
        };
        writeString('RIFF');
        offset += 4;
        data.setUint32(offset, 36 + dataLength, true);
        offset += 4;
        writeString('WAVE');
        offset += 4;
        writeString('fmt ');
        offset += 4;
        data.setUint32(offset, 16, true);
        offset += 4;
        data.setUint16(offset, 1, true);
        offset += 2;
        data.setUint16(offset, channelCount, true);
        offset += 2;
        data.setUint32(offset, sampleRate, true);
        offset += 4;
        data.setUint32(offset, channelCount * sampleRate * (sampleBits / 8), true);
        offset += 4;
        data.setUint16(offset, channelCount * (sampleBits / 8), true);
        offset += 2;
        data.setUint16(offset, sampleBits, true);
        offset += 2;
        writeString('data');
        offset += 4;
        data.setUint32(offset, dataLength, true);
        offset += 4;
        if (sampleBits === 8) {
          for (l = 0, len = bytes.length; l < len; l++) {
            abyte = bytes[l];
            s = Math.max(-1, Math.min(1, abyte));
            val = (ref = s < 0) != null ? ref : s * {
              0x8000: s * 0x7FFF
            };
            val = parseInt(255 / (65535 / (val + 32768)));
            data.setInt8(offset, val, true);
            offset++;
          }
        } else {
          for (o = 0, len1 = bytes.length; o < len1; o++) {
            abyte = bytes[o];
            s = Math.max(-1, Math.min(1, abyte));
            data.setInt16(offset, (ref1 = s < 0) != null ? ref1 : s * {
              0x8000: s * 0x7FFF
            }, true);
            offset += 2;
          }
        }
        this.buffer = [];
        this.size = 0;
        return new Blob([data], {
          type: 'audio/wav'
        });
      }
    };
    rec2 = function() {
      return recorder.getBuffer(function(buffers) {
        var newBuffer, newSource;
        process(buffers);
        newSource = audio_context.createBufferSource();
        newBuffer = audio_context.createBuffer(2, buffers[0].length, audio_context.sampleRate);
        newBuffer.getChannelData(0).set(buffers[0]);
        newBuffer.getChannelData(1).set(buffers[1]);
        newSource.buffer = newBuffer;
        newSource.connect(audio_context.destination);
        newSource.start();
        return recorder.clear();
      });
    };
    rec = function() {
      return recorder.getBuffer(function(buffers) {
        var w;
        audioData.input(buffers[0]);
        w = audioData.encodeWAV();
        process(w);
        return recorder.clear();
      });
    };
    _check_and_start_timer = 0;
    start = function() {
      var _check_and_start;
      if (started) {
        return;
      }
      _check_and_start = function() {
        var has, newBuffer, newSource;
        if (_check_and_start_timer > 0) {
          clearTimeout(_check_and_start_timer);
        }
        if (recorder) {
          started = true;
          recorder.record();
          newSource = void 0;
          newBuffer = void 0;
          has = 0;
          return timer = setInterval(rec, 1000);
        } else {
          return _check_and_start_timer = setTimeout(_check_and_start, 100);
        }
      };
      return _check_and_start();
    };
    stop = function() {
      if (!started) {
        return;
      }
      started = false;
      return clearInterval(timer);
    };
    startmedia = function(stream) {
      var e, workerPath;
      console.log("start audio record");
      try {
        audio_context = new AudioContext();
      } catch (error) {
        e = error;
        console.error(e);
      }
      input = audio_context.createMediaStreamSource(stream);
      workerPath = document.location.pathname.replace(/[^\.]+\.[^\.]+$/, '');
      workerPath += "vendor/scripts/recorderWorker.js";
      return recorder = new Recorder(input, {
        workerPath: workerPath
      });
    };
    this.startrec = start;
    this.stoprec = stop;
    mediaerror = function(e) {
      console.error("Failed to initialize audio recorder", e);
    };
    return navigator.getUserMedia({
      audio: true
    }, startmedia, mediaerror);
  };

  $(window).resize(function() {
    var defaultFontSize, defaultHeight, defaultWidth, marginHor, marginVer, resizeRate, windowHeight, windowWidth;
    defaultWidth = 1920;
    defaultHeight = 1080;
    defaultFontSize = 10;
    windowWidth = $(window).width();
    windowHeight = $(window).height();
    resizeRate = windowWidth * defaultHeight > defaultWidth * windowHeight ? parseFloat(windowHeight) / parseFloat(defaultHeight) : parseFloat(windowWidth) / parseFloat(defaultWidth);
    marginVer = (windowHeight - defaultHeight * resizeRate) / 2;
    marginHor = (windowWidth - defaultWidth * resizeRate) / 2;
    $('.container').css({
      'position': "absolute",
      'transform': 'scale(' + resizeRate + ')',
      'transform-origin': '0 0',
      'top': marginVer + 'px',
      'left': marginHor + 'px'
    });
    window.resizeRate = resizeRate;
    return true;
  });

  $(document).ready(function() {
    $(window).resize();
    $('.container').show();
    return true;
  });

  rootModule = angular.module('vlg', ['ngRoute', 'ui.router']);

  angular.module('vlg').config([
    '$stateProvider', '$urlRouterProvider', function($stateProvider, $urlRouterProvider) {
      var _makeState;
      _makeState = function(cfg) {
        return $.extend({
          url: '/login',
          templateUrl: "pages/login/login.html",
          onEnter: [
            'GameService', '$state', function(GameService, $state) {
              if (!GameService.gameServer.isLoggedIn()) {
                return $state.go('login');
              }
            }
          ]
        }, cfg);
      };
      $stateProvider.state('login', _makeState({
        url: '/login',
        templateUrl: "pages/login/login.html",
        onEnter: null
      })).state('hall', _makeState({
        url: '/hall',
        templateUrl: "pages/hall/hall.html"
      })).state('profile', _makeState({
        url: '/profile',
        templateUrl: "pages/profile/profile.html",
        abstract: true
      })).state('profile.statistics', _makeState({
        url: '/statistics',
        templateUrl: "pages/profile/statistics.html"
      })).state('profile.inventory', _makeState({
        url: '/inventory',
        templateUrl: "pages/profile/inventory.html"
      })).state('room', _makeState({
        url: '/room',
        templateUrl: "pages/room/room.html"
      }));
      $urlRouterProvider.otherwise('/login');
    }
  ]);

  angular.module('vlg').factory('DialogService', [
    function() {
      var serviceObj;
      serviceObj = {};
      serviceObj.alert = function(message) {
        return window.alert(message);
      };
      return serviceObj;
    }
  ]);

  angular.module('vlg').factory('GameAudioService', [
    'GameService', 'GameAudioValue', 'GameConstant', function(GameService, GameAudioValue, GameConstant) {
      var audioItems, i, item, l, len, playAudio, playCallback, playList, playing, serviceObj;
      audioItems = [].concat(GameAudioValue);
      for (i = l = 0, len = audioItems.length; l < len; i = ++l) {
        item = audioItems[i];
        item.player = new Audio();
        item.player.preload = "auto";
        item.player.src = item.path;
      }
      serviceObj = {};
      playing = false;
      playList = [];
      playCallback = function() {
        var audioItem, len1, o, playListItem;
        if (playList.length > 0) {
          playing = true;
          playListItem = (playList.splice(0, 1))[0];
          audioItem = null;
          for (o = 0, len1 = audioItems.length; o < len1; o++) {
            item = audioItems[o];
            if (item.name === playListItem.name) {
              audioItem = item;
              break;
            }
          }
          if (!audioItem) {
            return;
          }
          audioItem.player.load();
          audioItem.player.play();
          audioItem.player.oncanplay = function() {
            return setTimeout(playCallback, audioItem.player.duration * 1000);
          };
          audioItem.player.onerror = function() {
            return setTimeout(playCallback, 0);
          };
        } else {
          playing = false;
        }
      };
      playAudio = function(name, callback) {
        playList.push({
          name: name,
          callback: callback
        });
        if (!playing) {
          playCallback();
        }
      };
      serviceObj.playAudio = function(name, callback) {
        playAudio(name, callback);
      };
      serviceObj.greetings = function(callback) {
        serviceObj.playAudio("greetings", callback);
      };
      serviceObj.mvp = function(callback) {
        serviceObj.playAudio("mvp", callback);
      };
      serviceObj.greetings = function(callback) {
        serviceObj.playAudio("greetings", callback);
      };
      serviceObj.onOutsidePK = function(callback) {
        serviceObj.playAudio("out-field-pk", callback);
      };
      serviceObj.onInsidePK = serviceObj.onPK = function(callback) {
        serviceObj.playAudio("pk", callback);
      };
      serviceObj.onVote = function(callback) {
        serviceObj.playAudio("vote", callback);
      };
      serviceObj.onWin = function(resultCode, callback) {
        if (resultCode === GameConstant.RESULT_KILLERS_DIED) {
          serviceObj.playAudio("win-cops", callback);
        } else {
          serviceObj.playAudio("win-killers", callback);
        }
      };
      serviceObj.onSpeak = function(playerNumber, callback) {
        playerNumber = parseInt(playerNumber);
        if (isNaN(playerNumber)) {
          return;
        }
        serviceObj.playAudio("speak-" + playerNumber, callback);
      };
      serviceObj.onBaofei = function(playerNumber, callback) {
        playerNumber = parseInt(playerNumber);
        if (isNaN(playerNumber)) {
          return;
        }
        serviceObj.playAudio("baofei-" + playerNumber, callback);
      };
      serviceObj.onLastwords = function(playerNumber, callback) {
        playerNumber = parseInt(playerNumber);
        if (isNaN(playerNumber)) {
          return;
        }
        serviceObj.playAudio("lastwords-" + playerNumber, callback);
      };
      serviceObj.onOut = function(playerNumber, callback) {
        playerNumber = parseInt(playerNumber);
        if (isNaN(playerNumber)) {
          return;
        }
        serviceObj.playAudio("out-" + playerNumber, callback);
      };
      return serviceObj;
    }
  ]);

  angular.module('vlg').value("GameAudioValue", [
    {
      name: "baofei-1",
      path: "vendor/audios/baofei-1.ogg"
    }, {
      name: "baofei-10",
      path: "vendor/audios/baofei-10.ogg"
    }, {
      name: "baofei-11",
      path: "vendor/audios/baofei-11.ogg"
    }, {
      name: "baofei-12",
      path: "vendor/audios/baofei-12.ogg"
    }, {
      name: "baofei-13",
      path: "vendor/audios/baofei-13.ogg"
    }, {
      name: "baofei-14",
      path: "vendor/audios/baofei-14.ogg"
    }, {
      name: "baofei-15",
      path: "vendor/audios/baofei-15.ogg"
    }, {
      name: "baofei-16",
      path: "vendor/audios/baofei-16.ogg"
    }, {
      name: "baofei-2",
      path: "vendor/audios/baofei-2.ogg"
    }, {
      name: "baofei-3",
      path: "vendor/audios/baofei-3.ogg"
    }, {
      name: "baofei-4",
      path: "vendor/audios/baofei-4.ogg"
    }, {
      name: "baofei-5",
      path: "vendor/audios/baofei-5.ogg"
    }, {
      name: "baofei-6",
      path: "vendor/audios/baofei-6.ogg"
    }, {
      name: "baofei-7",
      path: "vendor/audios/baofei-7.ogg"
    }, {
      name: "baofei-8",
      path: "vendor/audios/baofei-8.ogg"
    }, {
      name: "baofei-9",
      path: "vendor/audios/baofei-9.ogg"
    }, {
      name: "greetings",
      path: "vendor/audios/greetings.ogg"
    }, {
      name: "lastwords",
      path: "vendor/audios/lastwords.ogg"
    }, {
      name: "lastwords-1",
      path: "vendor/audios/lastwords-1.ogg"
    }, {
      name: "lastwords-2",
      path: "vendor/audios/lastwords-2.ogg"
    }, {
      name: "lastwords-3",
      path: "vendor/audios/lastwords-3.ogg"
    }, {
      name: "mvp",
      path: "vendor/audios/mvp.ogg"
    }, {
      name: "night-comes",
      path: "vendor/audios/night-comes.ogg"
    }, {
      name: "out-1",
      path: "vendor/audios/out-1.ogg"
    }, {
      name: "out-10",
      path: "vendor/audios/out-10.ogg"
    }, {
      name: "out-11",
      path: "vendor/audios/out-11.ogg"
    }, {
      name: "out-12",
      path: "vendor/audios/out-12.ogg"
    }, {
      name: "out-13",
      path: "vendor/audios/out-13.ogg"
    }, {
      name: "out-14",
      path: "vendor/audios/out-14.ogg"
    }, {
      name: "out-15",
      path: "vendor/audios/out-15.ogg"
    }, {
      name: "out-16",
      path: "vendor/audios/out-16.ogg"
    }, {
      name: "out-2",
      path: "vendor/audios/out-2.ogg"
    }, {
      name: "out-3",
      path: "vendor/audios/out-3.ogg"
    }, {
      name: "out-4",
      path: "vendor/audios/out-4.ogg"
    }, {
      name: "out-5",
      path: "vendor/audios/out-5.ogg"
    }, {
      name: "out-6",
      path: "vendor/audios/out-6.ogg"
    }, {
      name: "out-7",
      path: "vendor/audios/out-7.ogg"
    }, {
      name: "out-8",
      path: "vendor/audios/out-8.ogg"
    }, {
      name: "out-9",
      path: "vendor/audios/out-9.ogg"
    }, {
      name: "out-field-pk",
      path: "vendor/audios/out-field-pk.ogg"
    }, {
      name: "pk",
      path: "vendor/audios/pk.ogg"
    }, {
      name: "speak-1",
      path: "vendor/audios/speak-1.ogg"
    }, {
      name: "speak-10",
      path: "vendor/audios/speak-10.ogg"
    }, {
      name: "speak-11",
      path: "vendor/audios/speak-11.ogg"
    }, {
      name: "speak-12",
      path: "vendor/audios/speak-12.ogg"
    }, {
      name: "speak-13",
      path: "vendor/audios/speak-13.ogg"
    }, {
      name: "speak-14",
      path: "vendor/audios/speak-14.ogg"
    }, {
      name: "speak-15",
      path: "vendor/audios/speak-15.ogg"
    }, {
      name: "speak-16",
      path: "vendor/audios/speak-16.ogg"
    }, {
      name: "speak-2",
      path: "vendor/audios/speak-2.ogg"
    }, {
      name: "speak-3",
      path: "vendor/audios/speak-3.ogg"
    }, {
      name: "speak-4",
      path: "vendor/audios/speak-4.ogg"
    }, {
      name: "speak-5",
      path: "vendor/audios/speak-5.ogg"
    }, {
      name: "speak-6",
      path: "vendor/audios/speak-6.ogg"
    }, {
      name: "speak-7",
      path: "vendor/audios/speak-7.ogg"
    }, {
      name: "speak-8",
      path: "vendor/audios/speak-8.ogg"
    }, {
      name: "speak-9",
      path: "vendor/audios/speak-9.ogg"
    }, {
      name: "vote",
      path: "vendor/audios/vote.ogg"
    }, {
      name: "win-cops",
      path: "vendor/audios/win-cops.ogg"
    }, {
      name: "win-killers",
      path: "vendor/audios/win-killers.ogg"
    }
  ]);

  angular.module('vlg').factory('GameDataService', [
    'GameService', 'GameConstant', '$rootScope', function(GameService, GameConstant, $rootScope) {
      var _updatePlayerGameStatus, dataVendor;
      dataVendor = {
        putongRooms: [],
        jiazuRooms: [],
        roomPlayers: {
          shangmai: [],
          shangzuo: [],
          guanzhong: []
        },
        roomInfo: {
          type: null,
          id: null
        },
        currentSpeaker: null,
        currentSpeakTimeLimit: null,
        loginName: null,
        diedList: [],
        gameInfo: null,
        pkList: [],
        voteStage: 0,
        killEnabled: false,
        checkEnabled: false,
        voteEnabled: false,
        roomInGame: false,
        baofeiEnabled: false
      };
      _updatePlayerGameStatus = function() {
        var i, l, len, player, ref, results;
        ref = dataVendor.roomPlayers.shangzuo;
        results = [];
        for (i = l = 0, len = ref.length; l < len; i = ++l) {
          player = ref[i];
          if (!player.invalid) {
            if (dataVendor.gameInfo.role !== GameConstant.ROLE_KILLER) {
              player.canKill = false;
            }
            if (dataVendor.gameInfo.role !== GameConstant.ROLE_COP) {
              player.canCheck = false;
            }
            if (!dataVendor.killEnabled) {
              player.canKill = false;
            }
            if (!dataVendor.checkEnabled) {
              player.canCheck = false;
            }
            if (!dataVendor.voteEnabled) {
              player.canVote = false;
            }
            if (player.isDead || GameService.gameServer.isDead()) {
              player.canCheck = false;
              player.canVote = false;
              player.canKill = false;
            }
            results.push(player.showHint = (player.canVote || player.canKill || player.canCheck || player.isDead) && dataVendor.roomInGame);
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      GameService.$on('roomputong_playernum', function(player_nums) {
        var i, l, len, player_num;
        dataVendor.putongRooms.splice(0);
        for (i = l = 0, len = player_nums.length; l < len; i = ++l) {
          player_num = player_nums[i];
          dataVendor.putongRooms.push({
            playerCount: player_num,
            maxPlayerCount: 20,
            name: "普通房",
            type: "putong",
            id: i
          });
        }
        return $rootScope.$broadcast('$putongRoomLoaded');
      });
      GameService.$on('roomjiazu_playernum', function(player_nums) {
        var i, l, len, player_num;
        dataVendor.jiazuRooms.splice(0);
        for (i = l = 0, len = player_nums.length; l < len; i = ++l) {
          player_num = player_nums[i];
          dataVendor.jiazuRooms.push({
            playerCount: player_num,
            maxPlayerCount: 20,
            name: "家族房",
            type: "jiazu",
            id: i
          });
        }
        return $rootScope.$broadcast('$jiazuRoomLoaded');
      });
      GameService.$on('enterroom', function() {
        return dataVendor.roomInGame = false;
      });
      GameService.$on('roomplayer', function(players, status) {
        var i, j, l, len, len1, o, playerName, playerStatus, playerType, playerTypes, ref;
        playerTypes = Object.keys(dataVendor.roomPlayers);
        for (i = l = 0, len = playerTypes.length; l < len; i = ++l) {
          playerType = playerTypes[i];
          dataVendor.roomPlayers[playerType].splice(0);
          ref = players[i];
          for (j = o = 0, len1 = ref.length; o < len1; j = ++o) {
            playerName = ref[j];
            playerStatus = status[i][j];
            dataVendor.roomPlayers[playerType].push({
              name: playerName,
              status: parseInt(playerStatus),
              imageUrl: "vendor/images/login/bg.png"
            });
          }
        }
        return $rootScope.$broadcast('$roomPlayersLoaded');
      });
      GameService.$on('speaker', function(speaker_player_name_or_id, speak_time_limit) {
        var l, len, len1, o, player, ref, ref1, speakerPlayer;
        if (speaker_player_name_or_id === "#") {
          speaker_player_name_or_id = null;
          dataVendor.currentSpeaker = null;
          $rootScope.$broadcast('$speakerChanged');
          return;
        }
        speakerPlayer = null;
        if (dataVendor.roomInGame) {
          speaker_player_name_or_id = Number(speaker_player_name_or_id);
          ref = dataVendor.roomPlayers.shangzuo;
          for (l = 0, len = ref.length; l < len; l++) {
            player = ref[l];
            if (player.number === speaker_player_name_or_id) {
              speakerPlayer = player;
              break;
            }
          }
        } else {
          ref1 = [].concat(dataVendor.roomPlayers.shangzuo, dataVendor.roomPlayers.guanzhong);
          for (o = 0, len1 = ref1.length; o < len1; o++) {
            player = ref1[o];
            if (player.name === speaker_player_name_or_id) {
              speakerPlayer = player;
              break;
            }
          }
        }
        if (!speakerPlayer) {
          console.warn("[GameDataService] [on $speakerChanged] cannot find the corresponding player");
          return;
        }
        dataVendor.currentSpeaker = speakerPlayer;
        dataVendor.currentSpeakTimeLimit = speak_time_limit;
        $rootScope.$broadcast('$speakerChanged');
      });
      GameService.$on('gamestart', function() {
        var i, l, len, player, ref;
        dataVendor.gameInfo = GameService.gameServer.gameInfo();
        dataVendor.diedList.splice(0);
        dataVendor.killEnabled = false;
        dataVendor.checkEnabled = false;
        dataVendor.baofeiEnabled = false;
        dataVendor.voteEnabled = false;
        dataVendor.roomInGame = true;
        ref = dataVendor.roomPlayers.shangzuo;
        for (i = l = 0, len = ref.length; l < len; i = ++l) {
          player = ref[i];
          if (!player.invalid) {
            player.number = i + 1;
            player.isDead = false;
            player.canVote = false;
            player.canKill = false;
            player.canCheck = false;
          }
        }
        _updatePlayerGameStatus();
        $rootScope.$broadcast('$gameStarted');
      });
      GameService.$on('gameover', function(result, score) {
        dataVendor.diedList.splice(0);
        dataVendor.killEnabled = false;
        dataVendor.checkEnabled = false;
        dataVendor.voteEnabled = false;
        dataVendor.roomInGame = false;
        _updatePlayerGameStatus();
        $rootScope.$broadcast('$gameOver', result, score);
      });
      GameService.$on('daylight', function(killed_number) {
        var l, len, player, ref;
        dataVendor.killEnabled = false;
        dataVendor.checkEnabled = false;
        dataVendor.baofeiEnabled = false;
        if (killed_number) {
          dataVendor.diedList.push(killed_number);
        }
        ref = dataVendor.roomPlayers.shangzuo;
        for (l = 0, len = ref.length; l < len; l++) {
          player = ref[l];
          player.canCheck = false;
          player.canKill = false;
          player.canVote = false;
          if (player.number === killed_number) {
            player.isDead = true;
          }
        }
        _updatePlayerGameStatus();
        return $rootScope.$broadcast('$daylight', killed_number);
      });
      GameService.$on('voted', function(kicked_number, equal_list) {
        var l, len, len1, len2, num, o, player, q, ref, ref1;
        dataVendor.voteEnabled = false;
        if (kicked_number) {
          dataVendor.diedList.push(kicked_number);
          ref = dataVendor.roomPlayers.shangzuo;
          for (l = 0, len = ref.length; l < len; l++) {
            player = ref[l];
            player.canVote = false;
            if (player.number === kicked_number) {
              player.isDead = true;
            }
          }
          _updatePlayerGameStatus();
        }
        if (equal_list) {
          ref1 = dataVendor.roomPlayers.shangzuo;
          for (o = 0, len1 = ref1.length; o < len1; o++) {
            player = ref1[o];
            player.canVote = false;
          }
          _updatePlayerGameStatus();
          dataVendor.pkList.splice(0);
          for (q = 0, len2 = equal_list.length; q < len2; q++) {
            num = equal_list[q];
            dataVendor.pkList.push(num);
          }
        }
        return $rootScope.$broadcast('$voteOver', kicked_number, equal_list);
      });
      GameService.$on('checked', function(number, role) {
        return $rootScope.$broadcast('$checked', number, role);
      });
      GameService.$on('baofei', function(number) {
        var l, len, player, ref;
        if (number) {
          dataVendor.diedList.push(number);
          ref = dataVendor.roomPlayers.shangzuo;
          for (l = 0, len = ref.length; l < len; l++) {
            player = ref[l];
            if (player.number === number) {
              player.isDead = true;
            }
          }
          _updatePlayerGameStatus();
        }
        return $rootScope.$broadcast('$baofei', number);
      });
      GameService.$on('startvote', function() {
        var l, len, player, ref;
        dataVendor.currentSpeaker = null;
        $rootScope.$broadcast('$speakerChanged');
        dataVendor.voteStage = 1;
        dataVendor.voteEnabled = true;
        ref = dataVendor.roomPlayers.shangzuo;
        for (l = 0, len = ref.length; l < len; l++) {
          player = ref[l];
          player.canVote = true;
        }
        _updatePlayerGameStatus();
        return $rootScope.$broadcast('$voteStart');
      });
      GameService.$on('startvoteinsidepk', function(pk_list) {
        var l, len, len1, len2, num, o, player, q, ref;
        dataVendor.currentSpeaker = null;
        $rootScope.$broadcast('$speakerChanged');
        dataVendor.voteStage = 2;
        dataVendor.voteEnabled = true;
        if (pk_list) {
          dataVendor.pkList.splice(0);
          for (l = 0, len = pk_list.length; l < len; l++) {
            num = pk_list[l];
            dataVendor.pkList.push(num);
          }
        }
        ref = dataVendor.roomPlayers.shangzuo;
        for (o = 0, len1 = ref.length; o < len1; o++) {
          player = ref[o];
          player.canVote = false;
          for (q = 0, len2 = pk_list.length; q < len2; q++) {
            num = pk_list[q];
            if (player.number === num) {
              player.canVote = true;
            }
          }
        }
        _updatePlayerGameStatus();
        return $rootScope.$broadcast('$pkInsideStart');
      });
      GameService.$on('startvoteoutsidepk', function(pk_list) {
        var l, len, len1, len2, num, o, player, q, ref;
        dataVendor.currentSpeaker = null;
        $rootScope.$broadcast('$speakerChanged');
        dataVendor.voteStage = 3;
        dataVendor.voteEnabled = true;
        if (pk_list) {
          dataVendor.pkList.splice(0);
          for (l = 0, len = pk_list.length; l < len; l++) {
            num = pk_list[l];
            dataVendor.pkList.push(num);
          }
        }
        ref = dataVendor.roomPlayers.shangzuo;
        for (o = 0, len1 = ref.length; o < len1; o++) {
          player = ref[o];
          player.canVote = false;
          for (q = 0, len2 = pk_list.length; q < len2; q++) {
            num = pk_list[q];
            if (player.number === num) {
              player.canVote = true;
            }
          }
        }
        _updatePlayerGameStatus();
        return $rootScope.$broadcast('$pkOutsideStart');
      });
      GameService.$on('check', function() {
        var l, len, player, ref;
        dataVendor.checkEnabled = true;
        ref = dataVendor.roomPlayers.shangzuo;
        for (l = 0, len = ref.length; l < len; l++) {
          player = ref[l];
          player.canCheck = true;
        }
        _updatePlayerGameStatus();
        return $rootScope.$broadcast('$checkStart');
      });
      GameService.$on('kill', function() {
        var l, len, player, ref;
        dataVendor.killEnabled = true;
        dataVendor.baofeiEnabled = !GameService.gameServer.isDead();
        ref = dataVendor.roomPlayers.shangzuo;
        for (l = 0, len = ref.length; l < len; l++) {
          player = ref[l];
          player.canKill = true;
        }
        _updatePlayerGameStatus();
        return $rootScope.$broadcast('$killStart');
      });
      GameService.$on('night', function() {
        return $rootScope.$broadcast('$night');
      });
      dataVendor.updatePlayerGameStatus = function() {
        return _updatePlayerGameStatus();
      };
      return dataVendor;
    }
  ]).factory('GameConstant', [
    function() {
      var constants;
      constants = {
        ROLE_COP: window.GameServer.ROLE_COP,
        ROLE_KILLER: window.GameServer.ROLE_KILLER,
        ROLE_VILLAGER: window.GameServer.ROLE_VILLAGER,
        RESULT_KILLERS_DIED: window.GameServer.RESULT_KILLERS_DIED,
        RESULT_COPS_DIED: window.GameServer.RESULT_COPS_DIED,
        RESULT_VILLAGERS_DIED: window.GameServer.RESULT_VILLAGERS_DIED
      };
      return constants;
    }
  ]);

  angular.module('vlg').factory('GamePlayService', [
    'GameService', 'GameDataService', 'GameAudioService', 'GameConstant', function(GameService, GameDataService, GameAudioService, GameConstant) {
      var serviceObj;
      serviceObj = {};
      serviceObj.data = GameDataService;
      serviceObj.audio = GameAudioService;
      serviceObj.connect = function() {
        return GameService.connect();
      };
      serviceObj.isConnected = function() {
        return GameService.isConnected();
      };
      serviceObj.login = function(username, password, callback) {
        var statusCode;
        if (username && password) {
          GameService.$off('login');
          if (0 !== (statusCode = GameService.gameServer.login(username, password))) {
            if (callback) {
              callback(false, -1, "发生系统错误");
            }
          } else {
            GameService.$one('login', function(status) {
              var error_message;
              if (status === 0) {
                GameDataService.loginName = username;
                if (callback) {
                  return callback(true, 0, "");
                }
              } else if (status === 3) {
                if (callback) {
                  return callback(true, 3, "");
                }
              } else {
                error_message = "发生未知错误";
                if (status === 1) {
                  error_message = "用户尚未注册";
                }
                if (status === 2) {
                  error_message = "密码错误，请重试";
                }
                if (callback) {
                  return callback(false, status, error_message);
                }
              }
            });
          }
        }
      };
      serviceObj.enterRoom = function(roomType, roomId, callback) {
        var resultCode;
        resultCode = -999;
        switch (roomType) {
          case "putong":
            resultCode = -GameService.gameServer.enterputong(roomId);
            break;
          case "jiazu":
            resultCode = -GameService.gameServer.enterjiazu(roomId);
            break;
          default:
            resultCode = -999;
        }
        if (resultCode !== 0) {
          if (callback) {
            callback(false, resultCode, "发生系统错误");
          }
          return;
        }
        return GameService.$one('enterroom', function(status) {
          if (status !== 0) {
            if (callback) {
              callback(false, 1000 + status, "无法进入房间");
            }
            return;
          }
          GameDataService.roomInfo.type = roomType;
          GameDataService.roomInfo.id = roomId;
          if (callback) {
            return callback(true, 0, "");
          }
        });
      };
      serviceObj.exitRoom = function(callback) {
        if (0 !== GameService.gameServer.quitroom()) {
          if (callback) {
            callback(false, -1, "发生系统错误");
          }
          return;
        }
        GameDataService.roomPlayers.shangzuo.splice(0);
        GameDataService.roomPlayers.shangmai.splice(0);
        GameDataService.roomPlayers.guanzhong.splice(0);
        GameDataService.currentSpeaker = null;
        if (callback) {
          return callback(true, 0, "");
        }
      };
      serviceObj.getCurrentRoomShangzuoPlayers = function() {
        return GameDataService.roomPlayers.shangzuo;
      };
      serviceObj.getCurrentRoomShangmaiPlayers = function() {
        return GameDataService.roomPlayers.shangmai;
      };
      serviceObj.getCurrentRoomGuanzhongPlayers = function() {
        return GameDataService.roomPlayers.guanzhong;
      };
      serviceObj.doShangzuo = function(callback) {
        if (0 !== GameService.gameServer.shangzuo()) {
          if (callback) {
            callback(false, -1, "发生系统错误");
          }
          return;
        }
        return GameService.$one("shangzuo", function(status) {
          if (status !== 0) {
            if (callback) {
              callback(false, status, "发生未知错误(" + status + ")");
            }
            return;
          }
          if (callback) {
            return callback(true, 0, "");
          }
        });
      };
      serviceObj.doXiazuo = function(callback) {
        if (0 !== GameService.gameServer.xiazuo()) {
          if (callback) {
            callback(false, -1, "发生系统错误");
          }
          return;
        }
        return GameService.$one("xiazuo", function(status) {
          if (status !== 0) {
            if (callback) {
              callback(false, status, "发生未知错误(" + status + ")");
            }
            return;
          }
          if (callback) {
            return callback(true, 0, "");
          }
        });
      };
      serviceObj.doShangmai = function(callback) {
        if (0 !== GameService.gameServer.shangmai()) {
          if (callback) {
            callback(false, -1, "发生系统错误");
          }
          return;
        }
        return GameService.$one("shangmai", function(status) {
          if (status !== 0) {
            if (callback) {
              callback(false, status, "发生未知错误(" + status + ")");
            }
            return;
          }
          if (callback) {
            return callback(true, 0, "");
          }
        });
      };
      serviceObj.doXiamai = function(callback) {
        if (0 !== GameService.gameServer.xiamai()) {
          if (callback) {
            callback(false, -1, "发生系统错误");
          }
          return;
        }
        return GameService.$one("xiamai", function(status) {
          if (status !== 0) {
            if (callback) {
              callback(false, status, "发生未知错误(" + status + ")");
            }
            return;
          }
          if (callback) {
            return callback(true, 0, "");
          }
        });
      };
      serviceObj.isShangzuo = function() {
        return GameService.gameServer.isShangzuo();
      };
      serviceObj.isShangmai = function() {
        return GameService.gameServer.isShangmai();
      };
      serviceObj.inGame = function() {
        return GameService.gameServer.inGame();
      };
      serviceObj.isDead = function(number) {
        var l, len, n, ref;
        if (!number) {
          return GameService.gameServer.isDead();
        }
        ref = GameDataService.diedList;
        for (l = 0, len = ref.length; l < len; l++) {
          n = ref[l];
          if (n === number) {
            return true;
          }
        }
        return false;
      };
      serviceObj.kill = function(number) {
        var result;
        result = 0 === GameService.gameServer.kill(number);
        if (result) {
          GameDataService.killEnabled = false;
          GameDataService.updatePlayerGameStatus();
        }
        return result;
      };
      serviceObj.check = function(number) {
        var result;
        result = 0 === GameService.gameServer.check(number);
        if (result) {
          GameDataService.checkEnabled = false;
          GameDataService.updatePlayerGameStatus();
        }
        return result;
      };
      serviceObj.vote = function(number) {
        var result;
        result = 0 === GameService.gameServer.vote(number);
        if (result) {
          GameDataService.voteEnabled = false;
          GameDataService.updatePlayerGameStatus();
        }
        return result;
      };
      serviceObj.baofei = function() {
        var result;
        result = 0 === GameService.gameServer.baofei();
        if (result) {
          GameDataService.baofeiEnabled = false;
        }
        return result;
      };
      serviceObj.endSpeak = function() {
        var result;
        result = 0 === GameService.gameServer.end_speak();
        return result;
      };
      serviceObj.amKiller = function() {
        return GameDataService.gameInfo.role === GameConstant.ROLE_KILLER;
      };
      serviceObj.amCop = function() {
        return GameDataService.gameInfo.role === GameConstant.ROLE_COP;
      };
      serviceObj.amVillager = function() {
        return GameDataService.gameInfo.role === GameConstant.ROLE_VILLAGER;
      };
      serviceObj.amDead = function() {
        return serviceObj.isDead();
      };
      serviceObj.inVoteList = function(player_number) {
        var l, len, n, ref;
        if ((!GameDataService.pkList) || (GameDataService.pkList.length === 0)) {
          return true;
        }
        ref = GameDataService.pkList;
        for (l = 0, len = ref.length; l < len; l++) {
          n = ref[l];
          if (player_number === n) {
            return true;
          }
        }
        return false;
      };
      serviceObj.startRecord = function() {
        return GameService.gameServer.startrec();
      };
      serviceObj.stopRecord = function() {
        return GameService.gameServer.stoprec();
      };
      serviceObj["const"] = GameConstant;
      return serviceObj;
    }
  ]);

  angular.module('vlg').factory('GameService', [
    function() {
      var _callEvent, _callbacks, _validateEventExpression, gameServer, game_server_callback, on_baofei, on_check, on_checked, on_close, on_daylight, on_enterroom, on_error, on_gameover, on_gamestart, on_kill, on_login, on_night, on_open, on_roomjiazu_playernum, on_roomplayer, on_roomputong_playernum, on_shangmai, on_shangzuo, on_speaker, on_speakover, on_startvote, on_startvoteinsidepk, on_startvoteoutsidepk, on_voted, on_xiamai, on_xiazuo, serviceObj;
      _callbacks = {
        "roomputong_playernum": [],
        "roomjiazu_playernum": [],
        "enterroom": [],
        "login": [],
        "roomplayer": [],
        "speaker": [],
        "open": [],
        "close": [],
        "error": [],
        "shangzuo": [],
        "xiazuo": [],
        "shangmai": [],
        "xiamai": [],
        "gamestart": [],
        "speakover": [],
        "gameover": [],
        "baofei": [],
        "daylight": [],
        "checked": [],
        "voted": [],
        "startvote": [],
        "startvoteinsidepk": [],
        "startvoteoutsidepk": [],
        "kill": [],
        "check": [],
        "night": []
      };
      _validateEventExpression = function(eventExpr) {
        var eventClass, eventExprSplited, eventName;
        if ((typeof eventExpr !== "string") || (eventExpr.length === 0)) {
          throw "Event is not valid";
        }
        eventExprSplited = eventExpr.split('.');
        eventClass = eventExprSplited.length > 1 ? eventExprSplited.slice(1).join(".") : null;
        eventName = eventExprSplited[0];
        if (!(indexOf.call(Object.keys(_callbacks), eventName) >= 0)) {
          throw "Event name is not valid";
        }
        return {
          eventClass: eventClass,
          eventName: eventName
        };
      };
      _callEvent = function() {
        var args, c, eventClass, eventExpr, eventExprParsed, eventName, i, l, len, o, ref, ref1;
        eventExpr = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        eventExprParsed = _validateEventExpression(eventExpr);
        eventName = eventExprParsed.eventName;
        eventClass = eventExprParsed.eventClass;
        ref = _callbacks[eventName];
        for (l = 0, len = ref.length; l < len; l++) {
          c = ref[l];
          if ((!eventClass) || (eventClass === c.eventClass)) {
            if (!c._del_flag) {
              if (c.once) {
                c._del_flag = true;
              }
              c.f.apply(gameServer, args);
            }
          }
        }
        if (_callbacks[eventName].length > 0) {
          for (i = o = ref1 = _callbacks[eventName].length - 1; ref1 <= 0 ? o <= 0 : o >= 0; i = ref1 <= 0 ? ++o : --o) {
            if (_callbacks[eventName][i]._del_flag) {
              _callbacks[eventName].splice(i, 1);
            }
          }
        }
      };
      on_roomputong_playernum = function(player_num) {
        _callEvent("roomputong_playernum", player_num);
      };
      on_roomjiazu_playernum = function(player_num) {
        _callEvent("roomjiazu_playernum", player_num);
      };
      on_enterroom = function(status) {
        _callEvent("enterroom", status);
      };
      on_login = function(status) {
        _callEvent("login", status);
      };
      on_roomplayer = function(players, status) {
        _callEvent("roomplayer", players, status);
      };
      on_speaker = function(speaker_player_name, time_limit) {
        _callEvent("speaker", speaker_player_name, time_limit);
      };
      on_open = function(evt) {
        _callEvent("open", evt);
      };
      on_close = function(evt) {
        _callEvent("close", evt);
      };
      on_error = function(evt) {
        _callEvent("error", evt);
      };
      on_shangzuo = function(status) {
        _callEvent("shangzuo", status);
      };
      on_xiazuo = function(status) {
        _callEvent("xiazuo", status);
      };
      on_shangmai = function(status) {
        _callEvent("shangmai", status);
      };
      on_xiamai = function(status) {
        _callEvent("xiamai", status);
      };
      on_gamestart = function() {
        _callEvent("gamestart");
      };
      on_speakover = function() {
        _callEvent("speakover");
      };
      on_gameover = function(result, score) {
        _callEvent("gameover", result, score);
      };
      on_baofei = function(number) {
        _callEvent("baofei", number);
      };
      on_daylight = function(killed_number) {
        _callEvent("daylight", killed_number);
      };
      on_checked = function(number, role) {
        _callEvent("checked", number, role);
      };
      on_voted = function(number, equals) {
        _callEvent("voted", number, equals);
      };
      on_startvote = function() {
        _callEvent("startvote");
      };
      on_startvoteinsidepk = function(vote_list) {
        _callEvent("startvoteinsidepk", vote_list);
      };
      on_startvoteoutsidepk = function(vote_list) {
        _callEvent("startvoteoutsidepk", vote_list);
      };
      on_kill = function() {
        _callEvent("kill");
        on_night();
      };
      on_check = function() {
        _callEvent("check");
        on_night();
      };
      on_night = function() {
        _callEvent("night");
      };
      game_server_callback = {};
      game_server_callback.onlogin = on_login;
      game_server_callback.onputong = on_roomputong_playernum;
      game_server_callback.onjiazu = on_roomjiazu_playernum;
      game_server_callback.onenterroom = on_enterroom;
      game_server_callback.onroomplayer = on_roomplayer;
      game_server_callback.onspeaker = on_speaker;
      game_server_callback.onopen = on_open;
      game_server_callback.onclose = on_close;
      game_server_callback.onerror = on_error;
      game_server_callback.onshangzuo = on_shangzuo;
      game_server_callback.onxiazuo = on_xiazuo;
      game_server_callback.onshangmai = on_shangmai;
      game_server_callback.onxiamai = on_xiamai;
      game_server_callback.ongamestart = on_gamestart;
      game_server_callback.onspeakover = on_speakover;
      game_server_callback.ongameover = on_gameover;
      game_server_callback.onbaofei = on_baofei;
      game_server_callback.ondaylight = on_daylight;
      game_server_callback.onchecked = on_checked;
      game_server_callback.onvoted = on_voted;
      game_server_callback.onstartvote = on_startvote;
      game_server_callback.onstartvoteinsidepk = on_startvoteinsidepk;
      game_server_callback.onstartvoteoutsidepk = on_startvoteoutsidepk;
      game_server_callback.onsha = on_kill;
      game_server_callback.onyan = on_check;
      game_server_callback.onshayan = on_night;
      gameServer = new GameServer(game_server_callback);
      serviceObj = {};
      serviceObj.$on = function(eventExpr, callbackFunc) {
        var callbackObject, eventExprParsed;
        if (typeof callbackFunc !== "function") {
          throw "Callback is not valid";
        }
        eventExprParsed = _validateEventExpression(eventExpr);
        callbackObject = {
          eventClass: eventExprParsed.eventClass,
          eventName: eventExprParsed.eventName,
          once: false,
          f: callbackFunc
        };
        _callbacks[callbackObject.eventName].push(callbackObject);
      };
      serviceObj.$one = function(eventExpr, callbackFunc) {
        var callbackObject, eventExprParsed;
        if (typeof callbackFunc !== "function") {
          throw "Callback is not valid";
        }
        eventExprParsed = _validateEventExpression(eventExpr);
        callbackObject = {
          eventClass: eventExprParsed.eventClass,
          eventName: eventExprParsed.eventName,
          once: true,
          f: callbackFunc
        };
        _callbacks[callbackObject.eventName].push(callbackObject);
      };
      serviceObj.$off = function(eventExpr) {
        var eventClass, eventExprParsed, eventName, i, l, ref;
        eventExprParsed = _validateEventExpression(eventExpr);
        eventName = eventExprParsed.eventName;
        eventClass = eventExprParsed.eventClass;
        if (eventClass) {
          for (i = l = ref = _callbacks[eventName].length - 1; ref <= 0 ? l <= 0 : l >= 0; i = ref <= 0 ? ++l : --l) {
            if (_callbacks[eventName][i].eventClass === eventClass) {
              _callbacks[eventName].splice(i, 1);
            }
          }
        } else {
          _callbacks[eventName].splice(0);
        }
      };
      serviceObj.$trigger = function() {
        var args, eventExpr;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        eventExpr = args[0];
        _validateEventExpression(eventExpr);
        return setTimeout((function() {
          return _callEvent.apply(void 0, args);
        }), 0);
      };
      serviceObj.isConnected = function() {
        return gameServer.isConnected();
      };
      serviceObj.connect = function() {
        return gameServer.connect();
      };
      serviceObj.gameServer = gameServer;
      return serviceObj;
    }
  ]);

  angular.module('vlg').directive('leftMenu', function() {
    return {
      restrict: 'C',
      templateUrl: './pages/page-components/left-menu.html',
      link: function(scope, elem, attr) {
        return scope.section = elem.attr('section') || null;
      }
    };
  }).directive('rightPanelWrapper', function() {
    return {
      restrict: 'C',
      templateUrl: './pages/page-components/right-panel-wrapper.html'
    };
  }).directive('bottomRankWrapper', function() {
    return {
      restrict: 'C',
      templateUrl: './pages/page-components/bottom-rank-wrapper.html'
    };
  });

  angular.module('vlg').controller('hallCtl', [
    '$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', function($scope, $state, $stageParams, game, dialog) {
      var _currentPage, _loadPage, _pageSize;
      $scope.ROOM_PUTONG = "putong";
      $scope.ROOM_JIAZU = "jiazu";
      _pageSize = 10;
      _currentPage = 0;
      _loadPage = function(p) {
        var roomList, totalPages;
        roomList = (function() {
          switch ($scope.content.currentRoomFilter) {
            case $scope.ROOM_PUTONG:
              return game.data.putongRooms;
            case $scope.ROOM_JIAZU:
              return game.data.jiazuRooms;
            default:
              return [];
          }
        })();
        totalPages = Math.ceil(roomList.length / _pageSize);
        if (p < 0) {
          p = 0;
        }
        if (p >= totalPages) {
          p = totalPages - 1;
        }
        _currentPage = p;
        return $scope.content.currentRoomList = roomList.slice(p * _pageSize, (p + 1) * _pageSize);
      };
      $scope.content = {
        currentRoomFilter: $scope.ROOM_PUTONG,
        currentRoomList: []
      };
      $scope.changeRoomFilter = function(filterName) {
        if ($scope.content.currentRoomFilter === filterName) {
          return;
        }
        $scope.content.currentRoomFilter = filterName;
        return _loadPage(0);
      };
      $scope.nextPage = function() {
        return _loadPage(_currentPage + 1);
      };
      $scope.prevPage = function() {
        return _loadPage(_currentPage - 1);
      };
      $scope.$on('$putongRoomLoaded', function() {
        if ($scope.content.currentRoomFilter === $scope.ROOM_PUTONG) {
          return _loadPage(_currentPage);
        }
      });
      $scope.$on('$jiazuRoomLoaded', function() {
        if ($scope.content.currentRoomFilter === $scope.ROOM_JIAZU) {
          return _loadPage(_currentPage);
        }
      });
      _loadPage(_currentPage);
      $scope.enterRoom = function(roomItem) {
        return game.enterRoom(roomItem.type, roomItem.id, function(success, errorCode, errorMessage) {
          if (!success) {
            dialog.alert("无法进入房间，" + errorMessage);
            return;
          }
          return $state.go("room");
        });
      };
      $scope.quickJoin = function() {
        var roomIdx, roomList;
        roomList = (function() {
          switch ($scope.content.currentRoomFilter) {
            case $scope.ROOM_PUTONG:
              return game.data.putongRooms;
            case $scope.ROOM_JIAZU:
              return game.data.jiazuRooms;
            default:
              return [];
          }
        })();
        roomIdx = Math.floor(Math.random() * roomList.length);
        return $scope.enterRoom(roomList[roomIdx]);
      };
    }
  ]);

  angular.module('vlg').controller('loginCtl', [
    '$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', function($scope, $state, $stageParams, game, dialog) {
      $scope.loginForm = {
        username: "",
        password: ""
      };
      $scope.loginAction = function() {
        if (!game.isConnected()) {
          dialog.alert("尚未连接到服务器，请稍后或刷新浏览器重试");
          return;
        }
        if ($scope.loginForm.username && $scope.loginForm.password) {
          return game.login($scope.loginForm.username, $scope.loginForm.password, function(success, errorCode, errorMessage) {
            if (success) {
              return $state.go('hall');
            } else {
              return dialog.alert("登录失败，" + errorMessage);
            }
          });
        }
      };
    }
  ]);

  angular.module('vlg').controller('profileCtl', ['$scope', '$state', '$stateParams', function($scope, $state, $stageParams) {}]).controller('profileInventoryCtl', [
    '$scope', '$state', '$stateParams', function($scope, $state, $stageParams) {
      var i;
      return $scope.inventoryItems = (function() {
        var l, results;
        results = [];
        for (i = l = 1; l <= 20; i = ++l) {
          results.push({
            id: i
          });
        }
        return results;
      })();
    }
  ]).directive('inventoryPropsItem', function() {
    return {
      restrict: 'C',
      templateUrl: './pages/profile/inventory-props-item.html',
      scope: {
        inventoryItem: "=item"
      },
      link: function(scope, elem, attr) {}
    };
  });

  angular.module('vlg').controller('roomCtl', [
    '$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', function($scope, $state, $stateParams, game, dialog) {
      var MAX_PLAYER_COUNT, SPEAK_TIME_LIMIT, _onSpeakerEnd, _pushChattingMessage, _pushMessage, _pushProgressMessage, _updatePlayers, doBaofei, doCheck, doKill, doVote, pushProgressPlain, speakTimer;
      MAX_PLAYER_COUNT = 16;
      SPEAK_TIME_LIMIT = 15;
      speakTimer = 0;
      $scope.content = {
        players: [],
        showPlayerTools: false,
        currentSpeaker: null,
        currentSpeakerNameOrNumber: null,
        leftSpeakTime: 0,
        leftSpeakTimeString: ""
      };
      $scope.content.messageList = {
        chatting: [],
        progress: []
      };
      _pushMessage = function(type, message) {
        var contentItem, i, l, len, ref;
        if ((typeof message) === "string") {
          message = {
            content: message
          };
        }
        if ((typeof message.content) === "string") {
          message.content = [
            {
              content: message.content
            }
          ];
        }
        ref = message.content;
        for (i = l = 0, len = ref.length; l < len; i = ++l) {
          contentItem = ref[i];
          message.content[i] = $.extend({
            content: "",
            style: {}
          }, contentItem);
        }
        $scope.content.messageList[type].push(message);
      };
      _pushChattingMessage = function(message) {
        return _pushMessage("chatting", message);
      };
      _pushProgressMessage = function(message) {
        return _pushMessage("progress", message);
      };
      pushProgressPlain = function(message) {
        return _pushProgressMessage(message);
      };
      _updatePlayers = function() {
        var playerList;
        playerList = game.data.roomPlayers.shangzuo.slice(0, MAX_PLAYER_COUNT);
        while (playerList.length < MAX_PLAYER_COUNT) {
          playerList.push({
            invalid: true
          });
        }
        return $scope.content.players = playerList;
      };
      $scope.$on('$roomPlayersLoaded', function() {
        _updatePlayers();
        return $scope.$apply();
      });
      _updatePlayers();
      $scope.exitRoom = function() {
        if (game.isShangzuo()) {
          dialog.alert("请先下座");
          return;
        }
        return game.exitRoom(function(success, errorCode, errorMessage) {
          if (!success) {
            dialog.alert("无法退出房间，" + errorMessage);
            return;
          }
          $scope.content.showPlayerTools = false;
          return $state.go("hall");
        });
      };
      $scope.doShangzuo = function() {
        if (game.isShangzuo()) {
          return;
        }
        return game.doShangzuo(function(success, errorCode, errorMessage) {
          if (!success) {
            dialog.alert("操作失败，" + errorMessage);
          }
        });
      };
      $scope.doXiazuo = function() {
        if (!game.isShangzuo()) {
          return;
        }
        return game.doXiazuo(function(success, errorCode, errorMessage) {
          if (!success) {
            dialog.alert("操作失败，" + errorMessage);
          }
        });
      };
      $scope.doShangmai = function() {
        if (game.isShangmai()) {
          return;
        }
        return game.doShangmai(function(success, errorCode, errorMessage) {
          if (!success) {
            dialog.alert("操作失败，" + errorMessage);
          }
        });
      };
      $scope.doXiamai = function() {
        if (!game.isShangmai()) {
          return;
        }
        return game.doXiamai(function(success, errorCode, errorMessage) {
          if (!success) {
            dialog.alert("操作失败，" + errorMessage);
          }
        });
      };
      _onSpeakerEnd = function() {
        var currentSpeakerNameOrNumber;
        game.stopRecord();
        currentSpeakerNameOrNumber = $scope.content.currentSpeakerNameOrNumber;
        $scope.content.currentSpeakerNameOrNumber = null;
        $scope.content.leftSpeakTime = 0;
        $scope.content.leftSpeakTimeString = "";
        if (speakTimer > 0) {
          clearInterval(speakTimer);
        }
        if (currentSpeakerNameOrNumber) {
          if ((typeof currentSpeakerNameOrNumber) === "number") {
            return pushProgressPlain(currentSpeakerNameOrNumber + "号玩家发言完毕");
          } else {
            return pushProgressPlain("玩家" + currentSpeakerNameOrNumber + "发言完毕");
          }
        }
      };
      $scope.$on('$speakerChanged', function() {
        var _startRecord;
        $scope.content.currentSpeaker = game.data.currentSpeaker;
        if ($scope.content.currentSpeaker) {
          _onSpeakerEnd();
          if (game.data.roomInGame) {
            $scope.content.currentSpeakerNameOrNumber = $scope.content.currentSpeaker.number;
          } else {
            $scope.content.currentSpeakerNameOrNumber = $scope.content.currentSpeaker.name;
          }
          _startRecord = function() {
            $scope.content.leftSpeakTime = game.data.currentSpeakTimeLimit;
            $scope.content.leftSpeakTimeString = "" + $scope.content.leftSpeakTime;
            speakTimer = setInterval((function() {
              $scope.content.leftSpeakTime -= 1;
              $scope.content.leftSpeakTimeString = "" + $scope.content.leftSpeakTime;
              return $scope.$apply();
            }), 1000);
            return game.startRecord();
          };
          if (game.data.roomInGame) {
            setTimeout(_startRecord, 5000);
          } else {
            _startRecord();
          }
          if ((typeof $scope.content.currentSpeakerNameOrNumber) === "number") {
            if ($scope.content.currentSpeaker.isDead) {
              game.audio.onLastwords($scope.content.currentSpeakerNameOrNumber);
              pushProgressPlain($scope.content.currentSpeakerNameOrNumber + "号玩家有遗言");
            } else {
              game.audio.onSpeak($scope.content.currentSpeakerNameOrNumber);
              pushProgressPlain($scope.content.currentSpeakerNameOrNumber + "号玩家正在发言");
            }
          } else {
            pushProgressPlain("玩家" + $scope.content.currentSpeakerNameOrNumber + "正在发言");
          }
        } else {
          _onSpeakerEnd();
        }
        $scope.$apply();
      });
      $scope.$on('$gameStarted', function() {
        var n, partnerString, roleString, specs;
        roleString = "未知";
        if (game.amKiller()) {
          roleString = "杀手";
        }
        if (game.amCop()) {
          roleString = "警察";
        }
        if (game.amVillager()) {
          roleString = "平民";
        }
        partnerString = "";
        if ((!game.amVillager()) && game.data.gameInfo.partners && (game.data.gameInfo.partners.length > 0)) {
          partnerString = "，你的队友是" + ((function() {
            var l, len, ref, results;
            ref = game.data.gameInfo.partners;
            results = [];
            for (l = 0, len = ref.length; l < len; l++) {
              n = ref[l];
              results.push(n + "号");
            }
            return results;
          })()).join("、");
        }
        specs = game.data.gameInfo.specs;
        pushProgressPlain("游戏开始，你是" + game.data.gameInfo.number + "号玩家, 你的身份是" + roleString + "。本局游戏" + specs + "杀" + specs + "警" + partnerString);
        $scope.$apply();
      });
      $scope.$on('$gameOver', function(evt, result, score) {
        var resultString, winLoseString;
        resultString = (function() {
          switch (result) {
            case game["const"].RESULT_COPS_DIED:
              return "警察死光了";
            case game["const"].RESULT_KILLERS_DIED:
              return "杀手死光了";
            case game["const"].RESULT_VILLAGERS_DIED:
              return "平民死光了";
            default:
              return result;
          }
        })();
        winLoseString = "游戏结束";
        if (score < 0) {
          winLoseString = "你输了";
        }
        if (score > 0) {
          winLoseString = "你赢了";
        }
        game.audio.onWin(result);
        pushProgressPlain(resultString + "，" + winLoseString);
        $scope.$apply();
      });
      $scope.$on('$night', function() {
        var actionString;
        actionString = "";
        if (game.data.killEnabled) {
          actionString = "，请杀人";
        }
        if (game.data.checkEnabled) {
          actionString = "，请验人";
        }
        pushProgressPlain("天黑了" + actionString);
        $scope.$apply();
      });
      $scope.$on('$daylight', function(evt, killed_number) {
        var announceString;
        announceString = "昨夜是平安夜";
        if (killed_number) {
          announceString = "昨夜" + killed_number + "号玩家被杀";
        }
        if (killed_number) {
          game.audio.onOut(killed_number);
        }
        pushProgressPlain("天亮了，" + announceString);
        $scope.$apply();
      });
      $scope.$on('$checked', function(evt, number, role) {
        var roleString;
        roleString = (function() {
          switch (role) {
            case game["const"].ROLE_KILLER:
              return "杀手";
            case game["const"].ROLE_COP:
              return "警察";
            case game["const"].ROLE_VILLAGER:
              return "平民";
          }
        })();
        pushProgressPlain("验人结果：" + number + "号玩家的身份是" + roleString);
        $scope.$apply();
      });
      $scope.$on('$voteStart', function() {
        game.audio.onVote();
        pushProgressPlain("现在开始投票");
        $scope.$apply();
      });
      $scope.$on('$pkInsideStart', function() {
        game.audio.onVote();
        pushProgressPlain("现在开始第二轮投票");
        $scope.$apply();
      });
      $scope.$on('$pkOutsideStart', function() {
        game.audio.onVote();
        pushProgressPlain("现在开始最后一轮投票");
        $scope.$apply();
      });
      $scope.$on('$voteOver', function(evt, kicked_number, equal_list) {
        var equalListString, num;
        if (kicked_number) {
          game.audio.onOut(kicked_number);
          pushProgressPlain("投票结束，" + kicked_number + "号玩家出局");
        } else {
          equalListString = ((function() {
            var l, len, results;
            results = [];
            for (l = 0, len = equal_list.length; l < len; l++) {
              num = equal_list[l];
              results.push(num + "号");
            }
            return results;
          })()).join("、");
          if (game.data.voteStage === 1) {
            game.audio.onInsidePK();
            pushProgressPlain("投票结束，" + equalListString + "玩家平票，进行场内PK");
          } else if (game.data.voteStage === 2) {
            game.audio.onOutsidePK();
            pushProgressPlain("投票结束，" + equalListString + "玩家平票，进行场外PK");
          } else {
            pushProgressPlain("投票结束，" + equalListString + "玩家平票，今天是平安日");
          }
        }
        $scope.$apply();
      });
      doVote = function(player) {
        if ((!player.invalid) && player.canVote) {
          if (game.vote(player.number)) {
            pushProgressPlain("你已经投票给" + player.number + "号玩家");
          }
        }
      };
      doKill = function(player) {
        if ((!player.invalid) && player.canKill) {
          if (game.kill(player.number)) {
            return pushProgressPlain("你已经选择杀死" + player.number + "号玩家");
          }
        }
      };
      doCheck = function(player) {
        if ((!player.invalid) && player.canCheck) {
          if (game.check(player.number)) {
            pushProgressPlain("你已经选择查验" + player.number + "号玩家");
          }
        }
      };
      doBaofei = function() {
        if ((!game.amDead()) && game.data.baofeiEnabled) {
          if (game.baofei()) {
            pushProgressPlain("你已选择爆匪");
          }
        }
      };
      $scope.actionPlayer = function(player) {
        if (player.invalid) {
          return;
        }
        if (player.isDead) {
          return;
        }
        if (player.canVote) {
          doVote(player);
        } else if (player.canCheck) {
          doCheck(player);
        } else if (player.canKill) {
          doKill(player);
        }
      };
      $scope.actionBaofei = function() {
        return doBaofei();
      };
      $scope.actionEndSpeak = function() {
        return game.endSpeak();
      };
    }
  ]).directive('roomContentBox', [
    function() {
      return {
        restrict: 'C',
        templateUrl: './pages/room/content-box.directive.html',
        scope: {
          messageList: "=massages"
        }
      };
    }
  ]);

  angular.module('vlg').controller('topCtl', [
    '$scope', '$state', '$stateParams', 'GameService', 'DialogService', 'GameDataService', function($scope, $state, $stageParams, GameService, dialog) {
      $scope.nav = {};
      $scope.nav.section = "";
      GameService.$on('error', function(evt) {
        dialog.alert("与服务器的连接发生错误");
        return $state.go('login');
      });
      GameService.$on('close', function(evt) {
        dialog.alert("与服务器的连接中断");
        return $state.go('login');
      });
      GameService.connect();
    }
  ]);

}).call(this);
