Package.oauth.OAuth.lastCallback = null;

Package.oauth.OAuth.showPopup = _.wrap Package.oauth.OAuth.showPopup, (parent, url, callback, dimensions) ->
  Package.oauth.OAuth.lastCallback = callback
  parent.call(@, url, callback, dimensions)

window.addEventListener 'message', (event) ->
  message = event.data
  switch message.action
    when '_handleCredentialSecret'
      Package.oauth.OAuth._handleCredentialSecret message.credentialToken, message.secret
      Package.oauth.OAuth.lastCallback()
