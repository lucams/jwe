var app = angular.module('app', ['ui.bootstrap', 'angularSpinner']);

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

app.directive('ngElementReady', [function() {
    return {
        priority: Number.MIN_SAFE_INTEGER, // execute last, after all other directives if any.
        restrict: "A",
        link: function($scope, $element, $attributes) {
            $scope.$eval($attributes.ngElementReady); // execute the expression in the attribute.
        }
    };
}]);

app.directive('focusOn', function() {
	   return function(scope, elem, attr) {
	      scope.$on(attr.focusOn, function(e) {
	          elem[0].focus();
	      });
	   };
	});

app.service('ajaxService', function($http) {
	this.getData = function(URL, ajaxMethod, ajaxParams) {
		var restURL = URL + ajaxParams;
		console.log("Inside ajaxService...");
		console.log("Connection using URL=[" + restURL + "], Method=[" + ajaxMethod + "]");
	    // $http() returns a $promise that we can add handlers with .then()
	    return $http({
	        method: ajaxMethod,
	        url: restURL,
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
	
	this.postFormData = function(URL, ajaxMethod, jsonData, ajaxParams) {
		var restURL = URL + ajaxParams;
		console.log("Inside ajaxService POST...");
		console.log("Connection using URL=[" + restURL + "], Method=[" + ajaxMethod + "]");
		
	    // $http() returns a $promise that we can add handlers with .then()
	    return $http({
	        method: ajaxMethod,
	        url: restURL,
	        headers : { 'Content-Type': 'application/x-www-form-urlencoded' },
	        data: jsonData,
	    });
	};
});
	    
/* -----------------------------------------------------------------------
* MAIN CONTROLLER  
--------------------------------------------------------------------------*/
app.controller('MainCtrl', function ($scope, $rootScope, $http, $log, $timeout, $modal, $filter, ajaxService, usSpinnerService) {
  
  $scope.showModal = false;
  $scope.debugFlag = false;
  $scope.modal = {};
  $scope.login = {};
  
  $scope.startSpin = function(key) {
  	usSpinnerService.spin(key);
  };
  
  $scope.stopSpin = function(key) {
  	usSpinnerService.stop(key);
  };
  
  $scope.init = function() {
	  console.log("Inside init()...");
	  $scope.login = {};
	  $scope.$broadcast('setFocus');
  };
  
  $scope.setDefaults = function(debugFlag) {
	  $scope.debugFlag = debugFlag;
  };
  
  $scope.clearLogin = function() {
	  console.log('Inside clearLogin...');
	  $scope.login = {};
	  $rootScope.$broadcast('setFocus');
  };
  
  $scope.processLogin = function() {
	$scope.startSpin('spinner-1');

	console.log('Inside loginUser: ');

	//---Cancel Modal Dialog Window---
	$scope.cancel = function () {
		console.log('Closing Modal Dialog Window...');
		$scope.showModal = false;
	};

	getLoginURL = "processLogin.jsp?";
	getLoginURL += '&etc=' + new Date().getTime();
	
	console.log("getLoginURL...: " + getLoginURL);
	
	function onSuccess(response) {
		console.log("+++++getLoginURL SUCCESS++++++");
		if ($scope.debugFlag == 'true') {
			console.log("Inside getLoginURL response..." + JSON.stringify(response.data));
		} else {
			console.log("Inside getLoginURL response...(XML response is being skipped, debug=false)");
		}
		if (response.data.status_code == '404') {
			$scope.showModalWindow('Error!', response.data.message, 'sm');
		} else {
		}
		$scope.stopSpin('spinner-1');
	};

	function onError(response) {
		console.log("-------getLoginURL FAILED-------");
		$scope.stopSpin('spinner-1');
		console.log("Inside getLoginURL error condition...");
		$scope.showModalWindow('Error!', response.data.message, 'sm');
	};

	//----MAKE AJAX REQUEST CALL to POST DATA----
	ajaxService.postFormData(getLoginURL, 'POST', $scope.login, '').then(onSuccess, onError);
  };
});

	  
/* -----------------------------------------------------------------------
* MODAL DIALOG WINDOW CONTROLLER  
--------------------------------------------------------------------------*/
app.controller('ModalInstanceCtrl', function ($scope, $modalInstance) {
  $scope.ok = function () {
    $modalInstance.dismiss('cancel');
  };
});
