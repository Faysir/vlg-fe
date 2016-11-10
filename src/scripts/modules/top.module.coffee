angular.module('vlg')

.controller('topCtl', ['$scope', '$state', '$stateParams', 'GameService', 'DialogService', ($scope, $state, $stageParams, GameService, dialog) ->
  $scope.nav = {}
  $scope.nav.section = ""

  GameService.$on 'error', (evt) ->
    dialog.alert("与服务器的连接发生错误")
    $state.go('login')
  GameService.$on 'close', (evt) ->
    dialog.alert("与服务器的连接中断")
    $state.go('login')

  console.log GameService.gameServer
  GameService.connect()

  return
])
