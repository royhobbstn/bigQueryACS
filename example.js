
// serverless

const BigQuery = require('@google-cloud/bigquery');

var yourProjectId = 'censusbigquery'; // change this to point to your project name

exports.bigQueryTest = function bigQueryTest(req, res) {
    

  const sqlQuery = "select NAME, B19013_001 from acs1115.eseq059 where STATE = '08' and SUMLEVEL = '050' order by NAME asc;";


  // Instantiates a client
  const bigquery = BigQuery({
    projectId: yourProjectId
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
