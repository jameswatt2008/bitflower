var stem = angular.module('stem', [
  'stem.controllers', 
  'stem.directives', 
  'stem.services'
]);

stem.config(function($routeProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'templates/start.html',
      controller: 'StartController'
    });
});
