const fetchApiTokens = () => {
  fetch(Spree.routes.api_tokens, {
    method: 'GET',
    credentials: 'same-origin'
  }).then(function (response) {
    switch (response.status) {
      case 200:
        response.json().then(function (json) {
          SpreeAPI.orderToken = json.order_token
          SpreeAPI.oauthToken = json.oauth_token
        })
        break
    }
  })
}

document.addEventListener("turbo:load", fetchApiTokens)
