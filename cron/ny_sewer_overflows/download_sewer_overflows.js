#!/usr/bin/env node
var request = require('request');
var _ = require('lodash');
var fs = require("fs");

let url = "https://data.ny.gov/resource/5d4q-pk7d.json";

request({url: url},
  (err, resp, body) => {
    let data = {
            type: "FeatureCollection",
            features: []
    };
    _.each(JSON.parse(body), (point) => {
      data.features.push( {
              type: "Feature",
              geometry: point.location_1,
              properties: point
      });
    });

    console.log(JSON.stringify(data));
  });
