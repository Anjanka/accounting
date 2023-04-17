import {Elm} from './Main.elm'
import './style.css'

const app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: {
        backendURL: process.env.ELM_APP_BACKEND_URL
    }
})

const tokenKey = 'accounting-user-token'

app.ports.storeToken.subscribe(function (token) {
    localStorage.setItem(tokenKey, token)
    app.ports.fetchToken.send(token)
})

app.ports.doFetchToken.subscribe(function () {
    const storedToken = localStorage.getItem(tokenKey)
    const tokenOrEmpty = storedToken ? storedToken : ''
    app.ports.fetchToken.send(tokenOrEmpty)
})