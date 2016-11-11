angular.module('vlg')

.controller('roomCtl', ['$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', ($scope, $state, $stateParams, game, dialog) ->

#  roomType = $stateParams.roomType
#  roomId = $stateParams.roomId

  MAX_PLAYER_COUNT = 16

  $scope.content =
    players: []

  _updatePlayers = ()->
    playerList = game.data.roomPlayers.shangzuo.slice(0, MAX_PLAYER_COUNT)
    while playerList.length < MAX_PLAYER_COUNT then playerList.push({invalid:true})
    $scope.content.players = playerList

  $scope.$on '$onRoomPlayersLoaded', ()->
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



  return
])