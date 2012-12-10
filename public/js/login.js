auth = function(token) {
  if (!token) return;
  
  var onSuccess, opts;
  onSuccess = function(data) {
    console.log("Login Successful", data);
    return window.location = data;
  };
  opts = {
    url: "/login",
    success: onSuccess,
    data: {
      token: token
    },
    type: "POST"
  };
  return $.ajax(opts);
};

$(document).ready(function() {
  
  $('.login').on('click', function() {
    navigator.id.get(auth);
  });

});