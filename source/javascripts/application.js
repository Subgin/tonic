// Dependencies
import { RalixApp } from 'ralix'
import 'sharer.js'

// Controllers
import AppCtrl from './controllers/app'

const App = new RalixApp({
  routes: {
    '/.*': AppCtrl
  },
})

App.start()
