angular.module('vlg')

.controller('roomCtl', ['$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', ($scope, $state, $stateParams, game, dialog) ->

#  roomType = $stateParams.roomType
#  roomId = $stateParams.roomId

  MAX_PLAYER_COUNT = 16
  SPEAK_TIME_LIMIT = 15

  speakTimer = 0

  $scope.content =
    players: []
    showPlayerTools: false
    currentSpeaker: null
    currentSpeakerNameOrNumber: null
    leftSpeakTime: 0
    leftSpeakTimeString: ""

  # each of messageList is an array with element as object:
  #   content: array[object]
  #     style: [ng-style object]
  #     content: [string]
  $scope.content.messageList =
    chatting: []
    progress: []

  # @message is an object:
  #   content: string | array
  #     [array item]:
  #       style: [ng-style object]
  #       content: [string]
  _pushMessage = (type, message) ->
    if (typeof message) == "string"
      message = { content: message }
    if (typeof message.content) == "string"
      message.content = [{ content: message.content }]
    for contentItem, i in message.content
      message.content[i] = $.extend {
        content: ""
        style: {}
      }, contentItem
    $scope.content.messageList[type].push message
    return

  _pushChattingMessage = (message) ->
    _pushMessage "chatting", message
  _pushProgressMessage = (message) ->
    _pushMessage "progress", message

  # @message: [string]
  pushProgressPlain = (message) ->
    _pushProgressMessage message

  _updatePlayers = ()->
    playerList = game.data.roomPlayers.shangzuo.slice(0, MAX_PLAYER_COUNT)
    while playerList.length < MAX_PLAYER_COUNT then playerList.push({invalid:true})
    $scope.content.players = playerList

#  _updatePlayerStatus = () ->
#    inGame =  game.inGame()
#    for player, i in $scope.content.players
#      if not player.invalid
#        player.isDead = inGame and game.isDead(player.number)
#        player.canVote = ((not player.isDead) and game.data.voteEnabled and game.inVoteList(player.number) and inGame)
#        player.canKill = ((not player.isDead) and game.data.killEnabled and inGame)
#        player.canCheck = ((not player.isDead) and game.data.checkEnabled and inGame)
#        player.showHint = ((player.canVote or player.canKill or player.canCheck or player.isDead) and inGame)

  $scope.$on '$roomPlayersLoaded', ()->
    _updatePlayers()
    $scope.$apply()
  _updatePlayers()

  $scope.exitRoom = () ->
    if game.isShangzuo()
      dialog.alert "请先下座"
      return
    game.exitRoom (success, errorCode, errorMessage) ->
      if not success
        dialog.alert("无法退出房间，#{errorMessage}")
        return
      $scope.content.showPlayerTools = false
      $state.go "hall"

  $scope.doShangzuo = ()->
    if game.isShangzuo() then return
    game.doShangzuo (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  $scope.doXiazuo = ()->
    if not game.isShangzuo() then return
    game.doXiazuo (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  $scope.doShangmai = ()->
    if game.isShangmai() then return
    game.doShangmai (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  $scope.doXiamai = ()->
    if not game.isShangmai() then return
    game.doXiamai (success, errorCode, errorMessage)->
      if not success
        dialog.alert "操作失败，#{errorMessage}"
        return

  _onSpeakerEnd = () ->
    game.stopRecord()
    currentSpeakerNameOrNumber = $scope.content.currentSpeakerNameOrNumber
    $scope.content.currentSpeakerNameOrNumber = null
    $scope.content.leftSpeakTime = 0
    $scope.content.leftSpeakTimeString = ""
    if speakTimer > 0 then clearInterval speakTimer
    if currentSpeakerNameOrNumber
      if (typeof currentSpeakerNameOrNumber) == "number"
        pushProgressPlain "#{currentSpeakerNameOrNumber}号玩家发言完毕"
      else
        pushProgressPlain "玩家#{currentSpeakerNameOrNumber}发言完毕"
  $scope.$on '$speakerChanged', () ->
    $scope.content.currentSpeaker = game.data.currentSpeaker
    if $scope.content.currentSpeaker
      _onSpeakerEnd()
      if game.data.roomInGame
        $scope.content.currentSpeakerNameOrNumber = $scope.content.currentSpeaker.number
      else
        $scope.content.currentSpeakerNameOrNumber = $scope.content.currentSpeaker.name
      _startRecord = () ->
        $scope.content.leftSpeakTime = game.data.currentSpeakTimeLimit
        $scope.content.leftSpeakTimeString = "#{$scope.content.leftSpeakTime}"
        speakTimer = setInterval (()->
          $scope.content.leftSpeakTime -= 1
          $scope.content.leftSpeakTimeString = "#{$scope.content.leftSpeakTime}"
          $scope.$apply()
        ), 1000
        game.startRecord()
      if game.data.roomInGame then setTimeout _startRecord, 5000
      else _startRecord()
      if (typeof $scope.content.currentSpeakerNameOrNumber) == "number"
        if $scope.content.currentSpeaker.isDead
          game.audio.onLastwords($scope.content.currentSpeakerNameOrNumber)
          pushProgressPlain "#{$scope.content.currentSpeakerNameOrNumber}号玩家有遗言"
        else
          game.audio.onSpeak($scope.content.currentSpeakerNameOrNumber)
          pushProgressPlain "#{$scope.content.currentSpeakerNameOrNumber}号玩家正在发言"
      else
        pushProgressPlain "玩家#{$scope.content.currentSpeakerNameOrNumber}正在发言"
    else
      _onSpeakerEnd()
    $scope.$apply()
    return

  $scope.$on '$gameStarted', () ->
#    _updatePlayerStatus()
    roleString = "未知"
    if game.amKiller() then roleString = "杀手"
    if game.amCop() then roleString = "警察"
    if game.amVillager() then roleString = "平民"
    partnerString = ""
    if (not game.amVillager()) and game.data.gameInfo.partners and (game.data.gameInfo.partners.length > 0)
      partnerString = "，你的队友是" + ("#{n}号" for n in game.data.gameInfo.partners).join("、")
    specs = game.data.gameInfo.specs
    pushProgressPlain "游戏开始，你是#{game.data.gameInfo.number}号玩家, 你的身份是#{roleString}。本局游戏#{specs}杀#{specs}警#{partnerString}"
    $scope.$apply()
    return

  $scope.$on '$gameOver', (evt, result, score) ->
#    _updatePlayerStatus()
    resultString = switch result
      when game.const.RESULT_COPS_DIED then "警察死光了"
      when game.const.RESULT_KILLERS_DIED then "杀手死光了"
      when game.const.RESULT_VILLAGERS_DIED then "平民死光了"
      else result
    winLoseString = "游戏结束"
    if score < 0 then winLoseString = "你输了"
    if score > 0 then winLoseString = "你赢了"
    game.audio.onWin(result)
    pushProgressPlain "#{resultString}，#{winLoseString}"
    $scope.$apply()
    return

  $scope.$on '$night', () ->
#    _updatePlayerStatus()
    actionString = ""
    if game.data.killEnabled then actionString = "，请杀人"
    if game.data.checkEnabled then actionString = "，请验人"
    pushProgressPlain "天黑了#{actionString}"
    $scope.$apply()
    return

  $scope.$on '$daylight', (evt, killed_number) ->
#    _updatePlayerStatus()
    announceString = "昨夜是平安夜"
    if killed_number then announceString = "昨夜#{killed_number}号玩家被杀"
    if killed_number then game.audio.onOut(killed_number)
    pushProgressPlain "天亮了，#{announceString}"
    $scope.$apply()
    return

  $scope.$on '$checked', (evt, number, role) ->
    roleString = switch role
      when game.const.ROLE_KILLER then "杀手"
      when game.const.ROLE_COP then "警察"
      when game.const.ROLE_VILLAGER then "平民"
    pushProgressPlain "验人结果：#{number}号玩家的身份是#{roleString}"
    $scope.$apply()
    return

  $scope.$on '$voteStart', () ->
#    _updatePlayerStatus()
    game.audio.onVote()
    pushProgressPlain "现在开始投票"
    $scope.$apply()
    return
  $scope.$on '$pkInsideStart', () ->
#    _updatePlayerStatus()
    game.audio.onVote()
    pushProgressPlain "现在开始第二轮投票"
    $scope.$apply()
    return
  $scope.$on '$pkOutsideStart', () ->
#    _updatePlayerStatus()
    game.audio.onVote()
    pushProgressPlain "现在开始最后一轮投票"
    $scope.$apply()
    return
  $scope.$on '$voteOver', (evt, kicked_number, equal_list) ->
#    _updatePlayerStatus()
    if kicked_number
      game.audio.onOut(kicked_number)
      pushProgressPlain "投票结束，#{kicked_number}号玩家出局"
    else
      equalListString = (("#{num}号" for num in equal_list)).join "、"
      if game.data.voteStage == 1
        game.audio.onInsidePK()
        pushProgressPlain "投票结束，#{equalListString}玩家平票，进行场内PK"
      else if game.data.voteStage == 2
        game.audio.onOutsidePK()
        pushProgressPlain "投票结束，#{equalListString}玩家平票，进行场外PK"
      else
        pushProgressPlain "投票结束，#{equalListString}玩家平票，今天是平安日"
    $scope.$apply()
    return

#  $scope.$on '$baofei'

  doVote = (player) ->
    if (not player.invalid) and player.canVote
      if game.vote(player.number)
        pushProgressPlain("你已经投票给#{player.number}号玩家")
    return
  doKill = (player) ->
    if (not player.invalid) and player.canKill
      if game.kill(player.number)
        pushProgressPlain("你已经选择杀死#{player.number}号玩家")
  doCheck = (player) ->
    if (not player.invalid) and player.canCheck
      if game.check(player.number)
        pushProgressPlain("你已经选择查验#{player.number}号玩家")
    return
  doBaofei = () ->
    if (not game.amDead()) and game.data.baofeiEnabled
      if game.baofei()
        pushProgressPlain("你已选择爆匪")
    return

  $scope.actionPlayer = (player) ->
    if player.invalid then return
    if player.isDead then return
    if player.canVote then doVote(player)
    else if player.canCheck then doCheck(player)
    else if player.canKill then doKill(player)
    return

  $scope.actionBaofei = () ->
    doBaofei()

  $scope.actionEndSpeak = () ->
    game.endSpeak()

  return
])

.directive('roomContentBox', [() ->
  return {
    restrict: 'C'
    templateUrl: './pages/room/content-box.directive.html'
    scope:
      messageList: "=massages"
  }
])