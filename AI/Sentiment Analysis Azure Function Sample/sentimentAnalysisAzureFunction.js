//Sentiment Analysis Azure Function

'use strict';

let https = require('https');
const subscription_key = "INSERT_YOUR_KEY_HERE";
const endpoint = "INSERT_YOUR_ENDPOINT_HERE";
const path = '/text/analytics/v2.1/sentiment'

module.exports = async function (context, req) {
    let documents = {
        'documents': [
            { 'id': '1', 'language': 'en', 'text': 'I\'m having a wonderful day!' },
            { 'id': '2', 'language': 'es', 'text': 'Today is terrible and I just want to go to bed.' },
        ]
    };


    let body = JSON.stringify(documents);

    let request_params = {
        method: 'POST',
        hostname: (new URL(endpoint)).hostname,
        path: path,
        headers: {
            'Ocp-Apim-Subscription-Key': subscription_key,
        }
    };

    let response = await makeRequest(request_params, body);
    context.res = {
        body: response
    }

};

function makeRequest(options, data) {
    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            res.setEncoding('utf8');
            let responseBody = '';

            res.on('data', (chunk) => {
                responseBody += chunk;
            });

            res.on('end', () => {
                resolve(JSON.parse(responseBody));
            });
        });

        req.on('error', (err) => {
            reject(err);
        });

        req.write(data)
        req.end();
    });
}
