import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'login',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/LoginChat.vue')
  },
  {
    path: '/chats',
    name: 'chats',
    component: () => import(/* webpackChunkName: "about" */ '../views/GroupChat.vue')
  },
  {
    path: '/',
    name: 'home',
    component: () => import(/* webpackChunkName: "about" */ '../components/MenuLateral.vue')
  }
]

const router = new VueRouter({
  mode: 'history',
  routes
})

export default router
