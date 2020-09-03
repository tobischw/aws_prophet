import { Elm } from './App/Main.elm';
import registerServiceWorker from './registerServiceWorker';
import { ACCESS_KEY_ID, SERCRET_ACCESS_KEY } from './keys';

const basePath = new URL(document.baseURI).pathname;

let app = Elm.App.Main.init({
  node: document.getElementById('root'),
  flags : { basePath }
});

let pricing = new AWS.Pricing({
  region: 'us-east-1',
  apiVersion: '2017-10-15',
  accessKeyId: ACCESS_KEY_ID,
  secretAccessKey: SERCRET_ACCESS_KEY
});

app.port.getProducts.subscribe(function ( message ) {
  let nextToken = message[0];
  let maxResults = message[1];
  let params = {
    Filters: [
      {
        Field: 'ServiceCode',
        Type: 'TERM_MATCH',
        Value: 'AmazonEC2'
      }
    ],
    ServiceCode: 'AmazonEC2',
    FormatVersion: 'aws_v1',
    MaxResults: maxResults,
    NextToken: nextToken
  };
  pricing.getProducts(params, function (err, data) {
    if (err) {
      console.log(err);
    } else { 
      app.ports.receiveProducts.send(JSON.stringify(data));  // successful response -- DECIDE: send back string JSON or just object?
    }
  });
});

registerServiceWorker();
