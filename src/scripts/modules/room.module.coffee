angular.module('vlg')

.controller('roomCtl', ['$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', ($scope, $state, $stateParams, game, dialog) ->

  roomType = $stateParams.roomType
  roomId = $stateParams.roomId

  $scope.content =
    players: []

  game.enterRoom roomType, roomId, (success, errorCode, errorMessage) ->
    if not success
      dialog.alert("无法进入房间，#{errorMessage}")
      $state.go('hall')
      return
    return

  return
])