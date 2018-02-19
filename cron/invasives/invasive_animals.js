#!/usr/bin/env node
var request = require('request');
var localeval = require('localeval');
var async = require('async');
var _ = require('lodash');
var fs = require("fs");

var base_url = "https://login.imapinvasives.org/nyimi/map/distribution_by_type";
var base_opts = {table: "observation"};

var animal_species = {
  "all_animals": "All Animals",
  "NY-2-109333": "Asian Clam",
  "NY-2-800739": "Bloody-red Shrimp",
  "NY-2-IMAP22": "Jumping Worms (species unknown)",
  "NY-2-105636": "Common Carp",
  "NY-2-105520": "Feral Swine, Wild Boar",
  "NY-2-109133": "Quagga Mussel",
  "NY-2-100501": "Round Goby",
  "NY-2-109673": "Zebra Mussel"
};

var types = [{key: "county",   type: "COUNTY", layer_num: 7},
             {key: "basin",    type: "HUC", layer_num: 9}];

// We want to iterate over all of the species, and make the request to the server.
// Generating the resulting JSON map
var result = {};
var global_regex = /feature\.data\['NAME'\] === '([^']+)'\s*\)\s*\{\s*num_obs\s*=\s*([0-9]+)/g;
var regex = /feature\.data\['NAME'\] === '([^']+)'\s*\)\s*\{\s*num_obs\s*=\s*([0-9]+)/;

async.forEachOf(animal_species,
  function ( species_name, species_id, species_done) {

    async.each(types, function (type, type_done ) {
      request({url: base_url,
               headers: {
                  'User-Agent': 'node js scraper'
               },
               qs: _.merge({}, base_opts, type, {species_id: species_id})},

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
