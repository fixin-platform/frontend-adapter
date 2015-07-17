Package.oauth.OAuth._endOfPopupResponseTemplate = Package.oauth.OAuth._endOfPopupResponseTemplate.replace(/window.opener[^;]+/, """window.opener) {
  window.opener.postMessage({action: "_handleCredentialSecret", credentialToken: credentialToken, secret: credentialSecret}, "*")"""
)
