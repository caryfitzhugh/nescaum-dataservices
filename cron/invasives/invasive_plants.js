#!/usr/bin/env node
var request = require('request');
var localeval = require('localeval');
var async = require('async');
var _ = require('lodash');
var fs = require("fs");

var base_url = "https://login.imapinvasives.org/nyimi/map/distribution_by_type/";
var base_opts = {table: "observation"};

var plant_species = {
  "all_plants": "All Plants",
  "NY-2-145344": "Autumn Olive, Autumn-olive",
  "NY-2-151919": "Black Swallow-wort, Louise's Swallow-wort, Dog-strangling Vine",
  "NY-2-128977": "Burning Bush, Winged Euonymus, Winged Burning Bush, Winged Spindletree",
  "NY-2-154063": "Canada Thistle, Creeping Thistle",
  "NY-2-147438": "Chinese Silver Grass, Eulalia, Chinese silvergrass, Maiden grass",
  "NY-2-145273": "Common Buckthorn",
  "NY-2-155546": "Common Frogbit, European Frog-bit, Frogbit, European frogbit",
  "NY-2-800788": "Common Reed, Common reed grass",
  "NY-2-146072": "Creeping Jennie, Moneywort, Creeping Jenny",
  "NY-2-145742": "Curly Pondweed, Crisped Pondweed, Curly-leaf pondweed, Curlyleaf pondweed, Crispy-leaved pondweed ",
  "NY-2-159460": "Eurasian Water-milfoil, European Water-milfoil, Spike Water-milfoil, Eurasian watermilfoil",
  "NY-2-148992": "European Privet, Common privet",
  "NY-2-127936": "Garlic Mustard",
  "NY-2-153454": "Giant Hogweed",
  "NY-2-IMAP1": "Honeysuckle (species unknown)",
  "NY-2-159017": "Hydrilla, Water-thyme, Florida Elodea, Water thyme",
  "NY-2-134460": "Japanese Barberry",
  "NY-2-129271": "Japanese Honeysuckle",
  "NY-2-135872": "Japanese Knotweed, Japanese Bamboo",
  "NY-2-142078": "Japanese Stiltgrass, Nepalese Browntop, Japanese stilt grass, Nepalgrass",
  "NY-2-135219": "Kudzu, Japanese arrowroot",
  "NY-2-133705": "Marsh Thistle, European Marsh Thistle",
  "NY-2-145545": "Mile-a-minute Weed, Mile-a-minute Vine, Asiatic Tearthum, Mile a minute weed",
  "NY-2-155789": "Morrow Honeysuckle, Morrows honeysuckle",
  "NY-2-640125": "Mugwort",
  "NY-2-129203": "Multiflora Rose, Rambler Rose",
  "NY-2-140646": "Norway Maple",
  "NY-2-139637": "Norway Spruce",
  "NY-2-131407": "Oriental Bittersweet, Asian Bittersweet, Asiatic Bittersweet",
  "NY-2-161289": "Pale Swallow-wort, Dog-strangling Vine, European Swallow-wort",
  "NY-2-160902": "Purple Loosestrife",
  "NY-2-834778": "Slender Falsebrome",
  "NY-2-152552": "Spotted Starthistle, Spotted Knapweed",
  "NY-2-155898": "Tartarian Honeysuckle",
  "NY-2-148863": "Tree-of-heaven, Tree of Heaven, Chinese Sumac, Ailanthus, Varnish-tree, Copa-tree",
  "NY-2-149241": "Water Chestnut, Water-chestnut",
  "NY-2-132592": "Wineberry, Japanese Wineberry, Wine Raspberry",
  "NY-2-149941": "Yellow Iris, Water-flag, Yellow flag iris, Water flag, Yellow flag"
};

var types = [{key: "county",   type: "COUNTY", layer_num: 7},
             {key: "basin",    type: "HUC", layer_num: 9}];

// We want to iterate over all of the species, and make the request to the server.
// Generating the resulting JSON map
var result = {};
var global_regex = /feature\.data\['NAME'\] === '([^']+)'\s*\)\s*\{\s*num_obs\s*=\s*([0-9]+)/g;
var regex = /feature\.data\['NAME'\] === '([^']+)'\s*\)\s*\{\s*num_obs\s*=\s*([0-9]+)/;

async.forEachOf(plant_species,
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
