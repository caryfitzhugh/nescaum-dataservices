const http = require('http');
const pg = require('pg');
const HOSTNAME = "grid2.rcc-acis.org";
const PORT = 80;
const PATH = "/GridData";

let conn_uri = process.env.MAP_RDS_CONNECTION_URI;
let db_table = process.argv[2];


const get_db_connection = () => {
  let client = new pg.Client({
    user: process.env.MAP_RDS_USERNAME,
    host: process.env.MAP_RDS_HOST,
    database: process.env.MAP_RDS_DB,
    password: process.env.MAP_RDS_PASSWORD,
    port: process.env.MAP_RDS_PORT})

  client.connect();
  return client;
};

const download_acis_data = (opts) => {
  return new Promise((win, lose) => {
    /*
     *{"grid":"loca:wmean:rcp85",
       "state":"NY",
        "elems":[{
          "elem":{
              "name":"maxt",
              "reduce": "cnt_gt_90",
              "interval":"yly"
              },
          "interval":[10],
          "duration":10,
          "reduce": "mean",
          "sdate":[2055],
          "edate":[2087],
          "area_reduce":"county_mean"
          }
    ]
}
     */

    /*
      grid: 'loca:wmean:rcp85',
      state: 'NY',
      elem_name: 'maxt',

       data_type: 'projected',
       variable_name: 'maxt',
       area_reduce: 'county_mean',
       elem_reduce: 'max',
       elem_interval: 'ANN',
       json_blob: null,
       ny_json_pk: 1 },
     */
    /*
    opts.grid = "loca:wmean:rcp85";
    opts.state = "NY";
    opts.elem_name = "maxt";
    opts.elem_reduce = "cnt_gt_90";
    opts.elem_interval = "yly";
    opts.area_reduce = 'county_mean';
    */

    let body = {
        "grid": opts.grid,
        "state": opts.state,
        "elems":[{
            "elem":{
                "name": opts.elem_name,
                "reduce":  opts.elem_reduce,
                "interval": opts.elem_interval
                },
            "interval": [opts.interval],
            "duration": opts.duration,
            "reduce": "mean",
            "sdate": opts.sdate,
            "edate": opts.edate,
            "area_reduce": opts.area_reduce
            }]
      };
    console.log(JSON.stringify(body));
    let req = http.request({
      hostname: HOSTNAME,
      port: PORT,
      path: PATH,
      method: "POST",
      headers: {
        "Content-Type":  "application/x-www-form-urlencoded",
        "User-Agent": "curl/7.51.0",
        "Accept": "*/*"
      }
    }, (res) => {
      console.log(`STATUS: ${res.statusCode}`);
      console.log(`HEADERS: ${JSON.stringify(res.headers)}`);
      res.setEncoding('utf8');
      let data = [];
      res.on('data', (chunk) => {
        data = data + chunk;
      });
      res.on('end', () => {
        win(data);
      });
    });

    req.on('error', (e) => {
      console.error(`problem with request: ${e.message}`);
      lose(e);
    });

    // write data to request body
    req.write(JSON.stringify(body));
    req.end();
  });
};

let rows_client = get_db_connection()

rows_client.query(`SELECT * FROM ${db_table}`, (err, res) => {
  if (err) {
    console.error(err.stack);
  } else {
    res.rows.forEach((row) => {
      // Process to fix up data
      let elem_interval = [];
      row.elem_interval.split(",").forEach((v) => {
        elem_interval.push(parseInt(v, 10));
      });
      row.elem_interval = elem_interval;

      let sdate = [];
      row.sdate.split(",").forEach((v) => {
        sdate.push(parseInt(v, 10));
      });
      row.sdate = sdate;

      let edate = [];
      row.edate.split(",").forEach((v) => {
        edate.push(parseInt(v, 10));
      });
      row.edate = edate;

      //
      download_acis_data(row)
        .then((data) => {
          const query = {
            text: `UPDATE ${db_table} SET json_blob = $1 WHERE ny_json_pk = $2`,
            values: [data, row.ny_json_pk]
          }
	console.log("Updating...")
          // callback
          let update_client = get_db_connection()
          update_client.query(query, (err, res) => {
            if (err) {
              console.log(err.stack)
            } else {
              console.log("Saved Record");
            }
            update_client.end();
          });
        });
    });
   }
   rows_client.end()
});
