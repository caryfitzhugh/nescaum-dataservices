#!/usr/bin/env node
var request = require('request');
var localeval = require('localeval');
var async = require('async');
var _ = require('lodash');
var fs = require("fs");

var base_url = "https://login.imapinvasives.org/nyimi/map/distribution_by_type";
var base_opts = {table: "observation"};

var insect_species = {
  "all_insects": "All Insects",
  "NY-2-859052": "Asian Long-horned Beetle",
  "NY-2-861748": "Brown Marmorated Stink Bug",
  "NY-2-748242": "Emerald Ash Borer",
  "NY-2-113466": "Hemlock Woolly Adelgid"
};

var types = [{key: "county",   type: "COUNTY", layer_num: 7},
             {key: "basin",    type: "HUC", layer_num: 9}];


// We want to iterate over all of the species, and make the request to the server.
// Generating the resulting JSON map
var result = {};
var global_regex = /feature\.data\['NAME'\] === '([^']+)'\s*\)\s*\{\s*num_obs\s*=\s*([0-9]+)/g;
var regex = /feature\.data\['NAME'\] === '([^']+)'\s*\)\s*\{\s*num_obs\s*=\s*([0-9]+)/;

async.forEachOf(insect_species,
  function ( species_name, species_id, species_done) {

    async.each(types, function (type, type_done ) {

      request({url: base_url, qs: _.merge({}, base_opts, type, {species_id: species_id})},

        function (err, resp, body) {
          var all_stats = _.reduce(body.match(global_regex), function (stats, match_line) {
            var match = regex.exec(match_line);
            stats[match[1]] = parseInt(match[2],10);
            return stats;
          }, {});

          _.set(result, species_name + "." + type.key, all_stats);

          type_done(null);
        }
      );
    }, function (err) { species_done(null); });
  }, function (err) {
    console.log(JSON.stringify(result, null, 2));
  });
