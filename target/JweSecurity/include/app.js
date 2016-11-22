var app = angular.module('app', ['ngTouch', 'angularSpinner', 'ui.grid', 'ui.grid.resizeColumns', 'ui.grid.moveColumns']);

app.config(['usSpinnerConfigProvider', function (usSpinnerConfigProvider) {
    usSpinnerConfigProvider.setDefaults({
		lines: 13, // The number of lines to draw
		  length: 5, // The length of each line
		  width: 4, // The line thickness
		  radius: 8, // The radius of the inner circle
		  corners: 1, // Corner roundness (0..1)
		  rotate: 0, // The rotation offset
		  direction: 1, // 1: clockwise, -1: counterclockwise
		  color: '#333', // #rgb or #rrggbb or array of colors
		  speed: 1, // Rounds per second
		  trail: 80, // Afterglow percentage
		  shadow: false, // Whether to render a shadow
		  hwaccel: false, // Whether to use hardware acceleration
		  className: 'spinner', // The CSS class to assign to the spinner
		  zIndex: 2e9, // The z-index (defaults to 2000000000)
		  top: '50%', // Top position relative to parent
		  left: '50%' // Left position relative to parent
		});
}]);

app.service('ajaxService', function($http) {
	this.getData = function(URL, ajaxMethod, ajaxParams, token) {
		var restURL = URL + ajaxParams;
		console.log("Inside ajaxService...");
		console.log("Connection using URL=[" + restURL + "], Method=[" + ajaxMethod + "]");
	    // $http() returns a $promise that we can add handlers with .then()
	    return $http({
	        method: ajaxMethod,
	        url: restURL,
	        headers: { 'token': token }
	     });
	 };

	this.postData = function(URL, ajaxMethod, jsonData, ajaxParams) {
		var restURL = URL + ajaxParams;
		console.log("Inside ajaxService POST...");
		console.log("Connection using URL=[" + restURL + "], Method=[" + ajaxMethod + "]");
		
	    // $http() returns a $promise that we can add handlers with .then()
	    return $http({
	        method: ajaxMethod,
	        url: restURL,
	        headers: {'Content-Type': 'application/json'},
	        data: jsonData,
	     });
		
	};
});

/* -----------------------------------------------------------------------
* MAIN CONTROLLER  
--------------------------------------------------------------------------*/
app.controller('MainCtrl', function ($scope, $http, $log, uiGridConstants, ajaxService, usSpinnerService) {

	$scope.gridOptions = { 
		enableCellEditOnFocus: false,
		enableGridMenu: false,
		enableSorting: true,
		enableRowSelection: true,
		enableRowHeaderSelection: false,
		enableColumnResizing: true,
	};
	
	$scope.gridOptions.columnDefs = [
 	{ name: '_id', 
 		displayName: 'ID', 
 		width: 120, 
 		maxWidth: 150, 
 		minWidth: 90, 
 	},
 	{ name: 'item-id',
 		displayName: 'Item-ID', 
 		width: 120, 
 		maxWidth: 150, 
 		minWidth: 90, 
 	},
 	{ name: 'item-name', 
 		displayName: 'Item-Name', 
 		width: 510, 
 		maxWidth: 800, 
 		minWidth: 400, 
 	},
 	{ name: 'price', 
 		displayName: 'Price',  
 		width: 120, 
 		maxWidth: 200, 
 		minWidth: 70, 
 	},
 	{ name: 'quantity', 
 		displayName: 'Quantity',  
 		width: 110, 
 		maxWidth: 200, 
 		minWidth: 70, 
 	}
   ];
	
  $scope.startSpin = function(key) {
  	usSpinnerService.spin(key);
  };
  
  $scope.stopSpin = function(key) { 
  	usSpinnerService.stop(key);
  };

  $scope.loadAllRoles = function() {
	$scope.startSpin('spinner-0');
	console.log("Inside loadUserRoles " + $scope.loadAllRolesUrl);

	function onSuccess(response) {
		console.log("+++++loadUserRoles SUCCESS++++++");
		if (response.data.status_code != '403' || response.data.status_code != '404') { 
			$scope.userRoles  =  response.data;
		}
		$scope.stopSpin('spinner-0');
	};
		
	function onError(response) {
		console.log("-------loadUserRoles FAILED-------");
		$scope.stopSpin('spinner-0');
		console.log("Inside loadUserRoles error condition...");
	};  
	
	//----MAKE AJAX REQUEST CALL to GET DATA----
	ajaxService.getData($scope.loadAllRolesUrl, 'GET', '', $scope.token).then(onSuccess, onError);
  };

  $scope.loadAllItems = function() {
	$scope.startSpin('spinner-0');
	console.log("Inside loadAllItems " + $scope.loadAllItemsUrl);

	function onSuccess(response) {
		console.log("+++++loadAllItems SUCCESS++++++");
		if (response.data.status_code != '404') { 
			$scope.gridOptions.data  =  response.data;
		}
		$scope.stopSpin('spinner-0');
	};

	function onError(response) {
		console.log("-------loadAllItems FAILED-------");
		$scope.stopSpin('spinner-0');
		console.log("Inside loadAllItems error condition...");
	};  
	
	//----MAKE AJAX REQUEST CALL to GET DATA----
	ajaxService.getData($scope.loadAllItemsUrl, 'GET', '', $scope.token).then(onSuccess, onError);
  };
  
  $scope.setDefaults = function(baseUrl, username, token) {
	$scope.loadAllRolesUrl = baseUrl + "/JweSecurity/rest/security/getallroles";
	$scope.loadAllItemsUrl = baseUrl + "/JweSecurity/rest/security/showallitems";
	$scope.username = username;
	$scope.token = token;
	
	console.log("Setting Defaults");
	console.log("loadAllRolesUrl....: " + $scope.loadAllRolesUrl);
	console.log("loadAllItemsUrl....: " + $scope.loadAllItemsUrl);	
	console.log("username...........: " + $scope.username);
	console.log("token..............: " + $scope.token);
  };
});

app.directive('ngElementReady', [function() {
    return {
	    priority: Number.MIN_SAFE_INTEGER, 
	    restrict: "A",
	    link: function($scope, $element, $attributes) {
	        $scope.$eval($attributes.ngElementReady);
	    }
    };
}]);
