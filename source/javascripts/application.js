import { RalixApp } from 'ralix'
import AppCtrl from './controllers/app'

const App = new RalixApp({
  routes: {
    '/.*': AppCtrl
  },
})

App.start()
