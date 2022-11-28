import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import vuetify from './plugins/vuetify'
import axios from "axios";

let baseURL = 'http://localhost:9000';
//let baseURL = 'http://192.168.5.108:9000';
const http = axios.create({ baseURL });

Vue.config.productionTip = false
Vue.prototype.$http = http;

new Vue({
  router,
  store,
  vuetify,
  render: h => h(App)
}).$mount('#app')