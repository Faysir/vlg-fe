angular.module('vlg')

.controller('loginCtl', ['$scope', '$state', '$stateParams', ($scope, $state, $stageParams) ->
  $scope.loginAction = ->
    $state.go('hall')
  return
])
