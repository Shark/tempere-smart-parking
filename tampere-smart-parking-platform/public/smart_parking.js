document.addEventListener("DOMContentLoaded", function() {
  var request = new XMLHttpRequest();
  var url = 'http://localhost:3000/parkingspot'

  request.open('GET', url, true);

  request.onload = function () {
    var data = JSON.parse(this.response)
    console.log(data.latitude)
    document.getElementById('parkingSpot').href = "https://www.google.com/maps/dir/?api=1&destination=" + data.latitude + "," + data.longitude
  }
2
  request.send();
});
