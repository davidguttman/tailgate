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

navigator.id.get(auth);