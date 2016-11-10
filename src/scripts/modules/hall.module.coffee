angular.module('vlg')

.controller('hallCtl', ['$scope', '$state', '$stateParams', 'GamePlayService', ($scope, $state, $stageParams, game) ->

  # room filter constants
  $scope.ROOM_PUTONG = "putong"
  $scope.ROOM_JIAZU = "jiazu"

  _pageSize = 10
  _currentPage = 0
  _loadPage = (p) ->
    roomList = switch $scope.content.currentRoomFilter
      when $scope.ROOM_PUTONG then game.data.putongRooms
      when $scope.ROOM_JIAZU  then game.data.jiazuRooms
      else []
    totalPages = Math.ceil(roomList.length / _pageSize)
    if p < 0 then p = 0
    if p >= totalPages then p = (totalPages - 1)
    _currentPage = p
    $scope.content.currentRoomList = roomList.slice(p * _pageSize, (p+1) * _pageSize)

  $scope.content =
    currentRoomFilter: $scope.ROOM_PUTONG
    currentRoomList: []

  $scope.changeRoomFilter = (filterName)->
    if $scope.content.currentRoomFilter == filterName then return
    $scope.content.currentRoomFilter = filterName
    _loadPage(0)

  $scope.nextPage = () ->
    _loadPage(_currentPage + 1)
  $scope.prevPage = () ->
    _loadPage(_currentPage - 1)

  $scope.$on '$onPutongRoomLoaded', ()->
    if $scope.content.currentRoomFilter == $scope.ROOM_PUTONG
      _loadPage(_currentPage)
  $scope.$on '$onJiazuRoomLoaded', ()->
    if $scope.content.currentRoomFilter == $scope.ROOM_JIAZU
      _loadPage(_currentPage)
  _loadPage(_currentPage)


  return

])
