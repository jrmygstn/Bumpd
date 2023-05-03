const SERVICE_PLAN_ID = 'YOUR_servicePlanId';
const API_TOKEN = 'YOUR_API_token';
const express = require('express');
const fetch = require('cross-fetch');
const app = express();
const port = 3000;
app.use(express.json());

app.post('/', async (req, res) => {
  var requestBody = req.body;
  console.log(requestBody);
  const sendSMS = {
    from: requestBody.to,
    to: [requestBody.from],
    body: 'You sent: ' + requestBody.body,
  };

  let result = await fetch(
    'https://us.sms.api.sinch.com/xms/v1/' + SERVICE_PLAN_ID + '/batches',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + API_TOKEN,
      },
      body: JSON.stringify(sendSMS),
    }
  );
  console.log(await result.json());
  res.send('Ok');
});

app.listen(port, () => {
  console.log(`Listening at http://localhost:${port}`);
});