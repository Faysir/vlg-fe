angular.module('vlg')

.controller('loginCtl', ['$scope', '$state', '$stateParams', 'GamePlayService', 'DialogService', ($scope, $state, $stageParams, game, dialog) ->

  $scope.loginForm =
    username: ""
    password: ""

  $scope.loginAction = ->
    if $scope.loginForm.username and $scope.loginForm.password
      game.login $scope.loginForm.username, $scope.loginForm.password, (success, errorCode, errorMessage) ->
        if success
          $state.go('hall')
        else
          dialog.alert "登录失败，#{errorMessage}"

  return
])
