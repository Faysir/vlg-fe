angular.module('vlg')

.controller('loginCtl', ['$scope', '$state', '$stateParams', 'GameService', ($scope, $state, $stageParams, GameService) ->

  $scope.loginForm =
    username: ""
    password: ""

  $scope.loginAction = ->
    if $scope.loginForm.username and $scope.loginForm.password
      GameService.$one 'login.loginCtl', (status) ->
        if status == 0
          $state.go('hall')
        else
          alert "Login failed, error code: #{status}"
      if 0 != GameService.gameServer.login($scope.loginForm.username, $scope.loginForm.password)
        GameService.$off 'login.loginCtl'
        alert "Login failed, stat error"

  return
])
