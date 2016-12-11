/**
 * Created by jaminshanti on 3/20/16.
 */


window.addEvent('domready', function initialize() {
        var mapOptions = {
          zoom: 7,
          panControl: true,
          mapTypeControl: true,
          center: new google.maps.LatLng(35.5570023, -79.6203712),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        }
        var map = new google.maps.Map(document.getElementById('map_canvas'),
                                      mapOptions);

        var image = 'http://maps.google.com/mapfiles/kml/pal2/icon2.png';
        var myLatLng = new google.maps.LatLng(41.89924, -87.62756);
        var marker = new google.maps.Marker({
            position: myLatLng,
            map: map,
            animation: google.maps.Animation.DROP,
            icon: image,
        });


    // Code for infowindow
    var popup=new google.maps.InfoWindow({
        content: "Hello"
    });

    google.maps.event.addListener(marker, 'click', function(e) {
        console.log(e);
        popup.open(map, this);
    });

})
initialize();




