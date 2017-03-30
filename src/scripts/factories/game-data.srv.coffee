angular.module('vlg')

.factory('GameDataService', ['GameService', 'GameConstant', '$rootScope', (GameService, GameConstant, $rootScope)->

  dataVendor =
    putongRooms: []
    jiazuRooms:  []
    roomPlayers:  # current room only
      shangmai:  []
      shangzuo:  []
      guanzhong: []
    roomInfo:
      type: null
      id: null
    currentSpeaker: null
    currentSpeakTimeLimit: null
    loginName: null
    diedList: []
    gameInfo: null
    pkList: []
    voteStage: 0 # 1: normal vote, 2: inside pk, 3: outside pk
    killEnabled: false
    checkEnabled: false
    voteEnabled: false
    roomInGame: false
    baofeiEnabled: false

  _updatePlayerGameStatus = () ->
    for player, i in dataVendor.roomPlayers.shangzuo
      if not player.invalid
        if dataVendor.gameInfo.role != GameConstant.ROLE_KILLER then player.canKill = false
        if dataVendor.gameInfo.role != GameConstant.ROLE_COP then player.canCheck = false
        if not dataVendor.killEnabled then player.canKill = false
        if not dataVendor.checkEnabled then player.canCheck = false
        if not dataVendor.voteEnabled then player.canVote = false
        if player.isDead or GameService.gameServer.isDead()
          player.canCheck = false
          player.canVote = false
          player.canKill = false
        player.showHint = ((player.canVote or player.canKill or player.canCheck or player.isDead) and dataVendor.roomInGame)

  GameService.$on 'roomputong_playernum', (player_nums)->
    dataVendor.putongRooms.splice(0)
    for player_num, i in player_nums
      dataVendor.putongRooms.push {
        playerCount: player_num
        maxPlayerCount: 20
        name: "普通房"
        type: "putong"
        id: i
      }
    $rootScope.$broadcast '$putongRoomLoaded'

  GameService.$on 'roomjiazu_playernum', (player_nums)->
    dataVendor.jiazuRooms.splice(0)
    for player_num, i in player_nums
      dataVendor.jiazuRooms.push {
        playerCount: player_num
        maxPlayerCount: 20
        name: "家族房"
        type: "jiazu"
        id: i
      }
    $rootScope.$broadcast '$jiazuRoomLoaded'

  GameService.$on 'enterroom', () ->
    dataVendor.roomInGame = false

  GameService.$on 'roomplayer', (players, status) ->
    playerTypes = Object.keys(dataVendor.roomPlayers)
    for playerType, i in playerTypes
      dataVendor.roomPlayers[playerType].splice 0
      for playerName, j in players[i]
        playerStatus = status[i][j]
        dataVendor.roomPlayers[playerType].push
          name: playerName
          status: parseInt(playerStatus)
          imageUrl: "vendor/images/login/bg.png"
    $rootScope.$broadcast '$roomPlayersLoaded'

  GameService.$on 'speaker', (speaker_player_name_or_id, speak_time_limit) ->
    if speaker_player_name_or_id == "#"
      speaker_player_name_or_id = null
      dataVendor.currentSpeaker = null
      $rootScope.$broadcast '$speakerChanged'
      return
    speakerPlayer = null

    if dataVendor.roomInGame
      speaker_player_name_or_id = Number speaker_player_name_or_id
      for player in dataVendor.roomPlayers.shangzuo
        if player.number == speaker_player_name_or_id
          speakerPlayer = player
          break
    else
      for player in [].concat(dataVendor.roomPlayers.shangzuo, dataVendor.roomPlayers.guanzhong)
        if player.name == speaker_player_name_or_id
          speakerPlayer = player
          break

    if not speakerPlayer
      console.warn "[GameDataService] [on $speakerChanged] cannot find the corresponding player"
      return
    dataVendor.currentSpeaker = speakerPlayer
    dataVendor.currentSpeakTimeLimit = speak_time_limit
    $rootScope.$broadcast '$speakerChanged'
    return

  GameService.$on 'gamestart', () ->
    dataVendor.gameInfo = GameService.gameServer.gameInfo()
    dataVendor.diedList.splice(0)
    # dataVendor.killEnabled = (dataVendor.gameInfo.role == GameConstant.ROLE_KILLER)
    # dataVendor.checkEnabled = (dataVendor.gameInfo.role == GameConstant.ROLE_COP)
    dataVendor.killEnabled = false
    dataVendor.checkEnabled = false
    dataVendor.baofeiEnabled = false
    dataVendor.voteEnabled = false
    dataVendor.roomInGame = true
    for player, i in dataVendor.roomPlayers.shangzuo
      if not player.invalid
        player.number = i + 1
        player.isDead = false
        player.canVote = false
        player.canKill = false # dataVendor.killEnabled
        player.canCheck = false # dataVendor.checkEnabled
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$gameStarted'
    return

  GameService.$on 'gameover', (result, score) ->
    # dataVendor.gameInfo = null
    dataVendor.diedList.splice(0)
    dataVendor.killEnabled = false
    dataVendor.checkEnabled = false
    dataVendor.voteEnabled = false
    dataVendor.roomInGame = false
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$gameOver', result, score
    return

  GameService.$on 'daylight', (killed_number) ->
    dataVendor.killEnabled = false
    dataVendor.checkEnabled = false
    dataVendor.baofeiEnabled = false
    if killed_number
      dataVendor.diedList.push(killed_number)
    for player in dataVendor.roomPlayers.shangzuo
      player.canCheck = false
      player.canKill = false
      player.canVote = false
      if player.number == killed_number then player.isDead = true
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$daylight', killed_number

  GameService.$on 'voted', (kicked_number, equal_list) ->
    dataVendor.voteEnabled = false
    if kicked_number
      dataVendor.diedList.push(kicked_number)
      for player in dataVendor.roomPlayers.shangzuo
        player.canVote = false
        if player.number == kicked_number then player.isDead = true
      _updatePlayerGameStatus()
    if equal_list
      for player in dataVendor.roomPlayers.shangzuo
        player.canVote = false
      _updatePlayerGameStatus()
      dataVendor.pkList.splice 0
      dataVendor.pkList.push num for num in equal_list
    $rootScope.$broadcast '$voteOver', kicked_number, equal_list

  GameService.$on 'checked', (number, role) ->
    $rootScope.$broadcast '$checked', number, role

  GameService.$on 'baofei', (number) ->
    if number
      dataVendor.diedList.push(number)
      for player in dataVendor.roomPlayers.shangzuo
        if player.number == number then player.isDead = true
      _updatePlayerGameStatus()
    $rootScope.$broadcast '$baofei', number

  GameService.$on 'startvote', () ->
    dataVendor.currentSpeaker = null
    $rootScope.$broadcast '$speakerChanged'
    dataVendor.voteStage = 1
    dataVendor.voteEnabled = true
    for player in dataVendor.roomPlayers.shangzuo
      player.canVote = true
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$voteStart'
  GameService.$on 'startvoteinsidepk', (pk_list) ->
    dataVendor.currentSpeaker = null
    $rootScope.$broadcast '$speakerChanged'
    dataVendor.voteStage = 2
    dataVendor.voteEnabled = true
    if pk_list
      dataVendor.pkList.splice 0
      dataVendor.pkList.push num for num in pk_list
    for player in dataVendor.roomPlayers.shangzuo
      player.canVote = false
      for num in pk_list
        if player.number == num then player.canVote = true
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$pkInsideStart'
  GameService.$on 'startvoteoutsidepk', (pk_list) ->
    dataVendor.currentSpeaker = null
    $rootScope.$broadcast '$speakerChanged'
    dataVendor.voteStage = 3
    dataVendor.voteEnabled = true
    if pk_list
      dataVendor.pkList.splice 0
      dataVendor.pkList.push num for num in pk_list
    for player in dataVendor.roomPlayers.shangzuo
      player.canVote = false
      for num in pk_list
        if player.number == num then player.canVote = true
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$pkOutsideStart'

  GameService.$on 'check', () ->
    dataVendor.checkEnabled = true
    for player in dataVendor.roomPlayers.shangzuo
      player.canCheck = true
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$checkStart'
  GameService.$on 'kill', () ->
    dataVendor.killEnabled = true
    dataVendor.baofeiEnabled = not GameService.gameServer.isDead()
    for player in dataVendor.roomPlayers.shangzuo
      player.canKill = true
    _updatePlayerGameStatus()
    $rootScope.$broadcast '$killStart'
  GameService.$on 'night', () ->
    $rootScope.$broadcast '$night'

  dataVendor.updatePlayerGameStatus = () ->
    _updatePlayerGameStatus()

  return dataVendor
])

.factory('GameConstant', [() ->
  constants =
    ROLE_COP: window.GameServer.ROLE_COP
    ROLE_KILLER: window.GameServer.ROLE_KILLER
    ROLE_VILLAGER: window.GameServer.ROLE_VILLAGER
    RESULT_KILLERS_DIED: window.GameServer.RESULT_KILLERS_DIED
    RESULT_COPS_DIED: window.GameServer.RESULT_COPS_DIED
    RESULT_VILLAGERS_DIED: window.GameServer.RESULT_VILLAGERS_DIED
  return constants
])