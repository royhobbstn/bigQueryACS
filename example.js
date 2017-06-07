
// serverless

const BigQuery = require('@google-cloud/bigquery');


exports.bigQueryTest = function bigQueryTest(req, res) {
    

  const sqlQuery = "SELECT " + req.query.field  + ", sumlevel FROM `censusbigquery.acs0913.g20135co` where sumlevel='040';";


  // Instantiates a client
  const bigquery = BigQuery({
    projectId: 'censusbigquery'
  });

  // Query options list: https://cloud.google.com/bigquery/docs/reference/v2/jobs/query
  const options = {
    query: sqlQuery,
    useLegacySql: false // Use standard SQL syntax for queries.
  };

  // Runs the query
  bigquery
    .query(options)
    .then((results) => {
      const rows = results[0];
      res.status(200).send(rows);
    })
    .catch((err) => {
      res.status(500).send(err);
    });

};
