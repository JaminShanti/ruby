#!/usr/bin/env bash


  "https://maps.googleapis.com/maps/api/geocode/json?&address=$siteZipcode"

  "https://maps.googleapis.com/maps/api/geocode/json?&address=1316 Olga Avenue, High Point, NC 27260-5414"
  $myLatLng = "var $myLatLng = new google.maps.LatLng(41.89924, -87.62756);"
  $popup = "var popup=new google.maps.InfoWindow({content: "$popupmessage"});"
  $addMaker = "var $site = new google.maps.Marker({ position: $myLatLng,map: map, animation: google.maps.Animation.DROP, icon: image, });"
  $addListener = "google.maps.event.addListener($site, 'click', function(e) {console.log(e); popup.open(map, this);});"